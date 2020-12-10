import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/services/sentry-services.dart';
import 'package:RestaurantSaas/services/utils.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'flavours-list.dart';

SentryError sentryError = new SentryError();

class BottonSheetClassDryClean extends StatefulWidget {
  final Map<String, dynamic> locationInfo;
  final List variantsList;
  final int deliveryCharge, minimumOrderAmount;
  final String currency, locale, shippingType, locationId;
  final Map<String, Map<String, String>> localizedValues;
  final String restaurantName, restaurantId, restaurantAddress;
  final Map<String, dynamic> product;
  final bool isProductFirstDeliverFree;

  BottonSheetClassDryClean({
    Key key,
    this.variantsList,
    this.product,
    this.currency,
    this.locale,
    this.localizedValues,
    this.restaurantName,
    this.restaurantId,
    this.restaurantAddress,
    this.locationInfo,
    this.deliveryCharge,
    this.minimumOrderAmount,
    this.shippingType,
    this.isProductFirstDeliverFree,
    this.locationId,
  }) : super(key: key);

  @override
  _BottonSheetClassDryCleanState createState() =>
      _BottonSheetClassDryCleanState();
}

class _BottonSheetClassDryCleanState extends State<BottonSheetClassDryClean> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedSizeIndex = 0;
  Map<String, dynamic> cartProduct;

  int groupValue = 0;
  bool selectVariant = false, addProductTocart = false, getTokenValue = false;
  int quantity = 1;
  String variantUnit, variantId;
  int variantStock;
  var variantPrice;
  List<dynamic> flavoursList = [];
  List<dynamic> tempProducts = [];

  double price = 0;

  @override
  void initState() {
    calculatePrice(widget.product);
    super.initState();
  }

  void calculatePrice(final Map<String, dynamic> product) async {
    price = 0;
    Map<String, dynamic> variant =
        widget.product['variants'][selectedSizeIndex];
    price = price + variant['price'];

    if (mounted) {
      setState(() {
        price = price * quantity;
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
      'categoryId': product['category'],
      'categoryName': product['title'],
      'Discount': variant['Discount'],
      'MRP': variant['MRP'],
      'note': null,
      'Quantity': quantity,
      'price': variant['price'],
      'extraIngredients': extraIngredientsList,
      'imageUrl': product['imageUrl'],
      'productId': product['_id'],
      'random': generateRandomString(15),
      'size': variant['size'],
      'title': product['title'],
      'restaurant': widget.restaurantName,
      'restaurantID': widget.restaurantId,
      'totalPrice': price,
      'restaurantAddress': widget.restaurantAddress
    };
    print(cartProduct.toString());
  }

  void addProduct() async {
    calculatePrice(widget.product);
    await Common.getProducts().then((productsList) {
      if (productsList != null) {
        tempProducts = productsList;
        tempProducts.add(cartProduct);
        Common.addProduct(tempProducts).then((value) {
          Toast.show(
              MyLocalizations.of(context).producthasbeenaddedtocart, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        tempProducts.add(cartProduct);
        if (widget.shippingType != null) {
          Common.setDeliveryCharge({
            "shippingType": widget.shippingType,
            "deliveryCharge": widget.deliveryCharge,
            "minimumOrderAmount": widget.minimumOrderAmount
          });
        }
        Common.addProduct(tempProducts).then((value) {
          Toast.show(
              MyLocalizations.of(context).producthasbeenaddedtocart, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  void _calculateCart() async {
    double deliveryCharge = 0.0, subTotal = 0.0, grandTotal = 0.0;
    Map<String, dynamic> selectedCoupon;
    double couponDeduction = 0.0;
    double tax = 0.0;
    List<dynamic> products;

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

    // [5] calculate delivery charge
    if (widget.shippingType != null) {
      if (widget.shippingType.compareTo('free') == 0) {
        deliveryCharge = 0.0;
      } else if (widget.shippingType.compareTo('flexible') == 0) {
        if (subTotal > widget.minimumOrderAmount) {
          deliveryCharge = 0.0;
        } else {
          deliveryCharge = widget.deliveryCharge.toDouble();
        }
      } else if (widget.shippingType.compareTo('fixed') == 0) {
        deliveryCharge = widget.deliveryCharge.toDouble();
      } else {
        deliveryCharge = 0.0;
      }
    }

    // [6] calculate grand total
    grandTotal = subTotal + deliveryCharge + tax;

    // [7] create complete order json as Map
    cart = {
      'locationId': widget.locationId,
      'firstDeliveryFree': widget.isProductFirstDeliverFree,
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
      'shippingAddress': null,
      'restaurant': products.length > 0 ? products[0]['restaurant'] : null,
      'restaurantID': products.length > 0 ? products[0]['restaurantID'] : null,
      'status': 'Pending',
      'subTotal': subTotal,
      'productDetails': products,
      'note': null,
      'isForDineIn': false,
      'pickupDate': null,
      'pickupTime': null,
      'coupon': selectedCoupon == null
          ? {'couponApplied': false}
          : {'couponApplied': true, 'couponName': selectedCoupon['couponName']}
    };

    // [8] set cart state and save to storage
    if (widget.locationInfo != null) {
      await Common.setCart(cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    Common.getFlavours().then((value) {
      if (mounted) {
        setState(() {
          flavoursList = value ?? [];
        });
      }
    });
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            widget.product['variants'].length > 0
                ? _buildSingleSelectionBlock(widget.currency)
                : Container(
                    height: 0.0,
                    width: 0.0,
                  ),
            Padding(
              padding: EdgeInsets.only(bottom: 5.0),
              child: widget.product['extraIngredients'].length > 0
                  ? _buildHeadingBlock(
                      MyLocalizations.of(context).extra,
                      MyLocalizations.of(context)
                          .whichextraingredientswouldyouliketoadd,
                    )
                  : Container(
                      height: 0.0,
                      width: 0.0,
                    ),
            ),
            widget.product['extraIngredients'] != null
                ? _buildMultiSelectionBlock(
                    widget.product['extraIngredients'], widget.currency)
                : Container(),
          ],
        ),
      ),
      bottomNavigationBar: widget.product['isFlavoured']
          ? Container(
              height: 65.0,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 10.0, end: 10.0, bottom: 5.0),
                  child: RawMaterialButton(
                    padding: EdgeInsetsDirectional.only(start: .0, end: 15.0),
                    fillColor: PRIMARY,
                    constraints: const BoxConstraints(minHeight: 44.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      MyLocalizations.of(context).addFlavour,
                      style: smallTitleWhiteOSR(),
                    ),
                    onPressed: () => addFlavoursClicked(),
                  )),
            )
          : Container(
              height: 65.0,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 10.0, end: 10.0, bottom: 5.0),
                child: RawMaterialButton(
                  padding: EdgeInsetsDirectional.only(start: .0, end: 15.0),
                  fillColor: PRIMARY,
                  constraints: const BoxConstraints(minHeight: 44.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: Container(
                          color: Colors.black,
                          margin: EdgeInsets.only(right: 0),
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 2.0,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '(${quantity.toString()}) ',
                                      style: titleLightWhiteOSS(),
                                    ),
                                    TextSpan(
                                        text: quantity == 1
                                            ? MyLocalizations.of(context).item
                                            : MyLocalizations.of(context).items,
                                        style: titleLightWhiteOSS()),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 1.0,
                              ),
                              new Text(
                                '${widget.currency} ${price.toStringAsFixed(2)}',
                                style: titleLightWhiteOSS(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      addProductTocart ? CircularProgressIndicator() : Text(""),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: new Text(
                          MyLocalizations.of(context).addToCart,
                          style: smallTitleWhiteOSR(),
                        ),
                      ),
                      Icon(Icons.shopping_cart, color: Colors.white)
                    ],
                  ),
                  onPressed: () async {
                    addProduct();
                    _calculateCart();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
    );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget _buildHeadingBlock(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Container(
        color: whiteTextb,
        height: 58.0,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 4.0)),
            Text(
              title,
              style: titleDarkBoldOSB(),
            ),
            Text(
              subtitle,
              style: hintStyleSmallTextDarkOSR(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleSelectionBlock(String currency) {
    return Container(
      color: greyc,
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(right: 0.0),
        itemCount: widget.product['variants'].length == null
            ? 0
            : widget.product['variants'].length,
        itemBuilder: (BuildContext context, int index) {
          if (widget.product['variants'][index]['isSelected'] == null)
            widget.product['variants'][index]['isSelected'] = false;
          return Container(
            color: Colors.white,
            width: screenWidth(context),
            child: RadioListTile(
              value: index,
              groupValue: selectedSizeIndex,
              selected: widget.product['variants'][index]['isSelected'],
              onChanged: (int selected) {
                if (mounted) {
                  setState(() {
                    selectedSizeIndex = selected;
                    widget.product['variants'][index]['isSelected'] =
                        !widget.product['variants'][index]['isSelected'];
                  });
                  calculatePrice(widget.product);
                }
              },
              activeColor: PRIMARY,
              title: widget.product['variants'][index]['size'] != null
                  ? new Text(
                      widget.product['variants'][index]['size'],
                      style: hintStyleSmallDarkLightOSR(),
                    )
                  : Text(''),
              secondary: widget.product['variants'][index]['price'] != null
                  ? new Text(
                      currency +
                          widget.product['variants'][index]['price']
                              .toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: hintStyleTitleBlueOSR(),
                    )
                  : Text(''),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMultiSelectionBlock(List<dynamic> extras, String currency) {
    return Container(
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: extras.length,
        itemBuilder: (BuildContext context, int index) {
          if (extras[index] != null && extras[index]['isSelected'] == null)
            extras[index]['isSelected'] = false;
          return extras[index] != null
              ? Container(
                  color: Colors.white,
                  width: screenWidth(context),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: extras[index]['isSelected'],
                          onChanged: (bool value) {
                            if (mounted) {
                              setState(() {
                                extras[index]['isSelected'] =
                                    !extras[index]['isSelected'];
                              });
                              calculatePrice(widget.product);
                            }
                          },
                          activeColor: PRIMARY,
                        ),
                        Text(
                          extras[index]['name'] != null
                              ? extras[index]['name']
                              : '',
                          style: hintStyleSmallDarkLightOSR(),
                        ),
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: new Text(
                                currency +
                                    (extras[index]['price']).toStringAsFixed(2),
                                textAlign: TextAlign.end,
                                style: hintStyleTitleBlueOSR(),
                              )),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: Colors.white,
                  width: screenWidth(context),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                  ),
                );
        },
      ),
    );
  }

  addFlavoursClicked() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => FlavourPage(
                  locationId: widget.locationId,
                  locationInfo: widget.locationInfo,
                  product: widget.product,
                  deliveryCharge: widget.deliveryCharge,
                  minimumOrderAmount: widget.minimumOrderAmount,
                  shippingType: widget.shippingType,
                  isProductFirstDeliverFree: widget.isProductFirstDeliverFree,
                  cartProduct: cartProduct,
                  flavourSelectable: widget.product['flavourSelectable'],
                  flavourData: widget.product['flavour'],
                  locale: widget.locale,
                  localizedValues: widget.localizedValues,
                )));
  }
}
