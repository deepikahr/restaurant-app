import 'dart:async';

import 'package:RestaurantSaas/styles/styles.dart' as prefix0;
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
import 'package:getwidget/getwidget.dart';

SentryError sentryError = new SentryError();

class OrderTrack extends StatefulWidget {
  final String orderId;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  OrderTrack({Key key, this.orderId, this.locale, this.localizedValues})
      : super(key: key);

  @override
  OrderTrackState createState() => OrderTrackState();
}

class OrderTrackState extends State<OrderTrack> {
  final GlobalKey<AsyncLoaderState> _asyncLoader =
      GlobalKey<AsyncLoaderState>();

  Future<Map<String, dynamic>> getOrderTrack(String orderId) async {
    return await ProfileService.getOrderById(orderId);
  }

  @override
  void initState() {
    super.initState();
//    selectedLanguages();
    getGlobalSettingsData();
  }

  String currency = "";

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  Widget _retriveOrderTrack() {
    return AsyncLoader(
        key: _asyncLoader,
        initState: () async => await getOrderTrack(widget.orderId),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          return trackOrderList(data);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithTitle(
        context,
        MyLocalizations.of(context).trackOrder,
      ),
      body: _retriveOrderTrack(),
    );
  }

  Widget trackOrderList(order) {
    String status;
    if (order['status'] == "Accepted") {
      status = MyLocalizations.of(context).accepted;
    } else if (order['status'] == "On the way.") {
      status = MyLocalizations.of(context).ontheWay;
    } else if (order['status'] == "Delivered") {
      status = MyLocalizations.of(context).delivered;
    } else if (order['status'] == "Cancelled") {
      status = MyLocalizations.of(context).cancelled;
    } else if (order['status'] == "Pending") {
      status = MyLocalizations.of(context).pending;
    } else {
      status = order['status'];
    }

    return ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: 1,
        padding: EdgeInsets.only(top: 16),
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
              child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      order['productDetails'][0]['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                order['productDetails'][0]['imageUrl'],
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
                            order['productDetails'][0]['restaurant'],
                            style: textMuliSemiboldm(),
                          ),
                          Text(
                            MyLocalizations.of(context).type +
                                ": " +
                                order['orderType'],
                            style: textMuliRegularxswithop(),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(bottom: 5, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            '${MyLocalizations.of(context).orderID} : ',
                            style: textMuliRegularxswithop(),
                          ),
                          Text(
                            order['orderID'].toString(),
                            style: textMuliRegularxswithop(),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Order On :',
                            style: textMuliRegularxswithop(),
                          ),
                          Text(
                            order['createdAtTime'] == null
                                ? ""
                                : DateFormat('dd-MMM-yy hh:mm a').format(
                                    new DateTime.fromMillisecondsSinceEpoch(
                                        order['createdAtTime']),
                                  ),
                            style: textMuliRegularxswithop(),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            '${MyLocalizations.of(context).status} :',
                            style: textMuliRegularxsgreen(),
                          ),
                          Text(
                            status,
                            style: textMuliRegularxsgreen(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(
                        bottom: 10, left: 15, right: 15, top: 10),
                    child: MySeparator(color: secondary.withOpacity(0.2))),
                ListView.builder(
                    itemCount: order['productDetails'].length,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            order['productDetails'][index]['title'],
                            style: textMuliSemiboldxs(),
                          ),
                          Text(
                            '$currency' +
                                order['productDetails'][index]['totalPrice']
                                    .toStringAsFixed(2),
                            style: textMuliSemiboldxs(),
                          ),
                        ],
                      );
                    }),
                order['orderType'] == 'Pickup'
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${MyLocalizations.of(context).pickUpTime} : ',
                      style: textMuliSemiboldxsgreen(),
                    ),
                    Text(
                      '${order['pickupDate'] == null ? "" : order['pickupDate']} '
                          ' ${order['pickupTime'] == null ? "" : order['pickupTime']}',
                      style: textMuliSemiboldxsgreen(),
                    ),
                  ],
                )
                    : Container(),
                SizedBox(height: 20),
                orderTrack(order),
              ],
            ),
          ));
        });
  }

  Widget orderTrack(order) {
    return ListView.builder(
        itemCount: order['userNotification'].length,
        physics: ScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (BuildContext context, int index) {
          String status;
          if (order['userNotification'][index]['status'] == "Pending") {
            status = MyLocalizations.of(context).pending;
          } else if (order['userNotification'][index]['status'] ==
              "Order Accepted by vendor.") {
            status = MyLocalizations.of(context).orderAcceptedbyvendor;
          } else if (order['userNotification'][index]['status'] ==
              "Your order is on the way.") {
            status = MyLocalizations.of(context).yourorderisontheway;
          } else if (order['userNotification'][index]['status'] ==
              "Your order has been delivered,Share your experience with us.") {
            order['userNotification'][index]['status'] =
                MyLocalizations.of(context)
                    .yourorderhasbeendeliveredshareyourexperiencewithus;
          } else if (order['userNotification'][index]['status'] ==
              "Your order is cancelled,sorry for inconvenience.") {
            order['userNotification'][index]['status'] =
                MyLocalizations.of(context)
                    .yourorderiscancelledsorryforinconvenience;
          } else {
            status = order['userNotification'][index]['status'];
          }

          return GFListTile(
            avatar: Column(
              children: <Widget>[
                GFAvatar(
                  backgroundColor: Colors.green,
                  radius: 6,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomPaint(painter: LineDashedPainter()),
              ],
            ),
            title: Text(
              status,
              style: textMuliSemiboldgreen(),
            ),
            subtitle: Text(
              DateFormat('dd-MMM-yy hh:mm a').format(
                  new DateTime.fromMillisecondsSinceEpoch(
                      order['userNotification'][index]['time'] ?? 0)),
              style: textMuliRegularsm(),
            ),
            icon: Padding(
              padding: const EdgeInsets.only(right: 68.0, bottom: 10),
              child: Image.asset(
                'lib/assets/icons/tick.png',
                width: 24,
                height: 14,
              ),
            ),
          );
        });
  }

  static String readTimestamp(int timestamp, context) {
    var now = new DateTime.now();
    var format = new DateFormat('hh:mma dd/MM/yyyy');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    String time = '';
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time =
            diff.inDays.toString() + ' ${MyLocalizations.of(context).dayAgo}';
      } else {
        time =
            diff.inDays.toString() + ' ${MyLocalizations.of(context).daysAgo}';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() +
            ' ${MyLocalizations.of(context).weekAgo}';
      } else {
        time = (diff.inDays / 7).floor().toString() +
            ' ${MyLocalizations.of(context).weeksAgo}';
      }
    }
    return time;
  }
}

class LineDashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..strokeWidth = 1;
    var max = 55;
    var dashWidth = 3;
    var dashSpace = 4;
    double startY = 0;
    while (max >= 0) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      final space = (dashSpace + dashWidth);
      startY += space;
      max -= space;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
