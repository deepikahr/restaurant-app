import 'dart:async';
import 'package:RestaurantSaas/screens/products/bottom-sheet1.dart';
import 'package:RestaurantSaas/services/main-service.dart';
import 'package:RestaurantSaas/services/profile-service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/common.dart';
import '../../../services/counter-service.dart';
import '../../../services/localizations.dart';
import '../../../services/sentry-services.dart';
import '../../../styles/styles.dart';
import '../../../widgets/no-data.dart';
import '../../auth/login.dart';
import 'coupons-list.dart';
import 'confirm-order.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';

SentryError sentryError = new SentryError();

// ignore: must_be_immutable
class CartPage extends StatefulWidget {
  Map<String, dynamic> product, taxInfo, locationInfo;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  final Map<String, dynamic> tableInfo;
  final Function listener;

  CartPage(
      {Key key,
      this.product,
      this.taxInfo,
      this.locationInfo,
      this.tableInfo,
      this.locale,
      this.localizedValues,
      this.listener})
      : super(key: key);

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double deliveryCharge = 0.0, subTotal = 0.0, grandTotal = 0.0;
  double tax = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int deliveryCharge1, minimumOrderAmount;
  List<dynamic> products;
  Map<String, dynamic> cartItems = {};
  int productsLength = 0;
  Map<String, dynamic> selectedCoupon;
  double couponDeduction = 0.0;
  String currency = '', shippingType;

  bool isLoading = true;

  @override
  void initState() {
    calculateCart();
    getGlobalSettingsData();
    super.initState();
  }

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  showFlavourOptionDialog(title, product) async {
    showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            top: 10.0,
          ),
          title: new Text(
            "$title",
            style: titleBlackLightOSB(),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Divider(),
                  IntrinsicHeight(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              calculatePrice(product, true, addFlavours: true);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(bottom: 12.0),
                              height: 30.0,
                              decoration: BoxDecoration(),
                              child: Text(
                                MyLocalizations.of(context).same.toUpperCase(),
                                style: textprimaryOSR(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              _showBottomSheet(product);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(bottom: 12.0),
                              height: 30.0,
                              decoration: BoxDecoration(),
                              child: Text(
                                MyLocalizations.of(context)
                                    .different
                                    .toUpperCase(),
                                style: textprimaryOSR(),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void calculateCart() async {
    setState(() {
      isLoading = true;
    });
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
    }).catchError((onError) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    await Common.getProducts().then((value) {
      products = value != null ? value : [];
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

    // [5] calculate delivery charge
    await ProfileService.getUserInfo().then((value) async {
      await MainService.getProductsBylocationId(cart['locationId'])
          .then((locationId) async {
        if (value['newUser'] &&
            locationId['restaurant']['restaurantID']['firstDeliveryFree']) {
          deliveryCharge = 0;
          grandTotal = subTotal + deliveryCharge;
        } else {
          await Common.getDeliveryCharge().then((value) {
            shippingType = value['shippingType'];
            deliveryCharge1 = value['deliveryCharge'];
            minimumOrderAmount = value['minimumOrderAmount'];
            if (value['shippingType'].compareTo('free') == 0) {
              deliveryCharge = 0.0;
              grandTotal = subTotal + deliveryCharge;
            } else if (value['shippingType'].compareTo('flexible') == 0) {
              if (subTotal > value['minimumOrderAmount']) {
                deliveryCharge = 0.0;
                grandTotal = subTotal + deliveryCharge + tax;
              } else {
                deliveryCharge = value['deliveryCharge'].toDouble();
                grandTotal = subTotal + deliveryCharge + tax;
              }
            } else if (value['shippingType'].compareTo('fixed') == 0) {
              deliveryCharge = value['deliveryCharge'].toDouble();
              grandTotal = subTotal + deliveryCharge + tax;
            } else {
              deliveryCharge = 0.0;
              grandTotal = subTotal + deliveryCharge + tax;
            }
          });
        }
      });
    }).catchError((value) {
      Common.getDeliveryCharge().then((value) {
        if (value != null) {
          if (value['shippingType'].compareTo('free') == 0) {
            deliveryCharge = 0.0;
            grandTotal = subTotal + deliveryCharge + tax;
          } else if (value['shippingType'].compareTo('flexible') == 0) {
            if (subTotal > value['minimumOrderAmount']) {
              deliveryCharge = 0.0;
              grandTotal = subTotal + deliveryCharge + tax;
            } else {
              deliveryCharge = value['deliveryCharge'].toDouble();
              grandTotal = subTotal + deliveryCharge + tax;
            }
          } else if (value['shippingType'].compareTo('fixed') == 0) {
            deliveryCharge = value['deliveryCharge'].toDouble();
            grandTotal = subTotal + deliveryCharge + tax;
          } else {
            deliveryCharge = 0.0;
            grandTotal = subTotal + deliveryCharge + tax;
          }
        } else {
          deliveryCharge = 0.0;
        }
      });
    });

    // [6] calculate grand total
    grandTotal = subTotal + deliveryCharge;

    // [7] create complete order json as Map
    if (products.length != 0) {
      cart = {
        'locationId': cart != null ? cart['locationId'] : null,
        'deliveryCharge': deliveryCharge.toInt(),
        'grandTotal': grandTotal,
        'location': cart['locationId'],
        'locationName': cart['locationName'],
        'orderType': 'Delivery',
        'payableAmount': grandTotal,
        'paymentOption': 'COD',
        'position': null,
        'shippingAddress': null,
        'restaurantName':
            products.length > 0 ? products[0]['restaurant'] : null,
        'restaurantID':
            products.length > 0 ? products[0]['restaurantID'] : null,
        'status': 'Pending',
        'subTotal': subTotal,
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
    if (products != null) {
      await Common.setCart(cart);
      if (mounted) {
        setState(() {
          isLoading = false;
          cartItems = cart;
          productsLength = products.length;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    if (products.toString() == [].toString()) {
      Common.setCart(null);
      Common.addProduct(null);
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

    calculateCart();
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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: appBarWithTitle(context, MyLocalizations.of(context).cart),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : productsLength > 0
              ? ListView(
                  children: <Widget>[
                    SizedBox(height: 5),
                    cartItemList(products),
                    coupon(),
                    billDetails(),
                  ],
                )
              // SingleChildScrollView(
              //     child: Stack(
              //       children: <Widget>[
              //         new Column(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           children: <Widget>[
              //             SingleChildScrollView(
              //               child: Container(
              //                   height: screenHeight(context) * 0.42,
              //                   color: greyc,
              //                   padding:
              //                       EdgeInsets.only(top: 10.0, bottom: 5.0),
              //                   child: _buildCartItemTile(products)),
              //             ),
              //             Divider(),
              //             _buildApplyCouponLine(),
              //             selectedCoupon != null ? Divider() : Container(),
              //             selectedCoupon != null
              //                 ? _buildPriceTagLine(
              //                     'Coupon (' +
              //                         selectedCoupon['couponName'] +
              //                         ' - ' +
              //                         selectedCoupon['offPrecentage']
              //                             .toString() +
              //                         '% off)',
              //                     couponDeduction)
              //                 : Container(),
              //             Divider(),
              //             _buildPriceTagLine(
              //                 MyLocalizations.of(context).subTotal, subTotal),
              //             Divider(),
              //             _buildPriceTagLine(
              //                 MyLocalizations.of(context).deliveryCharges,
              //                 deliveryCharge),
              //             Divider(),
              //             _buildPriceTagLine(
              //                 MyLocalizations.of(context).grandTotal,
              //                 grandTotal),
              //             Divider(),
              //           ],
              //         ),
              //       ],
              //     ),
              //   )
              : Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: NoData(
                    message: MyLocalizations.of(context).cartEmpty,
                    icon: Icons.hourglass_empty,
                  ),
                ),
      bottomNavigationBar: productsLength > 0
          ? Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Container(
                width: 335,
                height: 41,
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.29), blurRadius: 5)
                    ]),
                child: RaisedButton(
                    color: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
                    onPressed: _checkLoginAndNavigate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: '${MyLocalizations.of(context).total} : ',
                            style: textMuliSemiboldwhiteexs(),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      ' $currency ${grandTotal.toStringAsFixed(2)}',
                                  style: textMuliSemiboldwhite()),
                            ],
                          ),
                        ),
                        Text(
                          '${MyLocalizations.of(context).proceed}',
                          style: textMuliSemiboldwhite(),
                        ),
                      ],
                    )),
              ),
            )
          // _buildBottomBar()
          : Container(
              height: 0,
              width: 0,
            ),
    );
  }

  Widget cartItemList(List<dynamic> products) {
    return ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
              child: Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            padding: EdgeInsets.only(bottom: 10, top: 10),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: secondary.withOpacity(0.1)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        products[index]['title'],
                        style: textMuliBold(),
                      ),
                      // Text(
                      //   'Dominos',
                      //   style: textMuliSemiboldmd(),
                      // ),
                      products[index]['size'].length > 30
                          ? Text(
                              products[index]['Quantity'].toString() +
                                  'x ' +
                                  products[index]['size'].substring(0, 28) +
                                  "... ",
                              style: textMuliRegular(),
                            )
                          : Text(
                              products[index]['Quantity'].toString() +
                                  'x ' +
                                  products[index]['size'],
                              style: textMuliRegular(),
                            ),
                      products[index]['extraIngredients'].length == 0
                          ? Container()
                          : _buildCartExtraItemTile(
                              products[index]['extraIngredients']),
                      products[index]['flavour'] != null
                          ? _buildFlavourList(products[index]['flavour'])
                          : Container(),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      //  crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, right: 2),
                          child: Text(
                            currency,
                            style: textMuliRegularsm(),
                          ),
                        ),
                        Text(
                          products[index]['price'].toStringAsFixed(2),
                          style: textMuliBold(),
                        ),
                      ],
                    ),
                    Container(
                      width: 112,
                      // height: 32,
                      margin: EdgeInsets.only(left: 8, bottom: 8, top: 8),
                      decoration: BoxDecoration(
                          border: Border.all(color: primary),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            child: Icon(Icons.remove, color: primary),
                            onTap: () {
                              if (products[index]['Quantity'] <= 1) {
                                _updateProductQuantityFromCart(
                                    products[index], products[index]);
                              } else {
                                products[index]['flavour'] == null
                                    ? calculatePrice(products[index], false,
                                        decrement: true)
                                    : calculatePrice(products[index], false,
                                        removeFlavours: true);
                              }
                            },
                          ),
                          Text(
                            products[index]['Quantity'].toString(),
                            style: textMuliSemiboldsm(),
                          ),
                          InkWell(
                            child: Icon(Icons.add, color: primary),
                            onTap: () {
                              products[index]['flavour'] == null
                                  ? calculatePrice(products[index], true)
                                  : showFlavourOptionDialog(
                                      MyLocalizations.of(context)
                                          .doYouWantSameOrDifferent,
                                      products[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildAddNoteLine(index),
                  ],
                ),
              ],
            ),
          ));
        });
  }

  Widget coupon() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: bg,
      child: InkWell(
        onTap: _goToCoupons,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: <Widget>[
                  Image.asset(
                    'lib/assets/icons/sale.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  selectedCoupon != null
                      ? Text(
                          selectedCoupon['couponName'] +
                              ' - ' +
                              selectedCoupon['offPrecentage'].toString() +
                              '% OFF',
                          style: textMuliBold(),
                        )
                      : Text(
                          MyLocalizations.of(context).applyCoupon,
                          style: textMuliBold(),
                        ),
                  selectedCoupon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: InkWell(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  selectedCoupon = null;
                                });
                                calculateCart();
                              }
                            },
                            child: Icon(
                              Icons.cancel,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              selectedCoupon != null
                  ? Text(
                      '$currency' + couponDeduction.toStringAsFixed(2),
                      style: textMuliBold(),
                    )
                  : Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 16,
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget billDetails() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 12),
          priceTagLine(MyLocalizations.of(context).subTotal, subTotal),
          SizedBox(height: 9),
          priceTagLine(
              MyLocalizations.of(context).deliveryCharges, deliveryCharge),
          Divider(color: secondary.withOpacity(0.1), thickness: 1, height: 22),
          priceTagLine(MyLocalizations.of(context).grandTotal, grandTotal),
        ],
      ),
    );
  }

  // Widget _buildCartItemTile(List<dynamic> products) {
  //   return ListView.builder(
  //       physics: ScrollPhysics(),
  //       shrinkWrap: true,
  //       itemCount: products.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Container(
  //           padding: EdgeInsets.all(5),
  //           // color: Colors.grey,
  //           child: Container(
  //             color: greyc,
  //             child: Padding(
  //               padding: EdgeInsets.only(left: 5, top: 5),
  //               child: Column(
  //                 children: [
  //                   Text(
  //                     products[index]['title'],
  //                     overflow: TextOverflow.ellipsis,
  //                     maxLines: 2,
  //                     style: subTitleDarkLightOSS(),
  //                   ),
  //                   Row(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: <Widget>[
  //                       products[index]['size'].length > 30
  //                           ? Text(
  //                               products[index]['Quantity'].toString() +
  //                                   'x ' +
  //                                   products[index]['size'].substring(0, 28) +
  //                                   "... ",
  //                               textAlign: TextAlign.center,
  //                               style: hintStyleprimaryOSR(),
  //                             )
  //                           : Text(
  //                               products[index]['Quantity'].toString() +
  //                                   'x ' +
  //                                   products[index]['size'],
  //                               textAlign: TextAlign.center,
  //                               style: hintStyleprimaryOSR(),
  //                             ),
  //                       Text(
  //                         '$currency' +
  //                             products[index]['price'].toStringAsFixed(2),
  //                         style: titleBlackBoldOSB(),
  //                       ),
  //                       Row(
  //                         children: [
  //                           Container(
  //                             decoration: BoxDecoration(
  //                                 color: Colors.grey[300],
  //                                 borderRadius: BorderRadius.circular(15.0)),
  //                             height: 30,
  //                             width: 100,
  //                             child: Row(
  //                               children: <Widget>[
  //                                 Container(
  //                                   width: 24,
  //                                   height: 24,
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.black,
  //                                     borderRadius: BorderRadius.circular(20.0),
  //                                   ),
  //                                   child: InkWell(
  //                                     onTap: () {
  //                                       if (products[index]['Quantity'] <= 1) {
  //                                         _updateProductQuantityFromCart(
  //                                             products[index], products[index]);
  //                                       } else {
  //                                         products[index]['flavour'] == null
  //                                             ? calculatePrice(
  //                                                 products[index], false,
  //                                                 decrement: true)
  //                                             : calculatePrice(
  //                                                 products[index], false,
  //                                                 removeFlavours: true);
  //                                       }
  //                                     },
  //                                     child: Icon(
  //                                       Icons.remove,
  //                                       color: primary,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(
  //                                       left: 20.0, right: 20),
  //                                   child: Container(
  //                                       child: Text(products[index]['Quantity']
  //                                           .toString())),
  //                                 ),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(left: 0.0),
  //                                   child: Container(
  //                                     width: 24,
  //                                     height: 24,
  //                                     decoration: BoxDecoration(
  //                                       color: primary,
  //                                       borderRadius:
  //                                           BorderRadius.circular(15.0),
  //                                     ),
  //                                     child: InkWell(
  //                                       onTap: () {
  //                                         products[index]['flavour'] == null
  //                                             ? calculatePrice(
  //                                                 products[index], true)
  //                                             : showFlavourOptionDialog(
  //                                                 MyLocalizations.of(context)
  //                                                     .doYouWantSameOrDifferent,
  //                                                 products[index]);
  //                                       },
  //                                       child: Icon(Icons.add),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   products[index]['extraIngredients'].length == 0
  //                       ? Container()
  //                       : _buildCartExtraItemTile(
  //                           products[index]['extraIngredients']),
  //                   products[index]['flavour'] != null
  //                       ? _buildFlavourList(products[index]['flavour'])
  //                       : Container(),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   _buildAddNoteLine(index),
  //                   Divider()
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

  void _showBottomSheet(product) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return BottomSheetClassDryClean(
            shippingType: shippingType,
            deliveryCharge: deliveryCharge,
            minimumOrderAmount: minimumOrderAmount,
            restaurantName: product['restaurant'],
            restaurantId: product['restaurantID'],
            restaurantAddress: product['restaurantAddress'],
            locale: widget.locale,
            localizedValues: widget.localizedValues,
            product: product,
            currency: currency,
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
              alignment: AlignmentDirectional.topStart,
              width: screenWidth(context),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Text(
                      extraIngredients[index]['name'].length > 15
                          ? extraIngredients[index]['name'].substring(0, 15) +
                              '...'
                          : extraIngredients[index]['name'],
                      overflow: TextOverflow.ellipsis,
                      style: hintStyleprimaryLightOSR(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: new Text(
                        'x' + '1',
                        textAlign: TextAlign.center,
                        style: hintStyleprimaryOSR(),
                      ),
                    ),
                    new Text(
                      '$currency' +
                          extraIngredients[index]['price'].toStringAsFixed(2),
                      //  style: darkTextSmallHN(),
                    ),
                  ]));
        });
  }

  Widget priceTagLine(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: textMuliRegulars(),
        ),
        Text(
          '$currency' + value.toStringAsFixed(2),
          style: textMuliRegulars(),
        ),
      ],
    );
  }

  // Widget _buildPriceTagLine(String title, double value) {
  //   return Padding(
  //     padding: const EdgeInsets.only(
  //       left: 12.0,
  //       right: 12.0,
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         new Text(
  //           title,
  //           overflow: TextOverflow.ellipsis,
  //           style: titleBlackLightOSB(),
  //         ),
  //         new Text(
  //           '$currency' + value.toStringAsFixed(2),
  //           style: textprimaryOSR(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildBottomBar() {
  //   return GestureDetector(
  //     onTap: _checkLoginAndNavigate,
  //     child: new Container(
  //       height: 70.0,
  //       color: primary,
  //       child: new Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           new Text(
  //             MyLocalizations.of(context).completeOrder,
  //             style: subTitleWhiteLightOSR(),
  //           ),
  //           new Padding(padding: EdgeInsets.only(top: 5.0)),
  //           new Text(
  //             MyLocalizations.of(context).total +
  //                 ': $currency' +
  //                 grandTotal.toStringAsFixed(2),
  //             style: titleWhiteBoldOSB(),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _checkLoginAndNavigate() async {
    ProfileService.getUserInfo().then((value) {
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
    }).catchError((error) {});
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
            MyLocalizations.of(context).addNote,
            style: titleBlackLightOSBCoupon(),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 10)),
        (products[index] != null && products[index]['note'] != null)
            ? InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      products[index]['note'] = null;
                      Common.addProduct(products);
                    });
                    calculateCart();
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

  // Widget _buildApplyCouponLine() {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       InkWell(
  //         onTap: _goToCoupons,
  //         child: Text(
  //           MyLocalizations.of(context).applyCoupon,
  //           style: titleBlackLightOSBCoupon(),
  //         ),
  //       ),
  //       Padding(padding: EdgeInsets.only(left: 10)),
  //       selectedCoupon != null
  //           ? InkWell(
  //               onTap: () {
  //                 if (mounted) {
  //                   setState(() {
  //                     selectedCoupon = null;
  //                   });
  //                   calculateCart();
  //                 }
  //               },
  //               child: Icon(
  //                 Icons.cancel,
  //                 size: 18,
  //                 color: Colors.red,
  //               ),
  //             )
  //           : Container(),
  //     ],
  //   );
  // }

  Future<void> _showAddNoteAlert(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).cookNote),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    initialValue: products[index]['note'],
                    validator: (String value) {
                      if (value.isEmpty) {
                        return MyLocalizations.of(context).pleaseEnter;
                      } else
                        return null;
                    },
                    onSaved: (String value) {
                      if (mounted) {
                        setState(() {
                          products[index]['note'] = value;
                          Common.addProduct(products);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: MyLocalizations.of(context).note,
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
              child: Text(MyLocalizations.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(MyLocalizations.of(context).add),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  calculateCart();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  _buildFlavourList(List<dynamic> flavoursList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        flavoursList.length > 0
            ? Text(MyLocalizations.of(context).flavours)
            : Text(''),
        ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: flavoursList.length ?? 0,
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    flavoursList[index]['flavourName'],
                    style: titleBlackLightOSB(),
                  ),
                  Text(
                    '  X ',
                    style: titleBlackLightOSB(),
                  ),
                  Text(
                    flavoursList[index]['quantity'].toString(),
                    style: titleBlackLightOSB(),
                  ),
                ],
              );
            }),
      ],
    );
  }

  void calculatePrice(final Map<String, dynamic> product, bool increase,
      {addFlavours = false, removeFlavours = false, decrement = false}) async {
    Map<String, dynamic> cartProduct;
    int price = 0;
    int quantity = increase ? product['Quantity'] + 1 : product['Quantity'] - 1;
    price = product['price'].toInt() * quantity;
    List<dynamic> extraIngredientsList = List<dynamic>();
    if (product['extraIngredients'].length > 0 &&
        product['extraIngredients'][0] != null) {
      product['extraIngredients'].forEach((item) {
        if (item != null && item['isSelected'] != null && item['isSelected']) {
          price = price + item['price'];
          extraIngredientsList.add(item);
        }
      });
    }
    cartProduct = {
      'Discount': product['Discount'],
      'MRP': product['MRP'],
      'note': null,
      'Quantity': quantity,
      'price': product['price'],
      'extraIngredients': extraIngredientsList,
      'imageUrl': product['imageUrl'],
      'productId': product['productId'],
      'random': product['random'],
      'size': product['size'],
      'title': product['title'],
      'restaurant': product['restaurant'],
      'restaurantID': product['restaurantID'],
      'totalPrice': price,
      'restaurantAddress': product['restaurantAddress']
    };
    cartProduct.addAll({'product': product['product']});
    _updateProductQuantityFromCart(
      product,
      cartProduct,
      addFlavours: addFlavours,
      removeFlavours: removeFlavours,
      isDeleteItem: increase,
      decrement: decrement,
    );
  }

  void _updateProductQuantityFromCart(product, cartProduct,
      {isDeleteItem = false,
      addFlavours = false,
      removeFlavours = false,
      decrement = false}) async {
    await Common.getProducts().then((productsList) {
      products = productsList;
      if (productsList != null) {
        productsList.forEach((element) {
          if (element['productId'].toString() ==
                  cartProduct['productId'].toString() &&
              element['random'].toString() ==
                  cartProduct['random'].toString()) {
            productsList.remove(element);
            if (isDeleteItem) {
              if (addFlavours) {
                List<dynamic> flavourList = [];
                product['flavour'].map((flavour) {
                  Map<String, dynamic> item;
                  item = {
                    '_id': flavour['_id'],
                    'flavourName': flavour['flavourName'],
                    'tempQuantity': flavour['tempQuantity'],
                    'quantity': flavour['quantity'] + flavour['tempQuantity']
                  };
                  flavourList.add(item);
                }).toList();
                cartProduct.addAll({'flavour': flavourList});
              }
              productsList.add(cartProduct);
            }
            if (!isDeleteItem && removeFlavours) {
              List<dynamic> flavourList = [];
              product['flavour'].map((flavour) {
                Map<String, dynamic> item;
                item = {
                  '_id': flavour['_id'],
                  'flavourName': flavour['flavourName'],
                  'tempQuantity': flavour['tempQuantity'],
                  'quantity': flavour['quantity'] - flavour['tempQuantity']
                };
                flavourList.add(item);
              }).toList();
              cartProduct.addAll({'flavour': flavourList});
              productsList.add(cartProduct);
            }
            if (!isDeleteItem && decrement) {
              productsList.add(cartProduct);
            }
            Common.addProduct(productsList).then((value) {
              calculateCart();
            });
          }
        });
      }
    }).catchError((onError) {});
  }
}
