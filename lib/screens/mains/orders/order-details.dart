import 'dart:async';

import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/localizations.dart';
import '../../../services/profile-service.dart';
import '../../../services/sentry-services.dart';
import '../../../styles/styles.dart';
import '../../../widgets/no-data.dart';
import 'ratings.dart';

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
          return ListView(
            children: <Widget>[
              SizedBox(height: 20),
              restaurantInfo(data),
              deliveredaddress(data),
              billdetails(data),
              // deliveredtime(data),
            ],
          );
          // _buildOrderDetailsBody(data);
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
      backgroundColor: Colors.white,
      appBar:
          appBarWithTitle(context, MyLocalizations.of(context).orderDetails),
      body: _retriveOrderDetails(),
    );
  }

  Widget restaurantInfo(orderData) {
    String tableNumber = '';
    if (orderData['tableNumber'] != null) {
      tableNumber =
          ' for Table number : ' + orderData['tableNumber'].toString();
    }

    return Container(
      color: bg,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  orderData['productDetails'][0]['imageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            orderData['productDetails'][0]['imageUrl'],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "lib/assets/bgImgs/loginbg.png",
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                  SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        orderData['productDetails'][0]['restaurant'],
                        style: textMuliSemiboldm(),
                      ),
                      Text(
                        MyLocalizations.of(context).type +
                            ": " +
                            orderData['orderType'] +
                            tableNumber,
                        style: textMuliRegularxswithop(),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Order ID:',
                        style: textMuliRegularxswithop(),
                      ),
                      Text(
                        orderData['orderID'].toString(),
                        style: textMuliRegularxswithop(),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Order On:',
                        style: textMuliRegularxswithop(),
                      ),
                      Text(
                        orderData['createdAtTime'] == null
                            ? ""
                            : DateFormat('dd-MMM-yy hh:mm a').format(
                                new DateTime.fromMillisecondsSinceEpoch(
                                    orderData['createdAtTime']),
                              ),
                        style: textMuliRegularxswithop(),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'status:',
                        style: textMuliRegularxsgreen(),
                      ),
                      Text(
                        orderData['status'],
                        style: textMuliRegularxsgreen(),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 14),
            MySeparator(color: secondary.withOpacity(0.2)),
            SizedBox(height: 14),
            ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: orderData['productDetails'].length,
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  if (orderData['productRating'] != null) {
                    orderData['productRating'].forEach((item) {
                      if (item['product'] ==
                          orderData['productDetails'][index]['productId']) {
                        orderData['productDetails'][index]['RatingInfo'] = item;
                      }
                    });
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        orderData['productDetails'][index]['title'],
                        style: textMuliSemiboldxs(),
                      ),
                      (orderData['productDetails'][index]['RatingInfo'] == null)
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => Rating(
                                      orderId: orderData['_id'],
                                      productId: orderData['productDetails']
                                          [index]['productId'],
                                      locationId: orderData['location'],
                                      restaurantId: orderData['restaurantID'],
                                    ),
                                  ),
                                );
                              },
                              child: new Text(
                                MyLocalizations.of(context).rate,
                                textAlign: TextAlign.start,
                                style: textred(),
                              ),
                            )
                          : Row(
                              children: <Widget>[
                                Text(
                                  orderData['productDetails'][index]
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
                            ),
                      Text(
                        '$currency' +
                            orderData['productDetails'][index]['totalPrice']
                                .toStringAsFixed(2),
                        style: textMuliSemiboldxs(),
                      ),
                    ],
                  );
                }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget deliveredaddress(orderData) {
    if (orderData['orderDataType'] == "Pickup") {
      orderData['orderDataType'] = MyLocalizations.of(context).pickUp;
    } else if (orderData['orderDataType'] == "Dine In") {
      orderData['orderDataType'] = MyLocalizations.of(context).dineIn;
    } else if (orderData['orderDataType'] == "Delivery") {
      orderData['orderDataType'] = MyLocalizations.of(context).dELIVERY;
    } else {
      orderData['orderDataType'] = orderData['orderType'];
    }
    print('sh ${orderData['shippingAddress']}');
    return Container(
      color: bg,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15.0),
        child: orderData['orderType'] == "Pickup"
            ? deliveredtime(orderData)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Delivered at:',
                    style: textMuliBold(),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      '${orderData['shippingAddress']['flatNo']}, ${orderData['shippingAddress']['address']}, '
                      '${orderData['shippingAddress']['contactNumber']}, ${orderData['shippingAddress']['postalCode']}',
                      style: textMuliRegularwithop(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget billdetails(orderData) {
    return Container(
      color: bg,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bill Details',
              style: textMuliBold(),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  MyLocalizations.of(context).subTotal,
                  style: textMuliRegulars(),
                ),
                Text(
                  '$currency' + orderData['subTotal'].toStringAsFixed(2),
                  style: textMuliRegulars(),
                ),
              ],
            ),
            SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  MyLocalizations.of(context).deliveryCharges,
                  style: textMuliRegulars(),
                ),
                Text(
                  '$currency' + orderData['deliveryCharge'].toStringAsFixed(2),
                  style: textMuliRegulars(),
                ),
              ],
            ),
            SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  MyLocalizations.of(context).grandTotal,
                  style: textMuliRegulars(),
                ),
                Text(
                  '$currency' + orderData['grandTotal'].toStringAsFixed(2),
                  style: textMuliBoldlg(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget deliveredtime(orderData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${MyLocalizations.of(context).pickUpTime} : ',
          style: textMuliRegularMgreen(),
        ),
        Text(
          '${orderData['pickupDate'] == null ? "" : orderData['pickupDate']} '
          ' ${orderData['pickupTime'] == null ? "" : orderData['pickupTime']}',
          style: textMuliRegularMgreen(),
        ),
      ],
    );
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
