import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'cart.dart';
import '../../services/common.dart';
import '../../services/profile-service.dart';
import '../mains/home.dart';
import 'dart:convert';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> product, locationInfo, taxInfo, tableInfo;
  final String restaurantName, restaurantId, restaurantAddress;

  ProductDetailsPage(
      {Key key,
      this.product,
      this.locationInfo,
      this.restaurantName,
      this.restaurantId,
      this.taxInfo,
      this.tableInfo,
      this.restaurantAddress})
      : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int selectedSizeIndex = 0;
  int quantity = 1;
  double price = 0;
  Map<String, dynamic> cartProduct;
  bool isLoading = true;
  bool isFavourite = false;
  String favouriteId;
  bool isLoggedIn = false;

  void _changeProductQuantity(bool increase) {
    if (increase) {
      setState(() {
        quantity++;
      });
    } else {
      if (quantity > 1) {
        setState(() {
          quantity--;
        });
      }
    }
    _calculatePrice();
  }

  void _calculatePrice() {
    price = 0;
    Map<String, dynamic> variant =
        widget.product['variants'][selectedSizeIndex];
    price = price + variant['price'];

    setState(() {
      price = price * quantity;
    });
    List<dynamic> extraIngredientsList = List<dynamic>();
    if (widget.product['extraIngredients'].length > 0 &&
        widget.product['extraIngredients'][0] != null) {
      widget.product['extraIngredients'].forEach((item) {
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
      'imageUrl': widget.product['imageUrl'],
      'productId': widget.product['_id'],
      'size': variant['size'],
      'title': widget.product['title'],
      'restaurant': widget.restaurantName,
      'restaurantID': widget.restaurantId,
      'totalPrice': price,
      'restaurantAddress': widget.restaurantAddress
    };
  }

  @override
  void initState() {
    Common.getToken().then((onValue) {
      if (onValue != null) {
        setState(() {
          isLoggedIn = true;
          _checkFavourite();
        });
      }
    });
    _calculatePrice();
    super.initState();
  }

  void _checkFavourite() async {
    ProfileService.checkFavourite(widget.product['_id']).then((onValue) {
      if (mounted) {
        setState(() {
          isLoading = false;
          if (onValue['_id'] != null) {
            favouriteId = onValue['_id'];
          }
          if (onValue['resflag'] != null) {
            isFavourite = onValue['resflag'];
          } else {
            isFavourite = false;
          }
        });
      }
    });
  }

  void _addToFavourite() async {
    setState(() {
      isLoading = true;
    });
    if (isFavourite) {
      ProfileService.removeFavouritById(favouriteId).then((onValue) {
        if (onValue != null) {
          setState(() {
            favouriteId = null;
            isLoading = false;
            isFavourite = false;
          });
        }
      });
    } else {
      ProfileService.addToFavourite(widget.product['_id'], widget.restaurantId,
              widget.locationInfo['_id'])
          .then((onValue) {
        setState(() {
          favouriteId = onValue['_id'];
          isLoading = false;
          isFavourite = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(
          widget.product['title'],
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[
          HomePageState.buildCartIcon(context),
        ],
      ),
      // body: Stack(
      //   alignment: AlignmentDirectional.topCenter,
      //   children: <Widget>[

      //     _buildProductAddCounter(),
      //     _buildAddToCartButton(),
      //   ],
      // ),

      body: Container(
        alignment: AlignmentDirectional.topCenter,
        color: Colors.white,
        child: SingleChildScrollView(
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              _buildProductTopImg(
                widget.product['imageUrl'],
                widget.product['description'],
              ),
              _buildHeadingBlock(
                'Sizes & Price',
                'Select which size would you like to add',
              ),
              _buildSingleSelectionBlock(widget.product['variants']),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: widget.product['extraIngredients'].length > 0
                    ? _buildHeadingBlock(
                        'Extra',
                        'Which extra ingredients would you like to add',
                      )
                    : Container(
                        height: 0.0,
                        width: 0.0,
                      ),
              ),
              _buildMultiSelectionBlock(widget.product['extraIngredients']),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 110.0,
        child: Column(
          children: <Widget>[
            _buildProductAddCounter(),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildABoutUsBox(String description) {
    return Container(
      width: screenWidth(context),
      child: Column(children: [
        ExpansionTile(
          title: Text(
            'Description',
            // style: titleWhiteBoldOSBB(),
          ),
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
                child: Text(
                  description,
                  //  style: hintStyleSmallWhiteLightOSRInfo()
                ))
          ],
        ),
      ]),
    );
  }

  Widget _buildProductTopImg(String imgUrl, String description) {
    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.passthrough,
      children: <Widget>[
        Image(
          image: imgUrl != null
              ? NetworkImage(imgUrl)
              : AssetImage("lib/assets/headers/menu.png"),
          fit: BoxFit.fill,
          height: 150.0,
        ),
        isLoggedIn
            ? Positioned(
                top: 0,
                left: 0,
                child: isLoading
                    ? Image.asset(
                        'lib/assets/icon/spinner.gif',
                        width: 40.0,
                        height: 40.0,
                      )
                    : InkWell(
                        onTap: _addToFavourite,
                        child: Icon(
                          Icons.favorite,
                          color: isFavourite ? PRIMARY : primaryLight,
                          size: 40.0,
                        ),
                      ),
              )
            : Container(height: 0, width: 0),
      ],
    );
  }

  Widget _buildHeadingBlock(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Container(
        color: whiteTextb,
        height: 50.0,
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

  Widget _buildMultiSelectionBlock(List<dynamic> extras) {
    return Container(
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: extras.length,
        itemBuilder: (BuildContext context, int index) {
          if (extras[index] != null && extras[index]['isSelected'] == null)
            extras[index]['isSelected'] = false;
          return Container(
            color: Colors.white,
            width: screenWidth(context),
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: extras[index]['isSelected'],
                    onChanged: (bool value) {
                      setState(() {
                        extras[index]['isSelected'] =
                            !extras[index]['isSelected'];
                      });
                      _calculatePrice();
                    },
                    activeColor: PRIMARY,
                  ),
                  Text(
                    extras[index]['name'] != null ? extras[index]['name'] : '',
                    style: hintStyleSmallDarkLightOSR(),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: new Text(
                          '\$' + (extras[index]['price']).toStringAsFixed(2),
                          textAlign: TextAlign.end,
                          style: hintStyleTitleBlueOSR(),
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleSelectionBlock(List<dynamic> sizes) {
    return Container(
      color: greyc,
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(right: 0.0),
        itemCount: sizes.length,
        itemBuilder: (BuildContext context, int index) {
          if (sizes[index]['isSelected'] == null)
            sizes[index]['isSelected'] = false;
          return Container(
            color: Colors.white,
            width: screenWidth(context),
            child: RadioListTile(
              value: index,
              groupValue: selectedSizeIndex,
              selected: sizes[index]['isSelected'],
              onChanged: (int selected) {
                setState(() {
                  selectedSizeIndex = selected;
                  sizes[index]['isSelected'] = !sizes[index]['isSelected'];
                });
                _calculatePrice();
              },
              activeColor: PRIMARY,
              title: new Text(
                sizes[index]['size'],
                style: hintStyleSmallDarkLightOSR(),
              ),
              secondary: new Text(
                '\$' + sizes[index]['price'].toStringAsFixed(2),
                textAlign: TextAlign.end,
                style: hintStyleTitleBlueOSR(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductAddCounter() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
        end: 20.0,
        bottom: 10.0,
      ),
      child: RawMaterialButton(
        onPressed: null,
        padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
        fillColor: primaryLight,
        constraints: const BoxConstraints(minHeight: 44.0),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(50.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                _changeProductQuantity(false);
              },
              child: Container(
                child: Image(
                  image: AssetImage('lib/assets/icon/minus.png'),
                  width: 26.0,
                ),
              ),
            ),
            new Container(
              alignment: AlignmentDirectional.center,
              width: 26.0,
              height: 26.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: PRIMARY,
              ),
              child: new Text(quantity.toString(),
                  textAlign: TextAlign.center, style: hintStyleLightOSB()),
            ),
            InkWell(
              onTap: () {
                _changeProductQuantity(true);
              },
              child: Container(
                  child: Image(
                image: AssetImage('lib/assets/icon/addbtn.png'),
                width: 26.0,
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 1.0),
      child: RawMaterialButton(
        padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
        fillColor: PRIMARY,
        constraints: const BoxConstraints(minHeight: 44.0),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(50.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text(
              "ADD TO CART",
              style: hintStyleWhiteLightOSB(),
            ),
            new Text(
              '\$' + price.toStringAsFixed(2),
              style: titleLightWhiteOSR(),
            ),
          ],
        ),
        onPressed: _checkIfCartIsAvailable,
        splashColor: secondary,
      ),
    );
  }

  void _checkIfCartIsAvailable() {
    Common.getCart().then((onValue) {
      if (onValue == null) {
        _goToCart();
      } else {
        if (onValue['location'] == widget.locationInfo['_id']) {
          _goToCart();
        } else {
          _showClearCartAlert();
        }
      }
    });
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CartPage(
          product: cartProduct,
          taxInfo: widget.taxInfo,
          locationInfo: widget.locationInfo,
        ),
      ),
    );
  }

  Future<void> _showClearCartAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear cart?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'You have some items already in your cart from other location remove to add this!'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Common.removeCart();
                _goToCart();
              },
            ),
            FlatButton(
              child: Text('No'),
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
