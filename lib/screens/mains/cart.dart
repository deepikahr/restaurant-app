import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/common.dart';
import '../../services/counter-service.dart';
import '../../services/localizations.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';
import '../auth/login.dart';
import '../other/coupons-list.dart';
import 'confirm-order.dart';

SentryError sentryError = new SentryError();

// ignore: must_be_immutable
class CartPage extends StatefulWidget {
  Map<String, dynamic> product, taxInfo, locationInfo;
  final Map localizedValues;
  final String locale;
  final Map<String, dynamic> tableInfo;

  CartPage(
      {Key key,
      this.product,
      this.taxInfo,
      this.locationInfo,
      this.tableInfo,
      this.locale,
      this.localizedValues})
      : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double deliveryCharge = 0.0, subTotal = 0.0, grandTotal = 0.0;
  double tax = 0.0;
  List<dynamic> products;
  Map<String, dynamic> cartItems = {};
  int productsLength = 0;
  Map<String, dynamic> selectedCoupon;
  double couponDeduction = 0.0;
  String currency = '';

  @override
  void initState() {
    _calculateCart();

    getGlobalSettingsData();
    super.initState();
    // selectedLanguage();
  }

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  void _calculateCart() async {
    // [0] other options when opening cart from menu
    if (widget.taxInfo == null) {
      await Common.getCartInfo().then((onValue) {
        if (onValue != null) {
          widget.taxInfo = onValue['taxInfo'];
          widget.locationInfo = onValue['locationInfo'];
        }
      });
    } else {
      Map<String, dynamic> cartInfo = {
        'taxInfo': widget.taxInfo,
        'locationInfo': widget.locationInfo
      };
      await Common.setCartInfo(cartInfo).then((onValue) {});
    }

    // [1] retrive cart from storage if available
    Map<String, dynamic> cart = cartItems;
    await Common.getCart().then((onValue) {
      cart = onValue;
    });

    await Common.getProducts().then((value) {
      products = value != null ? value : [];
    });

    subTotal = 0.0;
    for (int i = 0; i < products.length; i++) {
      subTotal = subTotal + products[i]['totalPrice'];
    }

    // [3.1] calculate coupon deduction if applied
    if (selectedCoupon != null) {
      couponDeduction = (subTotal * selectedCoupon['offPrecentage'] / 100);
      subTotal = subTotal - couponDeduction;
    }

    // [4] calculate tax
    if (widget.taxInfo != null) {
      tax = (subTotal * (widget.taxInfo['taxRate'] / 100));
    }

    // [5] calculate delivery charge
    Map<String, dynamic> deliveryInfo = (widget.locationInfo != null &&
            widget.locationInfo['deliveryInfo'] != null)
        ? widget.locationInfo['deliveryInfo']['deliveryInfo']
        : null;
    if (deliveryInfo != null) {
      if (!deliveryInfo['freeDelivery']) {
        if (deliveryInfo['amountEligibility'] <= subTotal) {
          deliveryCharge = 0.0;
        } else {
          deliveryCharge =
              double.parse(deliveryInfo['deliveryCharges'].toString());
        }
      } else {
        deliveryCharge = 0.0;
      }
    } else {
      deliveryCharge = 0.0;
    }

    // [6] calculate grand total
    grandTotal = subTotal + deliveryCharge + tax;

    // [7] create complete order json as Map
    if (products.length != 0) {
      cart = {
        'deliveryCharge': deliveryCharge,
        'grandTotal': grandTotal,
        'location':
            widget.locationInfo != null ? widget.locationInfo['_id'] : null,
        'locationName': widget.locationInfo != null
            ? widget.locationInfo['locationName']
            : null,
        'orderType': 'Delivery',
        'payableAmount': grandTotal,
        'paymentOption': 'COD',
        'position': null,
        'loyalty': null,
        'shippingAddress': null,
        'restaurant': products.length > 0 ? products[0]['restaurant'] : null,
        'restaurantID':
            products.length > 0 ? products[0]['restaurantID'] : null,
        'status': 'Pending',
        'subTotal': subTotal,
        // "taxInfo": {"taxRate": 0, "taxName": "nil"},
        'taxInfo': widget.taxInfo,
        'productDetails': products,
        'note': null,
        'isForDineIn': false,
        'pickupDate': null,
        'pickupTime': null,
        'coupon': selectedCoupon == null
            ? {'couponApplied': false}
            : {
                'couponApplied': true,
                'couponName': selectedCoupon['couponName']
              }
      };
    }

    // [8] set cart state and save to storage
    if (widget.locationInfo != null) {
      await Common.setCart(cart);
      if (mounted) {
        setState(() {
          cartItems = cart;
          productsLength = products.length;
        });
      }
    }
  }

  void _goToCoupons() async {
    selectedCoupon = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CouponsList(
          locationId: cartItems['location'],
          locale: widget.locale,
          localizedValues: widget.localizedValues,
        ),
      ),
    );

    _calculateCart();
  }

  int cartCount;

  @override
  Widget build(BuildContext context) {
    if (widget.taxInfo != null && widget.taxInfo['taxName'] == null) {
      widget.taxInfo['taxName'] = '';
    }
    CounterService().getCounter().then((res) {
      if (mounted) {
        setState(() {
          cartCount = res;
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: new Text(
          MyLocalizations.of(context).getLocalizations("CART"),
          style: titleBoldWhiteOSS(),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: productsLength > 0
          ? SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Container(
                            height: screenHeight(context) * 0.42,
                            color: greyc,
                            padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                            child: _buildCartItemTile(products)),
                      ),
                      Divider(),
                      _buildApplyCouponLine(),
                      selectedCoupon != null ? Divider() : Container(),
                      selectedCoupon != null
                          ? _buildPriceTagLine(
                              'Coupon (' +
                                  selectedCoupon['couponName'] +
                                  ' - ' +
                                  selectedCoupon['offPrecentage'].toString() +
                                  '% off)',
                              couponDeduction)
                          : Container(),
                      Divider(),
                      _buildPriceTagLine(
                          MyLocalizations.of(context)
                              .getLocalizations("SUB_TOTAL"),
                          subTotal),
                      Divider(),
                      widget.taxInfo != null
                          ? _buildPriceTagLine(
                              "Tax " + widget.taxInfo['taxName'], tax)
                          : Container(height: 0, width: 0),
                      widget.taxInfo != null
                          ? Divider()
                          : Container(height: 0, width: 0),
                      _buildPriceTagLine(
                          MyLocalizations.of(context)
                              .getLocalizations("DELIVERY_CHARGES"),
                          deliveryCharge),
                      Divider(),
                      _buildPriceTagLine(
                          MyLocalizations.of(context).getLocalizations("TOTAL"),
                          grandTotal),
                      Divider(),
                    ],
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: NoData(
                message:
                    MyLocalizations.of(context).getLocalizations("CART_EMPTY"),
                icon: Icons.hourglass_empty,
              ),
            ),
      bottomNavigationBar: productsLength > 0
          ? _buildBottomBar()
          : Container(
              height: 0,
              width: 0,
            ),
    );
  }

  Widget _buildCartItemTile(List<dynamic> products) {
    return ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.all(5),
            // color: Colors.grey,
            child: Container(
              color: greyc,
              child: Padding(
                padding: EdgeInsets.only(left: 5, top: 5),
                child: Column(
                  children: [
                    Text(
                      products[index]['title'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: subTitleDarkLightOSS(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        products[index]['size'].length > 30
                            ? Text(
                                products[index]['Quantity'].toString() +
                                    'x ' +
                                    products[index]['size'].substring(0, 28) +
                                    "... ",
                                textAlign: TextAlign.center,
                                style: hintStylePrimaryOSR(),
                              )
                            : Text(
                                products[index]['Quantity'].toString() +
                                    'x ' +
                                    products[index]['size'],
                                textAlign: TextAlign.center,
                                style: hintStylePrimaryOSR(),
                              ),
                        Text(
                          '$currency' +
                              products[index]['price'].toStringAsFixed(2),
                          style: titleBlackBoldOSB(),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: PRIMARY,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            if (products.length == 1) {
                              Common.addProduct(null);
                              CounterService().calculateCounter();
                              Common.setCart(null);
                              setState(() {});
                              _calculateCart();
                            } else {
                              products.removeAt(index);
                              Common.addProduct(products);
                              CounterService().calculateCounter();
                              _calculateCart();
                            }
                          },
                        ),
                      ],
                    ),
                    // products[index]['extraIngredients'].length == 0
                    //     ? Container()
                    //     : new Text(
                    //         'Selected ${products[index]['extraIngredients'].length} Extra Items',
                    //         overflow: TextOverflow.ellipsis,
                    //         style: subTitleDarkLightOSS(),
                    //       ),
                    products[index]['extraIngredients'].length == 0
                        ? Container()
                        : _buildCartExtraItemTile(
                            products[index]['extraIngredients']),
                    _buildAddNoteLine(index),
                    Divider()
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCartExtraItemTile(List<dynamic> extraIngredients) {
    return ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: extraIngredients.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              width: screenWidth(context),
              padding: EdgeInsets.only(left: 50.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: new Text(
                        extraIngredients[index]['name'].length > 15
                            ? extraIngredients[index]['name'].substring(0, 15) +
                                '...'
                            : extraIngredients[index]['name'],
                        overflow: TextOverflow.ellipsis,
                        style: hintStylePrimaryLightOSR(),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: new Text(
                          'x' + '1',
                          textAlign: TextAlign.center,
                          style: hintStylePrimaryOSR(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: new Text(
                        '$currency' +
                            extraIngredients[index]['price'].toStringAsFixed(2),
                        //  style: darkTextSmallHN(),
                      ),
                    ),
                  ]));
        });
  }

  Widget _buildPriceTagLine(String title, double value) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: titleBlackLightOSB(),
          ),
          new Text(
            '$currency' + value.toStringAsFixed(2),
            style: textPrimaryOSR(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return GestureDetector(
      onTap: _checkLoginAndNavigate,
      child: new Container(
        height: 70.0,
        color: PRIMARY,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              MyLocalizations.of(context).getLocalizations("COMPLETE_ORDER"),
              style: subTitleWhiteLightOSR(),
            ),
            new Padding(padding: EdgeInsets.only(top: 5.0)),
            new Text(
              // //delivery charge deducted because of above line are commented to disable delivery charge in this page
              MyLocalizations.of(context).getLocalizations("TOTAL") +
                  ': $currency' +
                  (grandTotal - deliveryCharge).toStringAsFixed(2),
              style: titleWhiteBoldOSB(),
            )
          ],
        ),
      ),
    );
  }

  void _checkLoginAndNavigate() async {
    Common.getToken().then((onValue) async {
      String msg;
      if (onValue == null) {
        msg = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(
                    locale: widget.locale,
                    localizedValues: widget.localizedValues,
                  )),
        );
      } else {
        msg = 'Success';
      }
      if (msg == 'Success' && mounted) {
        var info = (widget.locationInfo != null &&
                widget.locationInfo['deliveryInfo'] != null)
            ? widget.locationInfo['deliveryInfo']['deliveryInfo']
            : null;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ConfrimOrderPage(
                locale: widget.locale,
                localizedValues: widget.localizedValues,
                cart: cartItems,
                deliveryInfo: info,
                currency: currency),
          ),
        );
      }
    });
  }

  Widget _buildAddNoteLine(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            _showAddNoteAlert(index);
          },
          child: Text(
            MyLocalizations.of(context).getLocalizations("ADD_NOTE"),
            style: titleBlackLightOSBCoupon(),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 10)),
        cartItems['productDetails'][index]['note'] != null
            ? InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      cartItems['productDetails'][index]['note'] = null;
                      Common.setCart(cartItems);
                    });
                    _calculateCart();
                  }
                },
                child: Icon(
                  Icons.cancel,
                  size: 18,
                  color: Colors.red,
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildApplyCouponLine() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: _goToCoupons,
          child: Text(
            MyLocalizations.of(context).getLocalizations("APPLY_COUPON"),
            style: titleBlackLightOSBCoupon(),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 10)),
        selectedCoupon != null
            ? InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      selectedCoupon = null;
                    });
                    _calculateCart();
                  }
                },
                child: Icon(
                  Icons.cancel,
                  size: 18,
                  color: Colors.red,
                ),
              )
            : Container(),
      ],
    );
  }

  Future<void> _showAddNoteAlert(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(MyLocalizations.of(context).getLocalizations("COOK_NOTE")),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    initialValue: cartItems['productDetails'][index]['note'],
                    validator: (String value) {
                      if (value.isEmpty) {
                        return MyLocalizations.of(context)
                            .getLocalizations("PLEASE_ENTER");
                      } else
                        return null;
                    },
                    onSaved: (String value) {
                      if (mounted) {
                        setState(() {
                          cartItems['productDetails'][index]['note'] = value;
                          Common.setCart(cartItems);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText:
                          MyLocalizations.of(context).getLocalizations("NOTE"),
                      labelStyle: hintStyleGreyLightOSR(),
                      contentPadding: EdgeInsets.all(10),
                      // border: InputBorder.,
                    ),
                    style: textBlackOSR(),
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child:
                  Text(MyLocalizations.of(context).getLocalizations("CANCEL")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(MyLocalizations.of(context).getLocalizations("ADD")),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _calculateCart();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
