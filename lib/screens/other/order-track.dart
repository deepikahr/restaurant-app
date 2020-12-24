import 'dart:async';

import 'package:RestaurantSaas/styles/styles.dart' as prefix0;
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/localizations.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';

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
          return _buildOrderTrackBody(data);
        });
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
          ),
        ),
        backgroundColor: prefix0.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: new Text(
          MyLocalizations.of(context).trackOrder,
          style: textbarlowSemiBoldWhite(),
        ),
      ),
      body: _retriveOrderTrack(),
    );
  }

  Widget _buildOrderTrackBody(Map<String, dynamic> order) {
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

    return SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
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
                              width: 25.0,
                              height: 25.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
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
                          new Padding(
                            padding: EdgeInsets.only(left: 6.0, right: 6.0),
                            child: new Text(
                              MyLocalizations.of(context).orderProgress + '...',
                              style: textOSl(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(5.0)),
                    Column(
                      children: <Widget>[
                        new Text(MyLocalizations.of(context).orderID +
                            ': ' +
                            order['orderID'].toString()),
                        new Text(
                          MyLocalizations.of(context).status + ': ' + status,
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: order['userNotification'].length,
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

                return new Padding(
                  padding: EdgeInsets.all(10.0),
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
                                // Padding(
                                //     padding:
                                //         EdgeInsets.only(top: 0.0, bottom: 10)),
                                new Container(
                                  width: 20.0,
                                  height: 15.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary,
                                  ),
                                ),
                                new Container(
                                  width: 3.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(
                                      left: 9.0, top: 5.0, right: 9.0),
                                  decoration: new BoxDecoration(
                                    border: Border.all(color: primary),
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 12,
                            fit: FlexFit.tight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Text(
                                  (index + 1).toString() + '. ' + status,
                                  style: textOSl(),
                                ),
                                // new Padding(padding: EdgeInsets.only(top: 5.0)),
                                new Text(
                                  DateFormat('dd-MMM-yy hh:mm a').format(
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          order['userNotification'][index]
                                                  ['time'] ??
                                              0)),
                                  style: textOS(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          Divider(),
        ],
      ),
    );
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
