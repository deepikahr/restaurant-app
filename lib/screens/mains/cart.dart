import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'confirm-order.dart';
import '../../services/common.dart';
import '../../widgets/no-data.dart';
import '../auth/login.dart';
import '../other/coupons-list.dart';

class CartPage extends StatefulWidget {
  Map<String, dynamic> product, taxInfo, locationInfo;

  CartPage({Key key, this.product, this.taxInfo, this.locationInfo})
      : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double deliveryCharge = 0.0, subTotal = 0.0, grandTotal = 0.0, tax = 0.0;
  List<dynamic> products;
  Map<String, dynamic> cartItems = {};
  int productsLength = 0;
  Map<String, dynamic> selectedCoupon;
  double couponDeduction = 0.0;

  @override
  void initState() {
    _calculateCart();
    super.initState();
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

    // [2] add new product to cart products list. remove first if already available
    products = cart != null ? cart['productDetails'] ?? [] : [];
    if (widget.product != null) {
      products.removeWhere(
          (item) => item['productId'] == widget.product['productId']);
      products.add(widget.product);
    }

    // [3] calculate sub total
    subTotal = 0.0;
    products.forEach((item) {
      subTotal = subTotal + item['totalPrice'];
    });

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
      if (deliveryInfo['freeDelivery']) {
        if (deliveryInfo['amountEligibility'] > subTotal) {
          deliveryCharge =
              double.parse(deliveryInfo['deliveryCharges'].toString());
        }
      } else {
        deliveryCharge = double.parse(deliveryInfo['deliveryCharges']);
      }
    }

    // [6] calculate grand total
    grandTotal = subTotal + tax + deliveryCharge;

    // [7] create complete order json as Map
    cart = {
      'deliveryCharge': deliveryCharge,
      'grandTotal': grandTotal,
      'location':
          widget.locationInfo != null ? widget.locationInfo['_id'] : null,
      'locationName': widget.locationInfo != null
          ? widget.locationInfo['locationName']
          : null,
      'orderType': 'Home Delivery',
      'payableAmount': grandTotal,
      'paymentOption': 'COD',
      'position': null,
      'loyalty': null,
      'shippingAddress': null,
      'restaurant': products.length > 0 ? products[0]['restaurant'] : null,
      'restaurantID': products.length > 0 ? products[0]['restaurantID'] : null,
      'status': 'Pending',
      'subTotal': subTotal,
      'taxInfo': widget.taxInfo,
      'productDetails': products,
      'coupon': selectedCoupon == null
          ? {'couponApplied': false}
          : {'couponApplied': true, 'couponName': selectedCoupon['couponName']}
    };

    // [8] set cart state and save to storage
    if (widget.locationInfo != null) {
      await Common.setCart(cart);
      setState(() {
        cartItems = cart;
        productsLength = products.length;
      });
    }
  }

  void _goToCoupons() async {
    selectedCoupon = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CouponsList(
              locationId: cartItems['location'],
            ),
      ),
    );
    _calculateCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: new Text(
          'Your Cart',
          style: titleBoldWhiteOSS(),
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
                            padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
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
                      _buildPriceTagLine('Sub Total', subTotal),
                      Divider(),
                      widget.taxInfo != null
                          ? _buildPriceTagLine(
                              'Tax ' + widget.taxInfo['taxName'], tax)
                          : Container(height: 0, width: 0),
                      widget.taxInfo != null
                          ? Divider()
                          : Container(height: 0, width: 0),
                      _buildPriceTagLine('Delivery Charge', deliveryCharge),
                      Divider(),
                      _buildPriceTagLine('Grand Total', grandTotal),
                      Divider(),
                    ],
                  ),
                  Container(
                    color: border,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: NoData(
                message: 'Your Cart is Empty',
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
          return ListTile(
            trailing: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: new Text(
                      'x' + products[index]['Quantity'].toString(),
                      textAlign: TextAlign.center,
                      style: hintStylePrimaryOSR(),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: new Text(
                    '\$' + products[index]['totalPrice'].toStringAsFixed(2),
                    style: titleBlackBoldOSB(),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: PRIMARY,
                      size: 20.0,
                    ),
                    onPressed: () async {
                      products.removeAt(index);
                      widget.product = null;
                      if (products.length == 0) {
                        cartItems = null;
                      }
                      await Common.setCart(cartItems);
                      _calculateCart();
                    },
                  ),
                ),
              ],
            ),
            leading: new Text(
              products[index]['title'],
              style: subTitleDarkLightOSS(),
            ),
          );
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
            '\$' + value.toStringAsFixed(2),
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
              "REVIEW AND COMPLETE YOUR ORDER",
              style: subTitleWhiteLightOSR(),
            ),
            new Padding(padding: EdgeInsets.only(top: 5.0)),
            new Text(
              'Total: \$' + grandTotal.toStringAsFixed(2),
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
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        );
      } else {
        msg = 'Success';
      }
      if (msg == 'Success') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ConfrimOrderPage(
                  cart: cartItems,
                  deliveryInfo: widget.locationInfo['deliveryInfo']
                      ['deliveryInfo'])),
        );
      }
    });
  }

  Widget _buildApplyCouponLine() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: _goToCoupons,
          child: Text(
            'Apply Coupon',
            style: titleBlackLightOSBCoupon(),
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 10)),
        selectedCoupon != null
            ? InkWell(
                onTap: () {
                  setState(() {
                    selectedCoupon = null;
                  });
                  _calculateCart();
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
}
