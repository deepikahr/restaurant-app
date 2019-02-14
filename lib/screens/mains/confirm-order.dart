import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'add-address.dart';
import 'payment-method.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/profile-service.dart';
import 'dart:core';
import '../../services/main-service.dart';

class ConfrimOrderPage extends StatefulWidget {
  final Map<String, dynamic> cart, deliveryInfo;

  ConfrimOrderPage({Key key, this.cart, this.deliveryInfo}) : super(key: key);

  @override
  _ConfrimOrderPageState createState() => _ConfrimOrderPageState();
}

class _ConfrimOrderPageState extends State<ConfrimOrderPage> {
  int selectedAddressIndex = 0;
  double remainingLoyaltyPoint = 0.0;
  double usedLoyaltyPoint = 0.0;
  bool isLoyaltyApplied = false;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateAddress =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Map<String, dynamic>> _getUserInfo() async {
    Map<String, dynamic> userInfo;
    await ProfileService.getUserInfo().then((onValue) {
      userInfo = onValue;
    });
    await MainService.getLoyaltyInfoByRestaurantId(widget.cart['restaurantID'])
        .then((onValue) {
      userInfo['loyaltyInfo'] = onValue;
      remainingLoyaltyPoint = userInfo['totalLoyaltyPoints'];
    });
    return userInfo;
  }

  Future<List<dynamic>> _getAddressList() async {
    return await ProfileService.getAddressList();
  }

  @override
  Widget build(BuildContext context) {
    AsyncLoader _asyncLoader = AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _getUserInfo(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          return _buildConfirmOrderView(data);
        });

    return Scaffold(
      backgroundColor: whiteTextb,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: new Text(
          'Review Your Order',
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
      ),
      body: _asyncLoader,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildConfirmOrderView(Map<String, dynamic> userInfo) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        alignment: AlignmentDirectional.topStart,
        color: greyc,
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            _buildHeader(),
            new Column(
              children: <Widget>[
                _buildBulletTitle(1, 'Contact Information'),
                _buildContactBlock(userInfo['name'],
                    userInfo['contactNumber'].toString(), userInfo),
                _buildBulletTitle(2, 'Select Address'),
                _buildAddressList(),
                _buildBulletTitle(3, 'Order Details'),
                _buildProductListBlock(userInfo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.black12,
      padding: EdgeInsets.all(10.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                'Date:',
                style: hintStyleSmallWhiteLightOSL(),
              ),
              new Text(
                DateTime.now().toString().substring(0, 10),
                style: hintStyleSmallWhiteLightOSL(),
              ),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                'Total Order:',
                style: hintStyleSmallWhiteLightOSL(),
              ),
              new Text(
                '\$' + widget.cart['grandTotal'].toStringAsFixed(2),
                style: hintStyleSmallWhiteLightOSL(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletTitle(int number, String title) {
    return Container(
      color: greyc,
      child: new Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: new Row(
          children: <Widget>[
            new Container(
              width: 22.0,
              height: 22.0,
              alignment: AlignmentDirectional.center,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: primaryLight,
              ),
              child: new Text(
                number.toString(),
                textAlign: TextAlign.center,
                style: hintStyleLightOSB(),
              ),
            ),
            new Padding(padding: EdgeInsets.all(5.0)),
            new Text(title, style: hintStyleSmallDarkOSB())
          ],
        ),
      ),
    );
  }

  Widget _buildContactBlock(
      String title, String value, Map<String, dynamic> userInfo) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              'Name',
              style: hintStyleOSB(),
            ),
            new Text(
              title,
              style: hintLightOSR(),
            ),
            new Divider(),
            new Text(
              'Phone',
              style: hintStyleOSB(),
            ),
            new Text(
              value,
              style: hintLightOSR(),
            ),
            Divider(),
            userInfo['loyaltyInfo']['minLoyalityPoints'] <
                    userInfo['totalLoyaltyPoints']
                ? Row(
                    children: <Widget>[
                      Checkbox(
                        value: isLoyaltyApplied,
                        onChanged: (bool value) {
                          double points = 0.0;
                          widget.cart['grandTotal'] =
                              widget.cart['payableAmount'];
                          if (value) {
                            if (userInfo['totalLoyaltyPoints'] >=
                                widget.cart['grandTotal']) {
                              points = userInfo['totalLoyaltyPoints'] -
                                  widget.cart['grandTotal'];
                              widget.cart['grandTotal'] = 0.0;
                            } else {
                              widget.cart['grandTotal'] =
                                  widget.cart['grandTotal'] -
                                      userInfo['totalLoyaltyPoints'];
                              points = 0.0;
                            }
                          } else {
                            points = double.parse(
                                userInfo['totalLoyaltyPoints'].toString());
                          }
                          setState(() {
                            remainingLoyaltyPoint = points;
                            isLoyaltyApplied = value;
                          });
                        },
                        activeColor: PRIMARY,
                      ),
                      Text(
                        'Use Loyalty Points',
                        style: hintStyleSmallDarkLightOSR(),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: new Text(
                            remainingLoyaltyPoint.toStringAsFixed(2),
                            textAlign: TextAlign.end,
                            style: hintStyleTitleBlueOSR(),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: Text('You dont have enough loyalty points. Minimum ' +
                        userInfo['loyaltyInfo']['minLoyalityPoints']
                            .toString() +
                        ' points required to use it, You have only ' +
                        userInfo['totalLoyaltyPoints'].toStringAsFixed(2) +
                        ' points on your account! Place orders to get more.'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList() {
    return AsyncLoader(
        key: _asyncLoaderStateAddress,
        initState: () async => await _getAddressList(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          if (widget.cart['shippingAddress'] == null) {
            widget.cart['shippingAddress'] = data.length > 0 ? data[0] : null;
          }
          return Padding(
            padding: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              bottom: 10.0,
            ),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(right: 0.0),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (data[index]['isSelected'] == null)
                        data[index]['isSelected'] = false;
                      return RadioListTile(
                        groupValue: selectedAddressIndex,
                        value: index,
                        selected: data[index]['isSelected'],
                        onChanged: (int selected) {
                          setState(() {
                            selectedAddressIndex = selected;
                            data[index]['isSelected'] =
                                !data[index]['isSelected'];
                            widget.cart['shippingAddress'] = data[index];
                          });
                        },
                        activeColor: PRIMARY,
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              data[index]['name'],
                              style: hintStyleSmallTextDarkOSR(),
                            ),
                            new Text(
                              data[index]['address'],
                              style: hintStyleSmallTextDarkOSR(),
                            ),
                            new Text(
                              data[index]['contactNumber'].toString(),
                              style: hintStyleSmallTextDarkOSR(),
                            ),
                            new Text(
                              data[index]['zip'].toString(),
                              style: hintStyleSmallTextDarkOSR(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(),
                  InkWell(
                    onTap: () async {
                      Map<String, dynamic> address = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => AddAddressPage(),
                        ),
                      );
                      if (address != null &&
                          address['name'] != null &&
                          address['address'] != null &&
                          address['zip'] != null) {
                        data.add(address);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.add_circle,
                          color: PRIMARY,
                          size: 18.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            ' Add Address',
                            style: textPrimaryOSR(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildProductListBlock(Map<String, dynamic> userInfo) {
    List<dynamic> products = widget.cart['productDetails'];
    usedLoyaltyPoint = (userInfo['totalLoyaltyPoints'] - remainingLoyaltyPoint);
    return Padding(
      padding: EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0, bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 6,
                          fit: FlexFit.tight,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                products[index]['title'],
                                style: subTitleDarkLightOSS(),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          fit: FlexFit.tight,
                          child: new Text(
                            'x' + products[index]['Quantity'].toString(),
                            textAlign: TextAlign.start,
                            style: hintStylePrimaryOSR(),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: new Text(
                            '\$' +
                                products[index]['totalPrice']
                                    .toStringAsFixed(2),
                            style: hintStyleOSB(),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.info,
                  color: PRIMARY,
                  size: 18.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    ' Order Summary',
                    style: textPrimaryOSR(),
                  ),
                )
              ],
            ),
            Divider(),
            _buildTotalPriceLine('Sub Total', widget.cart['subTotal']),
            widget.cart['taxInfo'] != null
                ? _buildTotalPriceLine(
                    'Tax ' + widget.cart['taxInfo']['taxName'],
                    double.parse(widget.cart['taxInfo']['taxRate'].toString()))
                : Container(height: 0, width: 0),
            _buildTotalPriceLine(
                'Delivery Charge',
                widget.cart['deliveryCharge'] == 'Free'
                    ? '0.0'
                    : widget.cart['deliveryCharge']),
            _buildTotalPriceLine('Grand Total',
                double.parse(widget.cart['grandTotal'].toString())),
            _buildTotalPriceLine('Used Loyalty Point', usedLoyaltyPoint),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPriceLine(String title, double value) {
    return Container(
      height: 40.0,
      color: greyc,
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(
            title,
            style: titleBlackLightOSB(),
          ),
          new Text(
            '\$' + value.toStringAsFixed(2),
            style: textLightOSR(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return RawMaterialButton(
      onPressed: () {
        if (widget.cart['shippingAddress'] != null &&
            widget.deliveryInfo != null) {
          if (widget.deliveryInfo['areaAthority']) {
            _buildBottomBarButton();
          } else {
            if (widget.deliveryInfo['areaCode'] == null ||
                widget.deliveryInfo['areaCode'][0] == null) {
              _buildBottomBarButton();
            } else {
              bool isPinFound = false;
              for (int i = 0; i < widget.deliveryInfo['areaCode'].length; i++) {
                if (widget.deliveryInfo['areaCode'][i]['pinCode'].toString() ==
                    widget.cart['shippingAddress']['zip'].toString()) {
                  isPinFound = true;
                }
              }
              if (isPinFound) {
                _buildBottomBarButton();
              } else {
                _showAvailablePincodeAlert(
                    widget.cart['restaurant'],
                    widget.cart['shippingAddress']['zip'].toString(),
                    widget.deliveryInfo['areaCode']);
              }
            }
          }
        } else {
          showSnackbar('Please Add address first');
        }
      },
      child: new Row(
        children: <Widget>[
          Expanded(
            child: new Container(
              height: 70.0,
              color: PRIMARY,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(top: 10.0)),
                  new Text(
                    "PLACE ORDER NOW",
                    style: subTitleWhiteLightOSR(),
                  ),
                  new Padding(padding: EdgeInsets.only(top: 5.0)),
                  new Text(
                    'Total: \$' + widget.cart['grandTotal'].toStringAsFixed(2),
                    style: titleWhiteBoldOSB(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _buildBottomBarButton() {
    widget.cart['loyalty'] = double.parse(usedLoyaltyPoint.toStringAsFixed(2));
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => PaymentMethod(cart: widget.cart),
        ));
  }

  Future<void> _showAvailablePincodeAlert(
      String restaurant, String zip, List<dynamic> pins) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delivery Not availble here!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(restaurant +
                    ' does not deliver to ' +
                    zip +
                    ' available pincodes are listed here!'),
                Divider(),
                SingleChildScrollView(
                  child: ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pins.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Text(pins[index]['pinCode'].toString()),
                        );
                      }),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
