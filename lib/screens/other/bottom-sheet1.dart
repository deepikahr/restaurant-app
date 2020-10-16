import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/services/sentry-services.dart';
import 'package:RestaurantSaas/services/utils.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';

import 'flavour-list1.dart';

SentryError sentryError = new SentryError();

class BottonSheetClassDryClean extends StatefulWidget {
  final int minimumOrderAmount;
  final double deliveryCharge;
  final String currency, locale, shippingType;
  final Map<String, Map<String, String>> localizedValues;
  final String restaurantName, restaurantId, restaurantAddress;
  final Map<String, dynamic> product;

  BottonSheetClassDryClean({
    Key key,
    this.product,
    this.currency,
    this.locale,
    this.localizedValues,
    this.restaurantName,
    this.restaurantId,
    this.restaurantAddress,
    this.deliveryCharge,
    this.minimumOrderAmount,
    this.shippingType,
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

  double price = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              widget.product['product']['variants'].length > 0
                  ? _buildSingleSelectionBlock(widget.currency)
                  : Container(
                      height: 0.0,
                      width: 0.0,
                    ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: widget.product['product']['extraIngredients'].length > 0
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
              widget.product['product']['extraIngredients'] != null
                  ? _buildMultiSelectionBlock(
                      widget.product['product']['extraIngredients'],
                      widget.currency)
                  : Container(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
                onPressed: () {
                  calculatePrice(widget.product);
                  addFlavoursClicked();
                },
              )),
        ));
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
        itemCount: widget.product['product']['variants'].length == null
            ? 0
            : widget.product['product']['variants'].length,
        itemBuilder: (BuildContext context, int index) {
          if (widget.product['product']['variants'][index]['isSelected'] ==
              null)
            widget.product['product']['variants'][index]['isSelected'] = false;
          return Container(
            color: Colors.white,
            width: screenWidth(context),
            child: RadioListTile(
              value: index,
              groupValue: selectedSizeIndex,
              selected: widget.product['product']['variants'][index]
                  ['isSelected'],
              onChanged: (int selected) {
                if (mounted) {
                  setState(() {
                    selectedSizeIndex = selected;
                    widget.product['product']['variants'][index]['isSelected'] =
                        !widget.product['product']['variants'][index]
                            ['isSelected'];
                  });
                  calculatePrice(widget.product);
                }
              },
              activeColor: PRIMARY,
              title:
                  widget.product['product']['variants'][index]['size'] != null
                      ? new Text(
                          widget.product['product']['variants'][index]['size'],
                          style: hintStyleSmallDarkLightOSR(),
                        )
                      : Text(''),
              secondary:
                  widget.product['product']['variants'][index]['price'] != null
                      ? new Text(
                          currency +
                              widget.product['product']['variants'][index]
                                      ['price']
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
    cartProduct.addAll({'product': widget.product['product']});
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => FlavourPage(
              shippingType: widget.shippingType,
                  deliveryCharge: widget.deliveryCharge,
                  minimumOrderAmount: widget.minimumOrderAmount,
                  cartProduct: cartProduct,
                  flavourSelectable: widget.product['product']
                      ['flavourSelectable'],
                  flavourData: widget.product['product']['flavour'],
                  locale: widget.locale,
                  localizedValues: widget.localizedValues,
                )));
  }

  void calculatePrice(final Map<String, dynamic> product) async {
    price = 0;
    Map<String, dynamic> variant =
        widget.product['product']['variants'][selectedSizeIndex];
    price = price + variant['price'];

    if (mounted) {
      setState(() {
        price = price * quantity;
      });
    }
    List<dynamic> extraIngredientsList = List<dynamic>();
    if (product['product']['extraIngredients'].length > 0 &&
        product['product']['extraIngredients'][0] != null) {
      product['product']['extraIngredients'].forEach((item) {
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
      'Quantity': quantity,
      'price': variant['price'],
      'extraIngredients': extraIngredientsList,
      'imageUrl': product['imageUrl'],
      'productId': product['productId'],
      'random': generateRandomString(15),
      'size': variant['size'],
      'title': product['title'],
      'restaurant': widget.restaurantName,
      'restaurantID': widget.restaurantId,
      'totalPrice': price,
      'restaurantAddress': widget.restaurantAddress
    };
  }
}
