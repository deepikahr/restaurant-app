import 'dart:async';

import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/localizations.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';
import '../other/ratings.dart';

SentryError sentryError = new SentryError();

class OrderDetails extends StatefulWidget {
  final String orderId;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  OrderDetails({Key key, this.orderId, this.localizedValues, this.locale})
      : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final GlobalKey<AsyncLoaderState> _asyncLoader =
      GlobalKey<AsyncLoaderState>();
  String currency = '';

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    return await ProfileService.getOrderById(orderId);
  }

  Widget _retriveOrderDetails() {
    return AsyncLoader(
        key: _asyncLoader,
        initState: () async => await getOrderDetails(widget.orderId),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
            message: MyLocalizations.of(context).connectionError,
            icon: Icons.block,
          );
        },
        renderSuccess: ({data}) {
          return _buildOrderDetailsBody(data);
        });
  }

  @override
  void initState() {
    getGlobalSettingsData();
    super.initState();
  }

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: PRIMARY,
        iconTheme: IconThemeData(color: Colors.white),
        title: new Text(
          MyLocalizations.of(context).orderDetails,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
      ),
      body: _retriveOrderDetails(),
    );
  }

  Widget _buildOrderDetailsBody(Map<String, dynamic> order) {
    String tableNumber = '';
    if (order['tableNumber'] != null) {
      tableNumber = ' for Table number : ' + order['tableNumber'].toString();
    }
    if (order['orderType'] == "Pickup") {
      order['orderType'] = MyLocalizations.of(context).pickUp;
    } else if (order['orderType'] == "Dine In") {
      order['orderType'] = MyLocalizations.of(context).dineIn;
    } else if (order['orderType'] == "Delivery") {
      order['orderType'] = MyLocalizations.of(context).dELIVERY;
    } else {
      order['orderType'] = order['orderType'];
    }
    return SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          order['orderType'] == 'Delivery'
              ? Padding(
                  padding: EdgeInsets.all(20.0),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(top: 0.0)),
                                  new Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: PRIMARY,
                                    ),
                                  ),
                                  new Container(
                                    width: 3.0,
                                    height: 80.0,
                                    margin:
                                        EdgeInsets.only(left: 9.0, top: 5.0),
                                    decoration: new BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )),
                          order['shippingAddress'] != null
                              ? Flexible(
                                  flex: 12,
                                  fit: FlexFit.tight,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      new Text(
                                        MyLocalizations.of(context)
                                            .deliveryAddress,
                                        style: textOSl(),
                                      ),
                                      new Padding(
                                          padding: EdgeInsets.only(top: 20.0)),
                                      new Text(
                                        MyLocalizations.of(context).flatNumber +
                                            ': ' +
                                            order['shippingAddress']['flatNo'],
                                        style: textOS(),
                                      ),
                                      new Text(
                                        MyLocalizations.of(context).address +
                                            ': ' +
                                            order['shippingAddress']['address'],
                                        style: textOS(),
                                      ),
                                      new Text(
                                        MyLocalizations.of(context)
                                                .mobileNumber +
                                            ': ' +
                                            order['shippingAddress']
                                                ['contactNumber'],
                                        style: textOS(),
                                      ),
                                      new Text(
                                        MyLocalizations.of(context).postalCode +
                                            ': ' +
                                            order['shippingAddress']
                                                    ['postalCode']
                                                .toString(),
                                        style: textOS(),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      )
                    ],
                  ),
                )
              : Container(),
          new Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.black12,
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: PRIMARY,
                              ),
                            ),
                          ],
                        )),
                    Flexible(
                        flex: 12,
                        fit: FlexFit.tight,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new Padding(padding: EdgeInsets.only(top: 0.0)),
                            new Text(
                              'Thanks for ordering',
                              style: textOSl(),
                            ),
                            Text(
                              MyLocalizations.of(context).orderType +
                                  ' : ' +
                                  order['orderType'] +
                                  tableNumber,
                              style: textOSl(),
                            ),
                          ],
                        ))
                  ],
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 35.0, top: 3.0, bottom: 10.0),
                  child: new Text(
                    MyLocalizations.of(context).restaurant +
                        ': ' +
                        // order['restaurant'].toString() +
                        order['productDetails'][0]['restaurant'] +
                        ', ' +
                        MyLocalizations.of(context).orderID +
                        ' :' +
                        order['orderID'].toString(),
                    style: textOSl(),
                  ),
                ),
                ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: order['productDetails'].length,
                    itemBuilder: (BuildContext context, int index) {
                      if (order['productRating'] != null) {
                        order['productRating'].forEach((item) {
                          if (item['product'] ==
                              order['productDetails'][index]['productId']) {
                            order['productDetails'][index]['RatingInfo'] = item;
                          }
                        });
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: new Text(
                              order['productDetails'][index]['title'],
                              style: textOS(),
                            ),
                          ),
                          (order['productDetails'][index]['RatingInfo'] == null)
                              ? Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Rating(
                                            orderId: order['_id'],
                                            productId: order['productDetails']
                                                [index]['productId'],
                                            locationId: order['location'],
                                            restaurantId: order['restaurantID'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: new Text(
                                      MyLocalizations.of(context).rate,
                                      textAlign: TextAlign.start,
                                      style: textred(),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        order['productDetails'][index]
                                                ['RatingInfo']['rating']
                                            .toString(),
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                    ],
                                  )),
                          Expanded(
                            flex: 3,
                            child: new Text(
                              order['productDetails'][index]['Quantity']
                                      .toString() +
                                  'x$currency' +
                                  order['productDetails'][index]['price']
                                      .toStringAsFixed(2),
                              textAlign: TextAlign.end,
                              style: textOS(),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 25)),
                          Divider(),
                        ],
                      );
                    }),
                new Divider(
                  color: Colors.white,
                ),
                new Row(
                  children: <Widget>[
                    Expanded(
                        child: new Text(
                      MyLocalizations.of(context).subTotal,
                      style: textOS(),
                    )),
                    Expanded(
                        child: new Text(
                      '$currency' + order['subTotal'].toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: textOS(),
                    ))
                  ],
                ),
                new Padding(padding: EdgeInsets.all(5.0)),
                new Row(
                  children: <Widget>[
                    Expanded(
                        child: new Text(
                      MyLocalizations.of(context).deliveryCharges,
                      style: textOS(),
                    )),
                    Expanded(
                        child: new Text(
                      '$currency' + order['deliveryCharge'].toString(),
                      textAlign: TextAlign.end,
                      style: textOS(),
                    ))
                  ],
                ),
                new Padding(padding: EdgeInsets.all(5.0)),
                new Row(
                  children: <Widget>[
                    Expanded(
                        child: new Text(
                      MyLocalizations.of(context).grandTotal,
                      style: textOSl(),
                    )),
                    Expanded(
                        child: new Text(
                      '$currency' + order['grandTotal'].toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: textOSl(),
                    ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
