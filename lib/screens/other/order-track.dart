import 'package:RestaurantSaas/styles/styles.dart' as prefix0;
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'package:intl/intl.dart';
import '../../services/profile-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class OrderTrack extends StatefulWidget {
  final String orderId;
  final Map<String, Map<String, String>> localizedValues;
  var locale;
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
    return MaterialApp(
        locale: Locale(widget.locale),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          MyLocalizationsDelegate(widget.localizedValues),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: languages.map((language) => Locale(language, '')),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: prefix0.PRIMARY,
            iconTheme: IconThemeData(color: Colors.white),
            title: new Text(
              MyLocalizations.of(context).trackOrder,
            ),
          ),
          body: _retriveOrderTrack(),
        ));
  }

  Widget _buildOrderTrackBody(Map<String, dynamic> order) {
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
                          new Padding(padding: EdgeInsets.only(top: 0.0)),
                          new Text(
                            MyLocalizations.of(context).orderProgress + '...',
                            style: textOSl(),
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
                          MyLocalizations.of(context).status +
                              ': ' +
                              order['status'],
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
                                  margin: EdgeInsets.only(left: 9.0, top: 5.0),
                                  decoration: new BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.grey,
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
                                  (index + 1).toString() +
                                      '. ' +
                                      order['userNotification'][index]
                                          ['status'],
                                  style: textOSl(),
                                ),
                                // new Padding(padding: EdgeInsets.only(top: 5.0)),
                                new Text(
                                  DateFormat('dd-MMM-yy hh:mm a').format(
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          order['createdAtTime'])),
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

  static String readTimestamp(int timestamp) {
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
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }
    return time;
  }
}

//   Widget _buildOrderTrackBody(Map<String, dynamic> order) {
//     return SingleChildScrollView(
//       child: new Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.all(10.0),
//             color: Colors.black12,
//             child: new Column(
//               children: <Widget>[
//                 new Row(
//                   children: <Widget>[
//                     Flexible(
//                         flex: 2,
//                         fit: FlexFit.tight,
//                         child: new Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             new Container(
//                               width: 25.0,
//                               height: 25.0,
//                               decoration: new BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: PRIMARY,
//                               ),
//                               child: Icon(
//                                 Icons.check,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         )),
//                     Flexible(
//                       flex: 12,
//                       fit: FlexFit.tight,
//                       child: new Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: <Widget>[
//                           new Padding(padding: EdgeInsets.only(top: 0.0)),
//                           new Text(
//                             MyLocalizations.of(context).orderProgress,
//                             style: textOSl(),
//                           ),
//                           new Text(
//                             '...',
//                             style: textOSl(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     new Padding(padding: EdgeInsets.all(5.0)),
//                     Column(
//                       children: <Widget>[
//                         new Text('Order ID: ' + order['orderID'].toString()),
//                         new Text(
//                           MyLocalizations.of(context).status + ': ${order['status']}',
//                           style: TextStyle(color: Colors.green),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           ListView.builder(
//               physics: ScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: order['userNotification'].length,
//               itemBuilder: (BuildContext context, int index) {
//                 return new Padding(
//                   padding: EdgeInsets.all(10.0),
//                   child: new Column(
//                     children: <Widget>[
//                       new Row(
//                         children: <Widget>[
//                           Flexible(
//                             flex: 2,
//                             fit: FlexFit.tight,
//                             child: new Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 // Padding(
//                                 //     padding:
//                                 //         EdgeInsets.only(top: 0.0, bottom: 10)),
//                                 new Container(
//                                   width: 20.0,
//                                   height: 15.0,
//                                   decoration: new BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: PRIMARY,
//                                   ),
//                                 ),
//                                 new Container(
//                                   width: 3.0,
//                                   height: 10.0,
//                                   margin: EdgeInsets.only(left: 9.0, top: 5.0),
//                                   decoration: new BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Flexible(
//                             flex: 12,
//                             fit: FlexFit.tight,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: <Widget>[
//                                 new Text(
//                                   (index + 1).toString() +
//                                       '. ' +
//                                       order['userNotification'][index]
//                                           ['status'],
//                                   style: textOSl(),
//                                 ),
//                                 // new Padding(padding: EdgeInsets.only(top: 5.0)),
//                                 new Text(
//                                   readTimestamp(
//                                       order['userNotification'][index]['time'], context),
//                                   style: textOS(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//           Divider(),
//         ],
//       ),
//     );
//   }

//   static String readTimestamp(int timestamp, context) {
//     var now = new DateTime.now();
//     var format = new DateFormat('HH:mm a dd/MM/yyyy');
//     var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
//     var diff = now.difference(date);
//     String time = '';
//     if (diff.inSeconds <= 0 ||
//         diff.inSeconds > 0 && diff.inMinutes == 0 ||
//         diff.inMinutes > 0 && diff.inHours == 0 ||
//         diff.inHours > 0 && diff.inDays == 0) {
//       time = format.format(date);
//     } else if (diff.inDays > 0 && diff.inDays < 7) {
//       if (diff.inDays == 1) {
//         time = diff.inDays.toString() + ' ' + MyLocalizations.of(context).dayAgo;
//       } else {
//         time = diff.inDays.toString() + ' ' + MyLocalizations.of(context).daysAgo;
//       }
//     } else {
//       if (diff.inDays == 7) {
//         time = (diff.inDays / 7).floor().toString() + ' ' + MyLocalizations.of(context).weekAgo;
//       } else {
//         time = (diff.inDays / 7).floor().toString() + ' ' + MyLocalizations.of(context).weeksAgo;
//       }
//     }
//     return time;
//   }
// }
