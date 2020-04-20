import 'package:RestaurantSaas/screens/mains/add-card.dart';
import 'package:RestaurantSaas/widgets/no-data.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../other/thank-you.dart';
import '../../services/profile-service.dart';
import '../../services/common.dart';
import '../../services/sentry-services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class PaymentMethod extends StatefulWidget {
  final Map<String, dynamic> cart, paymentMethods;
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
  int selectedPaymentIndex = 0;
  bool isLoading = false;
  List cardList;
  int groupValue, cvv;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isCardListLoading = false;
  bool isPaymentMethodLoading = false;
  List<dynamic> paymentMethodList;
  bool paymentMethodAvaiilable = true, paymentMethodAvaiilableCon = true;

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
    if (widget.cart['paymentOption'] == 'RazorPay') {
      // // Map<String, String> notesr= {'orderInfo': json.encode(widget.cart)};
      // Map<String, String> options = {
      //   'name': widget.cart['restaurant'],
      //   'currency': 'USD',
      //   'display_currency': 'USD',
      //   'image': 'https://www.73lines.com/web/image/12427',
      //   'description': 'Order Placed from ' + APP_NAME,
      //   'amount': (100 * widget.cart['grandTotal']).toStringAsFixed(2),
      //   'email': widget.cart['shippingAddress']['contactNumber'].toString(),
      //   'contact': widget.cart['shippingAddress']['contactNumber'].toString(),
      //   'theme': '#FF0000',
      //   'api_key': 'rzp_test_HjcXUWgYjGPIf9',
      //   // 'notes': notes.toString()
      // };
      // Map<dynamic, dynamic> paymentResponse =
      //     await Razorpay.showPaymentForm(options);
      // widget.cart['payment'] = {'paymentStatus': true};
      // widget.cart['paymentStatus'] = 'Success';
      // if (paymentResponse['code'] == 1) {
      //   _orderInfo();
      // }
    } else {
      _orderInfo();
    }
  }

  fetchCardInfo() async {
    if (mounted) {
      setState(() {
        isCardListLoading = true;
      });
    }
    await ProfileService.getCardList().then((onValue) {
      try {
        if (mounted) {
          setState(() {
            cardList = onValue;
          });
        }
        if (mounted) {
          setState(() {
            isCardListLoading = false;
          });
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  getPaymentMethod() async {
    if (widget.paymentMethods['message'] == "No setting data found") {
      if (mounted) {
        setState(() {
          paymentMethodList = [];
          paymentMethodAvaiilableCon = true;
        });
      }
    } else {
      if (widget.paymentMethods['message'] == null ||
          widget.paymentMethods['message'] == "") {
        if (widget.paymentMethods['restaurantID']['paymentMethod'].length ==
                0 ||
            widget.paymentMethods['restaurantID']['paymentMethod'] == []) {
          if (mounted) {
            setState(() {
              paymentMethodList = [];
              paymentMethodAvaiilableCon = true;
              paymentMethodAvaiilable = false;
            });
          }
        } else if (widget.paymentMethods['restaurantID']['paymentMethod'][0]
                    ['isSelected'] ==
                false &&
            widget.paymentMethods['restaurantID']['paymentMethod'][1]
                    ['isSelected'] ==
                false) {
          if (mounted) {
            setState(() {
              paymentMethodList = [];
              paymentMethodAvaiilable = false;
              paymentMethodAvaiilableCon = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              paymentMethodList =
                  widget.paymentMethods['restaurantID']['paymentMethod'];
              paymentMethodAvaiilableCon = false;
            });
          }
          if (mounted) {
            setState(() {});
          }
        }
      }
    }
  }

  void _orderInfo() {
    widget.cart['createdAtTime'] = DateTime.now().millisecondsSinceEpoch;
    widget.cart['restaurant'] = widget.cart['productDetails'][0]['restaurant'];
    widget.cart['restaurant'] = widget.cart['productDetails'][0]['restaurant'];
    widget.cart['restaurantID'] =
        widget.cart['productDetails'][0]['restaurantID'];
    ProfileService.placeOrder(widget.cart).then((onValue) {
      try {
        if (onValue != null && onValue['message'] != null) {
          if (widget.cart['paymentOption'] == 'CREDIT CARD') {
            Map<String, dynamic> body = {
              "cardId": cardList[groupValue]['_id'],
              "cardCvv": cvv,
              "orderId": onValue['_id']
            };

            ProfileService.placeOrderForCreditCard(body).then((res) {
              try {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }

                if (res['response_code'] == 400) {
                  showAlertMessage(res['message']);
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ThankYou(
                                locale: widget.locale,
                                localizedValues: widget.localizedValues,
                              )),
                      (Route<dynamic> route) => route.isFirst);
                }
              } catch (error, stackTrace) {
                sentryError.reportError(error, stackTrace);
              }
            }).catchError((onError) {
              sentryError.reportError(onError, null);
            });
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ThankYou(
                          localizedValues: widget.localizedValues,
                          locale: widget.locale,
                        )),
                (Route<dynamic> route) => route.isFirst);
          }
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  @override
  void initState() {
    getPaymentMethod();
    Common.getPositionInfo().then((onValue) {
      widget.cart['position'] = onValue;
    });
    fetchCardInfo();
    super.initState();
    getGlobalSettingsData();
  }

  String currency = '';

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
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
          style: titleBoldWhiteOSS(),
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
              ? Container(
                  height: 78.0,
                  color: PRIMARY,
                  child: isLoading
                      ? Image.asset(
                          'lib/assets/icon/spinner.gif',
                          width: 10.0,
                          height: 10.0,
                        )
                      : GestureDetector(
                          onTap: () {
                            if (!isLoading) {
                              if (mounted) {
                                setState(() {
                                  isLoading = true;
                                });
                                _placeOrder();
                              }
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Padding(padding: EdgeInsets.only(top: 10.0)),
                              new Text(
                                MyLocalizations.of(context).placeOrderNow,
                                style: subTitleWhiteLightOSR(),
                              ),
                              new Padding(padding: EdgeInsets.only(top: 5.0)),
                              new Text(
                                MyLocalizations.of(context).total +
                                    ': \$ ${widget.cart['grandTotal'].toStringAsFixed(2)}',
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
    return paymentMethodList.length > 0
        ? SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(right: 0.0),
                  itemCount: paymentMethodList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (paymentMethodList[index]['isSelected']) {
                      paymentMethodAvaiilable = true;
                    } else {
                      paymentMethodAvaiilable = false;
                    }
                    if (paymentMethodList[index]['isBoxSelected'] == null) {
                      if (index == 0) {
                        paymentMethodList[0]['isBoxSelected'] = true;
                      } else {
                        paymentMethodList[index]['isBoxSelected'] = true;
                      }
                    }
                    return paymentMethodList[index]['isSelected'] == true
                        ? Container(
                            margin: EdgeInsets.all(8.0),
                            color: Colors.white,
                            child: RadioListTile(
                                value: index,
                                groupValue: selectedPaymentIndex,
                                selected: paymentMethodList[index]
                                    ['isBoxSelected'],
                                onChanged: (int selected) {
                                  if (!isLoading) {
                                    if (paymentMethodList[index]['type'] ==
                                        'COD') {
                                      groupValue = null;
                                    }
                                    setState(() {
                                      selectedPaymentIndex = selected;
                                      paymentMethodList[index]
                                              ['isBoxSelected'] =
                                          !paymentMethodList[index]
                                              ['isBoxSelected'];
                                      widget.cart['paymentOption'] =
                                          paymentMethodList[index]['type'];
                                    });
                                  }
                                },
                                activeColor: PRIMARY,
                                title: Text(
                                  paymentMethodList[index]['type'],
                                  style: TextStyle(color: PRIMARY),
                                ),
                                secondary:
                                    paymentMethodList[index]['type'] == "COD"
                                        ? Icon(
                                            Icons.attach_money,
                                            color: PRIMARY,
                                            size: 16.0,
                                          )
                                        : Icon(
                                            Icons.credit_card,
                                            color: PRIMARY,
                                            size: 16.0,
                                          )),
                          )
                        : Container();
                  },
                ),
                widget.cart['paymentOption'] == 'CREDIT CARD'
                    ? paymentMethod()
                    : Container(),
                widget.cart['paymentOption'] == 'CREDIT CARD'
                    ? buildSaveCardInfo()
                    : Container(),
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
    // Container(
    //   child: Column(
    //     children: <Widget>[
    //       Container(
    //         margin: EdgeInsets.all(8.0),
    //         color: Colors.white,
    //         child: RadioListTile(
    //           value: 0,
    //           groupValue: selectedPaymentIndex,
    //           selected: true,
    //           onChanged: (int selected) {
    //             if (!isLoading) {
    //               setState(() {
    //                 selectedPaymentIndex = selected;

    //                 widget.cart['paymentOption'] = "COD";
    //               });
    //             }
    //           },
    //           activeColor: PRIMARY,
    //           title: Text(
    //             "COD",
    //             style: TextStyle(color: PRIMARY),
    //           ),
    //           secondary: Icon(
    //             Icons.attach_money,
    //             color: PRIMARY,
    //             size: 16.0,
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  Widget paymentMethod() {
    return isCardListLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            margin: EdgeInsetsDirectional.only(top: 10.0),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 4.0)
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: new Text(
                    MyLocalizations.of(context).selectCard,
                    style: textBlackOSR(),
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    var result = Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (BuildContext context) => new AddCardPage(
                            localizedValues: widget.localizedValues,
                            locale: widget.locale,
                          ),
                        ));

                    // if (result != null) {
                    result.then((onValue) {
                      fetchCardInfo();

                      if (mounted) {
                        setState(() {
                          // cardList.add(onValue);
                          cardList = cardList;
                        });
                      }
                    });
                    // }
                  },
                  child: new Text(
                    MyLocalizations.of(context).addCard,
                    // style: normaltitleStyle(),
                  ),
                ),
              ],
            ),
          );
  }

  Widget buildSaveCardInfo() {
    return cardList.length == 0
        ? NoData(
            message: MyLocalizations.of(context).noSavedCardsPleaseaddone + '!',
            icon: Icons.no_sim,
          )
        : ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: cardList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(children: [
                RadioListTile(
                  value: index,
                  groupValue: groupValue,
                  onChanged: (int value) {
                    showDialog<Null>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return new AlertDialog(
                            title: new Text(
                                MyLocalizations.of(context).pleaseEnterCVV),
                            content: new SingleChildScrollView(
                              child: new ListBody(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 14.0),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: greyc, width: 1.0),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Form(
                                          key: _formKey,
                                          child: Flexible(
                                            fit: FlexFit.tight,
                                            flex: 9,
                                            child: TextFormField(
                                              decoration: new InputDecoration(
                                                hintText:
                                                    MyLocalizations.of(context)
                                                        .cvv,
                                                // hintStyle: greySmallTextHN(),
                                                contentPadding:
                                                    EdgeInsets.all(12.0),
                                                border: InputBorder.none,
                                              ),
                                              // style: darkTextSmallHN(),
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (String value) {
                                                if (value.length != 3)
                                                  return MyLocalizations.of(
                                                          context)
                                                      .cVVmustbeof3digits;
                                                else
                                                  return null;
                                              },
                                              onSaved: (String value) {
                                                if (mounted) {
                                                  setState(() {
                                                    cvv = int.parse(value);
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex: 1,
                                          child: Icon(
                                            Icons.credit_card,
                                            color: Colors.blueGrey,
                                            size: 16.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: new Text(
                                    MyLocalizations.of(context).cancel),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: new Text(MyLocalizations.of(context).ok),
                                onPressed: () {
                                  final FormState formState =
                                      _formKey.currentState;
                                  if (formState.validate()) {
                                    formState.save();
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          );
                        });
                    setState(
                      () {
                        groupValue = value;
                      },
                    );
                  },
                  activeColor: PRIMARY,
                  title: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.all(5.0)),
                      Expanded(
                          child: new Text(
                        cardList != null && cardList.length > 0
                            ? cardList[index]['cardNumberDisp'] ?? ''
                            : '',
                        // style: hintStyleBlackSmallPNR(),
                      )),
                    ],
                  ),
                ),
                Divider(
                  color: border.withOpacity(0.2),
                  height: 16.0,
                ),
              ]);
            });
  }

  void showAlertMessage(message) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(MyLocalizations.of(context).paymentFailed),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message),
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
        });
  }

  void showAlert() {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(MyLocalizations.of(context).paymentFailed),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(MyLocalizations.of(context)
                          .yourordercancelledPleasetryagain +
                      '!'),
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
        });
  }
}
