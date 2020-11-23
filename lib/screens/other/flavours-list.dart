import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class FlavourPage extends StatefulWidget {
  final Map<String, dynamic> flavourData;
  final Map<String, Map<String, String>> localizedValues;
  final String locale, shippingType, locationId;
  final int flavourSelectable, minimumOrderAmount, deliveryCharge;
  final Map cartProduct;
  final Map<String, dynamic> locationInfo, product;
  final bool isProductFirstDeliverFree;

  const FlavourPage(
      {Key key,
      this.localizedValues,
      this.locale,
      this.flavourData,
      this.flavourSelectable,
      this.cartProduct,
      this.shippingType,
      this.locationId,
      this.minimumOrderAmount,
      this.deliveryCharge,
      this.isProductFirstDeliverFree,
      this.locationInfo,
      this.product})
      : super(key: key);

  @override
  _FlavourPageState createState() => _FlavourPageState();
}

class _FlavourPageState extends State<FlavourPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> cartProduct;
  int flavourQuantity = 0;
  bool isSelectExtra = true;
  List<dynamic> selectedFlavoursList = [];

  @override
  void initState() {
    cartProduct = widget.cartProduct;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.flavourData != null ? widget.flavourData['Title'] : '',
          style: textbarlowSemiBoldBlack(),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.flavourData['flavours'].length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return FlavourTile(
                maxSelect: widget.flavourSelectable,
                flavourData: widget.flavourData,
                index: index,
                isSelectExtra: isSelectExtra,
                changeQuantity: _changeProductQuantity,
              );
            }),
      ),
      bottomNavigationBar:
          ((selectedFlavoursList?.length ?? 0) > 0) ? _buildSaveButton() : null,
    );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1500),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void addProduct() async {
    List<dynamic> tempProducts = [];
    await Common.getProducts().then((productsList) {
      if (productsList != null) {
        tempProducts = productsList;
        tempProducts.add(cartProduct);
        Common.addProduct(tempProducts).then((value) {
          Toast.show(
              MyLocalizations.of(context).producthasbeenaddedtocart, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _calculateCart();
          Future.delayed(Duration(milliseconds: 2000), () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      } else {
        tempProducts.add(cartProduct);
        Common.addProduct(tempProducts).then((value) {
          Toast.show(
              MyLocalizations.of(context).producthasbeenaddedtocart, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _calculateCart();
          Future.delayed(Duration(milliseconds: 2000), () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      }
    }).catchError((onError) {});
  }

  void _calculateCart() async {
    double deliveryCharge = 0.0, subTotal = 0.0, grandTotal = 0.0;
    List<dynamic> products;

    // [1] retrive cart from storage if available
    Map<String, dynamic> cart;
    await Common.getCart().then((onValue) {
      cart = onValue;
    });

    await Common.getProducts().then((value) => products = value);

    subTotal = 0.0;
    for (int i = 0; i < products.length; i++) {
      subTotal = subTotal + products[i]['totalPrice'];
    }

    // [5] calculate delivery charge
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

    // [6] calculate grand total
    grandTotal = subTotal + deliveryCharge;

    // [7] create complete order json as Map
    cart = {
      'locationId': widget.locationId,
      'firstDeliveryFree': widget.isProductFirstDeliverFree,
      'deliveryCharge': deliveryCharge,
      'grandTotal': grandTotal,
      'location': widget.locationId,
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
      'coupon': {'couponApplied': false}
    };
    Common.setDeliveryCharge({
      "shippingType": widget.shippingType,
      "deliveryCharge": widget.deliveryCharge,
      "minimumOrderAmount": widget.minimumOrderAmount
    });

    // [8] set cart state and save to storage
    if (widget.locationInfo != null) {
      await Common.setCart(cart);
    }
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      child: RawMaterialButton(
          onPressed: () {
            try {
              cartProduct.addAll({'flavour': selectedFlavoursList});
              cartProduct.addAll({'product': widget.product});
              addProduct();
            } catch (error) {}
          },
          child: Container(
            alignment: AlignmentDirectional.center,
            margin: EdgeInsets.only(left: 5.0, right: 5.0),
            height: 56.0,
            decoration: BoxDecoration(
                color: PRIMARY, border: Border.all(color: PRIMARY)),
            child: Text(
              MyLocalizations.of(context).addToCart,
              style: smallTitleWhiteOSR(),
            ),
          )),
    );
  }

  void _changeProductQuantity(
      bool increase, int index, int individualQuantity) {
    if (increase) {
      if (mounted) {
        setState(() {
          flavourQuantity++;
        });
      }
    } else {
      if (flavourQuantity > 0) {
        if (mounted) {
          setState(() {
            flavourQuantity--;
          });
        }
      }
    }
    _changeFlavourData(increase, index, individualQuantity);
    checkMaxSelect();
  }

  void _changeFlavourData(
      bool increase, int index, int individualQuantity) async {
    Map<String, dynamic> flavourData;
    if (selectedFlavoursList != null) {
      String id;
      selectedFlavoursList.map((e) {
        if (e['_id'] == widget.flavourData['flavours'][index]['_id']) {
          id = e['_id'];
        }
      }).toList();
      if (id != null) {
        selectedFlavoursList.removeWhere((element) =>
            element['_id'] == widget.flavourData['flavours'][index]['_id']);
        if (increase) {
          flavourData = {
            'tempQuantity': individualQuantity,
            "_id": widget.flavourData['flavours'][index]['_id'],
            "flavourName": widget.flavourData['flavours'][index]['flavourName'],
            "quantity": individualQuantity
          };
          selectedFlavoursList.add(flavourData);
        } else if (individualQuantity > 0) {
          flavourData = {
            "_id": widget.flavourData['flavours'][index]['_id'],
            "flavourName": widget.flavourData['flavours'][index]['flavourName'],
            "quantity": individualQuantity,
            'tempQuantity': individualQuantity,
          };
          selectedFlavoursList.add(flavourData);
        }
      } else {
        if (increase) {
          flavourData = {
            "_id": widget.flavourData['flavours'][index]['_id'],
            "flavourName": widget.flavourData['flavours'][index]['flavourName'],
            "quantity": individualQuantity,
            'tempQuantity': individualQuantity,
          };
          selectedFlavoursList.add(flavourData);
        }
      }
    } else {
      if (increase) {
        flavourData = {
          "_id": widget.flavourData['flavours'][index]['_id'],
          "flavourName": widget.flavourData['flavours'][index]['flavourName'],
          "quantity": individualQuantity,
          'tempQuantity': individualQuantity,
        };
        selectedFlavoursList.add(flavourData);
      }
    }
  }

  void checkMaxSelect() {
    if (widget.flavourSelectable == flavourQuantity) {
      if (mounted) {
        setState(() {
          isSelectExtra = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isSelectExtra = true;
        });
      }
    }
  }
}

class FlavourTile extends StatefulWidget {
  final Map<String, dynamic> flavourData;
  final Function changeQuantity;
  final int index;
  final bool isSelectExtra;
  final int maxSelect;

  const FlavourTile(
      {Key key,
      this.flavourData,
      this.changeQuantity,
      this.index,
      this.isSelectExtra,
      this.maxSelect})
      : super(key: key);

  @override
  _FlavourTileState createState() => _FlavourTileState();
}

class _FlavourTileState extends State<FlavourTile> {
  int individualQuantity = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
          Widget>[
        Text(
          widget.flavourData['flavours'][widget.index]['flavourName'],
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            wordSpacing: 0.5,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                if (mounted) {
                  setState(() {
                    if (individualQuantity > 0) {
                      setState(() {
                        individualQuantity--;
                      });
                      widget.changeQuantity(
                          false, widget.index, individualQuantity);
                    }
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: individualQuantity == 0 ? Colors.white : PRIMARY,
                  border: Border.all(
                      color: individualQuantity == 0 ? Colors.grey : PRIMARY),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.remove,
                  color: individualQuantity == 0 ? Colors.grey : Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              individualQuantity.toString(),
              style: TextStyle(
                  color: individualQuantity == 0 ? Colors.grey : Colors.black),
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (widget.isSelectExtra) {
                  if (mounted) {
                    setState(() {
                      individualQuantity++;
                      widget.changeQuantity(
                          true, widget.index, individualQuantity);
                    });
                  }
                } else {
                  showSnackbar(
                      '${MyLocalizations.of(context).youCanPickMaximum} ${widget.maxSelect} ${MyLocalizations.of(context).flavours}');
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: individualQuantity == 0 ? Colors.white : PRIMARY,
                  border: Border.all(
                      color: individualQuantity == 0 ? Colors.grey : PRIMARY),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.add,
                  color: individualQuantity == 0 ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1500),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
