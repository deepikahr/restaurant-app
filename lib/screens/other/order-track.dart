import 'dart:async';

import 'package:RestaurantSaas/styles/styles.dart' as prefix0;
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'package:intl/intl.dart';
import '../../services/profile-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/sentry-services.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class OrderTrack extends StatefulWidget {
  final String orderId;
  final Map localizedValues;
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
              message:
                  MyLocalizations.of(context).getLocalizations("ERROR_MSG"),
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
        backgroundColor: prefix0.PRIMARY,
        iconTheme: IconThemeData(color: Colors.white),
        title: new Text(
          MyLocalizations.of(context).getLocalizations("TRACK_ORDER"),
        ),
      ),
      body: _retriveOrderTrack(),
    );
  }

  Widget _buildOrderTrackBody(Map<String, dynamic> order) {
    String status;
    if (order['status'] == "Accepted") {
      status = MyLocalizations.of(context).getLocalizations("ACCEPTED");
    } else if (order['status'] == "On the way.") {
      status = MyLocalizations.of(context).getLocalizations("ON_THE_WAY");
    } else if (order['status'] == "Delivered") {
      status = MyLocalizations.of(context).getLocalizations("DELIVERED");
    } else if (order['status'] == "Cancelled") {
      status = MyLocalizations.of(context).getLocalizations("CANCELLED");
    } else if (order['status'] == "Pending") {
      status = MyLocalizations.of(context).getLocalizations("PENDING");
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
                                color: PRIMARY,
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
                              MyLocalizations.of(context)
                                      .getLocalizations("ORDER_PROGRSS") +
                                  '...',
                              style: textOSl(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(5.0)),
                    Column(
                      children: <Widget>[
                        new Text(MyLocalizations.of(context)
                                .getLocalizations("ORDER_ID", true) +
                            order['orderID'].toString()),
                        new Text(
                          MyLocalizations.of(context)
                                  .getLocalizations("STATUS", true) +
                              status,
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
                  status =
                      MyLocalizations.of(context).getLocalizations("PENDING");
                } else if (order['userNotification'][index]['status'] ==
                    "Order Accepted by vendor.") {
                  status = MyLocalizations.of(context)
                      .getLocalizations("ORDER_ACCEPTED");
                } else if (order['userNotification'][index]['status'] ==
                    "Your order is on the way.") {
                  status = MyLocalizations.of(context)
                      .getLocalizations("ORDER_ON_THE_WAY");
                } else if (order['userNotification'][index]['status'] ==
                    "Your order has been delivered,Share your experience with us.") {
                  order['userNotification'][index]['status'] =
                      MyLocalizations.of(context)
                          .getLocalizations("ORDER_DELIVERD_MSG");
                } else if (order['userNotification'][index]['status'] ==
                    "Your order is cancelled,sorry for inconvenience.") {
                  order['userNotification'][index]['status'] =
                      MyLocalizations.of(context)
                          .getLocalizations("ORDER_CANCELLED_MSG");
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
                                    color: PRIMARY,
                                  ),
                                ),
                                new Container(
                                  width: 3.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(
                                      left: 9.0, top: 5.0, right: 9.0),
                                  decoration: new BoxDecoration(
                                    border: Border.all(color: PRIMARY),
                                    color: PRIMARY,
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
}
