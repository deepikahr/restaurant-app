import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/widgets/no-data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';

import '../../services/common.dart';
import '../../services/localizations.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../other/thank-you.dart';

SentryError sentryError = new SentryError();

class PaymentMethod extends StatefulWidget {
  final Map<String, dynamic> cart;
  final paymentMethods;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  PaymentMethod(
      {Key key,
      this.cart,
      this.locale,
      this.localizedValues,
      this.paymentMethods})
      : super(key: key);

  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  int groupValue;
  List cardList, paymentMethodList;
  bool isPaymentMethodLoading = false,
      paymentMethodAvaiilable = true,
      paymentMethodAvaiilableCon = true,
      isPlaceOrderLoading = false,
      isFirstTime = true;
  String currency = '';
  String _paymentMethodId;

  void _placeOrder() async {
    await Common.getPositionInfo().then((onValue) {
      try {
        widget.cart['position'] = onValue;
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });

    _orderInfo();
  }

  getPaymentMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
    if (mounted) {
      setState(() {
        isPaymentMethodLoading = true;
      });
    }
    if (widget.paymentMethods == null || widget.paymentMethods.length == 0) {
      if (mounted) {
        setState(() {
          paymentMethodList = [];
          paymentMethodAvaiilableCon = true;
          isPaymentMethodLoading = false;
        });
      }
    } else if ((widget.paymentMethods[0]['isSelected'] == false &&
            widget.paymentMethods[1]['isSelected'] == false) ||
        (widget.paymentMethods[1]['isSelected'] == false &&
            widget.paymentMethods[0]['isSelected'] == false)) {
      if (mounted) {
        setState(() {
          paymentMethodList = [];
          paymentMethodAvaiilable = false;
          paymentMethodAvaiilableCon = true;
          isPaymentMethodLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          paymentMethodList = widget.paymentMethods;
          paymentMethodAvaiilableCon = false;
          isPaymentMethodLoading = false;
        });
      }
    }
  }

  void _orderInfo() {
    if (groupValue == null) {
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(MyLocalizations.of(context).selectPaymentMethod),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(MyLocalizations.of(context).ok),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      widget.cart['paymentOption'] = paymentMethodList[groupValue]['type'];
      if (widget.cart['paymentOption'] == 'STRIPE') {
        StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
            .then((pm) {
          setState(() {
            _paymentMethodId = pm.id;

            widget.cart['createdAtTime'] =
                DateTime.now().millisecondsSinceEpoch;
            widget.cart['restaurant'] =
                widget.cart['productDetails'][0]['restaurant'];
            widget.cart['restaurantID'] =
                widget.cart['productDetails'][0]['restaurantID'];
            widget.cart['paymentMethodId'] = _paymentMethodId;

            if (mounted) {
              setState(() {
                isPlaceOrderLoading = true;
              });
            }
            ProfileService.placeOrder(widget.cart).then((onValue) {
              if (mounted) {
                setState(() {
                  isPlaceOrderLoading = false;
                });
              }
              if (onValue['statusCode'] == 200) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ThankYou(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues),
                    ),
                    (Route<dynamic> route) => route.isFirst);
              } else {
                showAlertMessageCardError(onValue['message']);
              }
            });
          });
        }).catchError((e) {
          showAlertMessageCardError(e.toString());
        });
      } else if (widget.cart['paymentOption'] == 'COD') {
        widget.cart['createdAtTime'] = DateTime.now().millisecondsSinceEpoch;
        widget.cart['restaurant'] =
            widget.cart['productDetails'][0]['restaurant'];
        widget.cart['restaurantID'] =
            widget.cart['productDetails'][0]['restaurantID'];
        widget.cart['paymentMethodId'] = null;
        if (mounted) {
          setState(() {
            isPlaceOrderLoading = true;
          });
        }
        Map<String, dynamic> cart = widget.cart;
        cart['productDetails'].map((product) {
          product.remove('product');
          if (product['flavour'] != null) {
            product['flavour'].map((flavour) {
              flavour.remove('tempQuantity');
            }).toList();
          }
        }).toList();
        ProfileService.placeOrder(widget.cart).then((onValue) {
          if (mounted) {
            setState(() {
              isPlaceOrderLoading = false;
            });
          }
          if (onValue['statusCode'] == 200) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ThankYou(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues),
                ),
                (Route<dynamic> route) => route.isFirst);
          } else {
            showAlertMessageCardError(onValue['message']);
          }
        });
      }
    }
  }

  void showAlertMessageCardError(message) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(MyLocalizations.of(context).ok.toUpperCase()),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    getPaymentMethod();
    StripePayment.setOptions(StripeOptions(
        publishableKey: STRIPE_KEY,
        merchantId: "Test",
        androidPayMode: 'test'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteTextb,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: new Text(
          MyLocalizations.of(context).paymentMethod,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
      ),
      body: isPaymentMethodLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: PRIMARY,
              ),
            )
          : _buildPaymentMethodSelector(),
      bottomNavigationBar:
          (!isPaymentMethodLoading && !paymentMethodAvaiilableCon)
              ? InkWell(
                  onTap: _placeOrder,
                  child: Container(
                    height: 78.0,
                    color: PRIMARY,
                    child: isPlaceOrderLoading
                        ? Image.asset(
                            'lib/assets/icon/spinner.gif',
                            width: 10.0,
                            height: 10.0,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(top: 10.0)),
                              Text(
                                MyLocalizations.of(context).placeOrderNow,
                                style: subTitleWhiteLightOSR(),
                              ),
                              Padding(padding: EdgeInsets.only(top: 5.0)),
                              Text(
                                MyLocalizations.of(context).total +
                                    ': $currency ${widget.cart['grandTotal'].toStringAsFixed(2)}',
                                style: titleWhiteBoldOSB(),
                              ),
                            ],
                          ),
                  ),
                )
              : Container(
                  child: Text(""),
                ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return ((paymentMethodList?.length ?? 0) > 0)
        ? SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(right: 0.0),
                  itemCount: paymentMethodList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return paymentMethodList[index]['isSelected'] == true
                        ? Container(
                            margin: EdgeInsets.all(8.0),
                            color: Colors.white,
                            child: RadioListTile(
                              value: index,
                              groupValue: groupValue,
                              selected: paymentMethodList[index]['isSelected'],
                              onChanged: (int selected) {
                                if (mounted) {
                                  setState(() {
                                    groupValue = selected;
                                    widget.cart['paymentOption'] =
                                        paymentMethodList[index]['type'];
                                  });
                                }
                              },
                              activeColor: PRIMARY,
                              title: Text(
                                paymentMethodList[index]['type'] == "COD"
                                    ? MyLocalizations.of(context).cod
                                    : paymentMethodList[index]['type'] ==
                                            "STRIPE"
                                        ? MyLocalizations.of(context).addCard
                                        : paymentMethodList[index]['type'],
                                style: TextStyle(color: PRIMARY),
                              ),
                              secondary:
                                  paymentMethodList[index]['type'] == "COD"
                                      ? Text(
                                          currency,
                                          style: TextStyle(
                                              fontSize: 16.0, color: PRIMARY),
                                        )
                                      : Icon(
                                          Icons.credit_card,
                                          color: PRIMARY,
                                          size: 16.0,
                                        ),
                            ),
                          )
                        : Container();
                  },
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(60),
            child: NoData(
              message: MyLocalizations.of(context).noPaymentMethods,
              icon: Icons.hourglass_empty,
            ),
          );
  }
}
