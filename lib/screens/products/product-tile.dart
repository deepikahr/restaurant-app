import 'package:RestaurantSaas/screens/auth/login.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'bottom-sheet.dart';

class BuildProductTile extends StatefulWidget {
  final Map<String, dynamic> locationInfo, taxInfo;
  final bool isProductFirstDeliverFree;
  final String imgUrl,
      productName,
      info,
      currency,
      restaurantName,
      address,
      shippingType,
      restaurantId;
  final Map<String, dynamic> product;
  final double mrp, off, price, topPadding;
  final Map<String, Map<String, String>> localizedValues;
  final String locale, locationId;
  final int deliveryCharge, minimumOrderAmount;

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
    this.shippingType,
    this.deliveryCharge,
    this.minimumOrderAmount,
    this.isProductFirstDeliverFree,
    this.locationId,
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

    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (BuildContext context) => ProductDetailsPage(
        //         product: widget.product,
        //         restaurantName: widget.restaurantName,
        //         restaurantId: widget.restaurantId,
        //         locationInfo: widget.locationInfo,
        //           )),
        // );
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.imgUrl != null
                ? ClipRRect(
                    child: Image.network(
                      widget.imgUrl,
                      height: 115,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  )
                : Image.asset('lib/assets/images/dominos.png'),
            SizedBox(
              height: 6,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${widget.productName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMuliSemiboldsm(),
                ),
                SizedBox(
                  width: 6,
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              widget.info,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: hintStyleGreyLightOSR(),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.off > 0
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFFF0000)),
                            borderRadius: BorderRadius.circular(5.0)),
                        padding: EdgeInsets.only(
                            left: 12.0, top: 2.0, bottom: 2.0, right: 12.0),
                        child: Text(
                          widget.off.toStringAsFixed(1) + '% off',
                          style: hintStyleRedOSS(),
                        ),
                      )
                    : Text(''),
                Text(
                  '\$ ${widget.mrp}',
                  style: textMuliRegularsmstrike(),
                ),
                SizedBox(width: 3),
                Text(
                  '\$ ${widget.price}',
                  style: textMuliSemiboldsm(),
                ),
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Container(
              height: 28,
              margin: EdgeInsets.all(8),
              child: GFButton(
                  color: primary,
                  elevation: 0,
                  fullWidthButton: true,
                  type: GFButtonType.outline,
                  borderShape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                      side: BorderSide(color: primary)),
                  onPressed: () {
                    _checkLoginAndNavigate();
                  },
                  child: Text(
                    '+ Add',
                    style: textMuliSemiboldprimary(),
                  )),
            ),
            //                Container(
            //   width: 158,
            //   height: 28,
            //   margin: EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     border: Border.all(color:primary),
            //     borderRadius: BorderRadius.circular(5)
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: <Widget>[
            //        Icon(Icons.remove,color:primary),
            //           Text(
            //             '1',
            //             style: textMuliSemiboldsm(),
            //           ),
            //           Icon(Icons.add,color:primary),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
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
        _checkIfCartIsAvailable();
      }
    });
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
      } catch (error) {}
    }).catchError((onError) {});
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return BottomSheetClassDryClean(
            locationId: widget.locationId,
            isProductFirstDeliverFree: widget.isProductFirstDeliverFree,
            shippingType: widget.shippingType,
            deliveryCharge: widget.deliveryCharge,
            minimumOrderAmount: widget.minimumOrderAmount,
            locationInfo: widget.locationInfo,
            restaurantName: widget.restaurantName,
            restaurantId: widget.restaurantId,
            restaurantAddress: widget.address,
            locale: widget.locale,
            localizedValues: widget.localizedValues,
            currency: widget.currency,
            product: widget.product,
            variantsList: widget.product['variants'] ?? '',
          );
        });
  }

  Future<void> _showClearCartAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
}
