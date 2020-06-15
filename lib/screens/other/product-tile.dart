import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottom-sheet.dart';

class BuildProductTile extends StatefulWidget {
  final Map<String, dynamic> locationInfo, taxInfo;
  final String imgUrl,
      productName,
      info,
      currency,
      restaurantName,
      address,
      restaurantId;
  final Map<String, dynamic> product;
  final double mrp, off, price, topPadding;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  const BuildProductTile({
    Key key,
    this.imgUrl,
    this.productName,
    this.info,
    this.product,
    this.mrp,
    this.off,
    this.price,
    this.topPadding,
    this.currency,
    this.localizedValues,
    this.locale,
    this.restaurantName,
    this.address,
    this.restaurantId,
    this.locationInfo,
    this.taxInfo,
  }) : super(key: key);

  @override
  _BuildProductTileState createState() => _BuildProductTileState();
}

class _BuildProductTileState extends State<BuildProductTile> {
  bool dummy = true;
  int productQuantity = 0;
  List<dynamic> products;
  double price = 0;
  bool isProductDelete = false;
  Map<String, dynamic> cartProduct;

  @override
  Widget build(BuildContext context) {
    getProductQuantity(widget.product).then((value) {
      setState(() {
        productQuantity = value;
      });
    });
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 0.0),
          title: _buildProductTileTitle(widget.imgUrl, widget.productName,
              widget.mrp, widget.off, widget.price, widget.info),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 20.0,
                  child: Row(
                    children: <Widget>[
                      Text(
                        widget.info,
                        style: hintStyleGreyLightOSR(),
                      ),
                    ],
                  )),
              widget.off > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFFF0000)),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 15.0, top: 2.0, bottom: 2.0, right: 15.0),
                          child: Text(
                            widget.off.toStringAsFixed(1) + '% off',
                            style: hintStyleRedOSS(),
                          ),
                        ),
                      ),
                    )
                  : Text(''),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '${widget.currency}' + widget.price.toStringAsFixed(2),
                style: subTitleDarkBoldOSS(),
              ),
              productQuantity == 0
                  ? InkWell(
                      onTap: () {
                        _checkIfCartIsAvailable();
                      },
                      child: Container(
                        padding: EdgeInsetsDirectional.only(top: 18.0),
                        child: Image.asset(
                          'lib/assets/icon/addbtn.png',
                          width: 16.0,
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15.0)),
                      height: 30,
                      width: 100,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: InkWell(
                              onTap: () {
                                _changeProductQuantity(false);
                                _calculatePrice(widget.product);
                                _updateProductQuantityFromCart(productQuantity,
                                    false, widget.product["_id"], cartProduct);
                                _calculateCart();
                              },
                              child: Icon(
                                Icons.remove,
                                color: PRIMARY,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: Container(
                                child: Text(productQuantity.toString())),
                          ),
                          Text(''),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: PRIMARY,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _changeProductQuantity(true);
                                  _calculatePrice(widget.product);
                                  _updateProductQuantityFromCart(
                                      productQuantity,
                                      true,
                                      widget.product["_id"],
                                      cartProduct);
                                  _calculateCart();
                                },
                                child: Icon(Icons.add),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  void _updateProductQuantityFromCart(int productQuantity, bool increase,
      String productId, Map<String, dynamic> newProduct) async {
    await Common.getProducts().then((productsList) {
      print(productsList.toString());
      products = productsList;
      if (productsList != null) {
        productsList.forEach((element) {
          if (element['productId'].toString() == productId.toString()) {
            productsList.remove(element);
            if (!isProductDelete) {
              productsList.add(newProduct);
            } else {
              setState(() {
                isProductDelete = false;
              });
            }
            Common.addProduct(productsList).then((value) {});
            if (productsList.length != 0) {
              Common.setCart(null);
            }
          }
        });
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  void _changeProductQuantity(bool increase) {
    if (increase) {
      if (mounted) {
        setState(() {
          productQuantity++;
        });
      }
    } else {
      if (productQuantity == 1) {
        setState(() {
          isProductDelete = true;
        });
      } else if (productQuantity > 0) {
        if (mounted) {
          setState(() {
            productQuantity--;
          });
        }
      }
    }
  }

  Widget _buildProductTileTitle(String imgUrl, String productName, double mrp,
      double off, double price, String info) {
    return Row(
      children: <Widget>[
        Text(
          productName.length > 21
              ? "${productName[0].toUpperCase()}${productName.substring(1, 21) + '...'}"
              : "${productName[0].toUpperCase()}${productName.substring(1)}",
          style: subTitleDarkBoldOSS(),
        ),
        Padding(padding: EdgeInsets.all(5.0)),
        off > 0
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0), color: PRIMARY),
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    '${widget.currency} ' + mrp.toStringAsFixed(2),
                    style: hintStyleSmallWhiteLightOSSStrike(),
                  ),
                ),
              )
            : Text(''),
      ],
    );
  }

  Future<int> getProductQuantity(Map<String, dynamic> product) async {
    int quantity = 0;
    List<dynamic> products;
    await Common.getProducts().then((value) {
      products = value;
    });
    if (products != null) {
      products.forEach((cartProduct) {
        if (cartProduct['productId'].toString() == product['_id'].toString()) {
          quantity = cartProduct['Quantity'];
        }
        return quantity;
      });
    }
    return quantity;
  }

  void _calculatePrice(final Map<String, dynamic> product) {
    price = 0;
    Map<String, dynamic> variant = product['variants'][0];
    price = price + variant['price'];

    if (mounted) {
      setState(() {
        price = price * productQuantity;
      });
    }
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
      'Discount': variant['Discount'],
      'MRP': variant['MRP'],
      'note': null,
      'Quantity': productQuantity,
      'price': variant['price'],
      'extraIngredients': extraIngredientsList,
      'imageUrl': product['imageUrl'],
      'productId': product['_id'],
      'size': variant['size'],
      'title': product['title'],
      'restaurant': widget.restaurantName,
      'restaurantID': widget.restaurantId,
      'totalPrice': price,
      'restaurantAddress': widget.address
    };
  }

  void _checkIfCartIsAvailable() {
    Common.getCart().then((onValue) {
      try {
        if (onValue == null) {
          _showBottomSheet();
        } else {
          if (onValue['location'] == widget.locationInfo['_id']) {
            _showBottomSheet();
          } else {
            _showClearCartAlert();
          }
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return BottonSheetClassDryClean(
            taxInfo: widget.taxInfo,
            locationInfo: widget.locationInfo,
            restaurantName: widget.restaurantName,
            restaurantId: widget.restaurantId,
            restaurantAddress: widget.address,
            locale: widget.locale,
            localizedValues: widget.localizedValues,
            productQuantity: productQuantity,
            currency: widget.currency,
            product: widget.product,
            variantsList: widget.product['variants'] ?? '',
          );
        });
  }

  Future<void> _showClearCartAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).clearcart + '?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(MyLocalizations.of(context)
                        .youhavesomeitemsalreadyinyourcartfromotherlocationremovetoaddthis +
                    '!'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MyLocalizations.of(context).yes),
              onPressed: () {
                Navigator.of(context).pop();
                Common.removeCart();
                _showBottomSheet();
              },
            ),
            FlatButton(
              child: Text(MyLocalizations.of(context).no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _calculateCart() async {
    double deliveryCharge = 0.0, subTotal = 0.0, grandTotal = 0.0;
    Map<String, dynamic> selectedCoupon;
    double couponDeduction = 0.0;
    double tax = 0.0;
    List<dynamic> products;

    // [0] other options when opening cart from menu

    if (widget.taxInfo != null) {
      Map<String, dynamic> cartInfo = {
        'taxInfo': widget.taxInfo,
        'locationInfo': widget.locationInfo
      };
      await Common.setCartInfo(cartInfo).then((onValue) {});
    }

    // [1] retrive cart from storage if available
    Map<String, dynamic> cart;
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
    if (products.length != 0)
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

    // [8] set cart state and save to storage
    if (widget.locationInfo != null) {
      if (products.length != 0) {
        await Common.setCart(cart);
      } else {
        await Common.setCart(null);
      }
    }
  }
}
