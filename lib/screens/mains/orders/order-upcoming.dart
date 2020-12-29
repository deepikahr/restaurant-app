import 'package:RestaurantSaas/widgets/card.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/localizations.dart';
import '../../../services/profile-service.dart';
import '../../../services/sentry-services.dart';
import '../../../styles/styles.dart';
import '../../../widgets/no-data.dart';
import 'order-details.dart';
import 'order-track.dart';

SentryError sentryError = new SentryError();

class OrderUpcoming extends StatefulWidget {
  final bool isRatingAllowed;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  OrderUpcoming(
      {Key key, this.isRatingAllowed, this.locale, this.localizedValues})
      : super(key: key);

  @override
  OrderUpcomingState createState() => OrderUpcomingState();
}

class OrderUpcomingState extends State<OrderUpcoming>
    with TickerProviderStateMixin {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();

  getNonDelieveredOrders() async {
    return await ProfileService.getNonDeliveredOrdersList();
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

  @override
  Widget build(BuildContext context) {
    return AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getNonDelieveredOrders(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          if (data.length > 0) {
            return buildOrderList(data, widget.isRatingAllowed, context,
                widget.locale, widget.localizedValues, currency);
          } else {
            return buildEmptyPage(context);
          }
        });
  }

  static Widget buildEmptyPage(context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: NoData(message: MyLocalizations.of(context).noCompletedOrders),
    );
  }

  static Widget buildOrderList(
      List<dynamic> orders,
      bool isRatingAllowed,
      context,
      final String locale,
      Map<String, Map<String, String>> localizedValues,
      String currency) {
    return Container(
      color: bg,
      margin: EdgeInsets.only(top: 10),
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          if (orders[index]['status'] == "Accepted") {
            orders[index]['status'] = MyLocalizations.of(context).accepted;
          } else if (orders[index]['status'] == "On the way.") {
            orders[index]['status'] = MyLocalizations.of(context).ontheWay;
          } else if (orders[index]['status'] == "Delivered") {
            orders[index]['status'] = MyLocalizations.of(context).delivered;
          } else if (orders[index]['status'] == "Cancelled") {
            orders[index]['status'] = MyLocalizations.of(context).cancelled;
          } else if (orders[index]['status'] == "Pending") {
            orders[index]['status'] = MyLocalizations.of(context).pending;
          } else {
            orders[index]['status'] = orders[index]['status'];
          }
          if (orders[index]['orderType'] == "Pickup") {
            orders[index]['orderType'] = MyLocalizations.of(context).pickUp;
          } else if (orders[index]['orderType'] == "Dine In") {
            orders[index]['orderType'] = MyLocalizations.of(context).dineIn;
          } else if (orders[index]['orderType'] == "Delivery") {
            orders[index]['orderType'] = MyLocalizations.of(context).dELIVERY;
          } else {
            orders[index]['orderType'] = orders[index]['orderType'];
          }
          return orderCard(context, orders[index], isRatingAllowed, locale,
              localizedValues, currency);
          // return Container(
          //   width: screenWidth(context),
          //   margin: EdgeInsetsDirectional.only(top: 8.0),
          //   color: Colors.white,
          //   padding: EdgeInsets.all(10),
          //   child: Column(
          //     children: <Widget>[
          //       _buildImageHead(
          //           orders[index]['productDetails'][0]['imageUrl'],
          //           orders[index]['productDetails'].length,
          //           orders[index]['productDetails'][0]['restaurant'],
          //           orders[index]['status'],
          //           orders[index]['orderType'],
          //           orders[index]['tableNumber'],
          //           orders[index]['pickupDate'] == null
          //               ? ""
          //               : orders[index]['pickupDate'],
          //           orders[index]['pickupTime'] == null
          //               ? ""
          //               : orders[index]['pickupTime'],
          //           context),
          //       _buildOrderInfo(
          //           orders[index]['orderType'],
          //           orders[index]['status'],
          //           'Date',
          //           orders[index]['orderID'],
          //           context,
          //           isRatingAllowed,
          //           orders[index]['_id'],
          //           locale,
          //           localizedValues),
          //       _buildProductList(
          //           orders[index]['productDetails'],
          //           orders[index]['_id'],
          //           orders[index]['restaurantID'],
          //           orders[index]['location'],
          //           isRatingAllowed,
          //           currency),
          //       _buildBottomPriceLine(
          //           double.parse(orders[index]['grandTotal'].toString()),
          //           orders[index]['paymentOption'],
          //           orders[index]['createdAtTime'] == null
          //               ? ""
          //               : DateFormat('dd-MMM-yy hh:mm a').format(
          //                   new DateTime.fromMillisecondsSinceEpoch(
          //                       orders[index]['createdAtTime']),
          //                 ),
          //           context,
          //           currency)
          //     ],
          //   ),
          // );
        },
      ),
    );
  }

  static Widget _buildImageHead(
      String imgUrl,
      int itemCount,
      String restaurantName,
      String status,
      String orderType,
      int tableNumber,
      String date,
      String time,
      BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.passthrough,
      children: <Widget>[
        Image(
          image: imgUrl != null
              ? NetworkImage(imgUrl)
              : AssetImage("lib/assets/bgImgs/loginbg.png"),
          fit: BoxFit.fill,
          color: Colors.black54,
          colorBlendMode: BlendMode.darken,
          height: 95.0,
          width: screenWidth(context),
        ),
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular((3.0)),
                color: greyTextc,
              ),
              child: Column(children: <Widget>[
                Text(
                  restaurantName,
                  style: titleLightWhiteOSR(),
                ),
                Text(
                  itemCount.toString() + ' ' + MyLocalizations.of(context).item,
                  style: hintStyleSmallWhiteBoldOSL(),
                ),
                Text(
                  MyLocalizations.of(context).status + ": " + status,
                  style: hintStyleSmallWhiteBoldOSL(),
                ),
                Text(
                  MyLocalizations.of(context).type + ": " + orderType,
                  style: hintStyleSmallWhiteBoldOSL(),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
            ),
            orderType == 'Pickup'
                ? Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular((3.0)),
                      color: primary,
                    ),
                    child: Text(
                      MyLocalizations.of(context).pickUpTime +
                          ": " +
                          date +
                          "  " +
                          time,
                      style: hintStyleSmallWhiteBoldOSL(),
                    ))
                : Container(),
            tableNumber != null
                ? Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular((3.0)),
                      color: primary,
                    ),
                    child: Text(
                      MyLocalizations.of(context).tableNo +
                          ".: " +
                          tableNumber.toString(),
                      style: hintStyleSmallWhiteBoldOSL(),
                    ))
                : Container()
          ],
        ),
      ],
    );
  }

  static Widget _buildOrderInfo(
      String type,
      String status,
      String time,
      int orderId,
      BuildContext context,
      bool isRatingAllowed,
      String orderIdUniq,
      final String locale,
      Map<String, Map<String, String>> localizedValues) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: primary,
                  size: 24.0,
                ),
              ],
            ),
          ),
          Flexible(
            flex: 12,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  type + ' : ' + status,
                  style: hintStyleSmallDarkBoldOSL(),
                ),
                Text(
                  MyLocalizations.of(context).orderID +
                      ": " +
                      orderId.toString(),
                  style: titleBlackLightOSB(),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RawMaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  onPressed: () {
                    if (isRatingAllowed) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => OrderDetails(
                            orderId: orderIdUniq,
                            locale: locale,
                            localizedValues: localizedValues,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => OrderTrack(
                            orderId: orderIdUniq,
                            locale: locale,
                            localizedValues: localizedValues,
                          ),
                        ),
                      );
                    }
                  },
                  fillColor: primary,
                  child: new Text(
                    isRatingAllowed
                        ? MyLocalizations.of(context).view
                        : MyLocalizations.of(context).track,
                    style: hintStylesmallWhiteLightOSL(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildProductList(
      List<dynamic> products,
      String orderId,
      String restaurantId,
      String locationId,
      bool isRatingAllowed,
      String currency) {
    return ListView.builder(
      itemCount: products.length,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: border, width: 1.0),
              top: BorderSide(color: border, width: 1.0),
            ),
          ),
          padding: EdgeInsetsDirectional.only(top: 5.0, bottom: 5.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    (index + 1).toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: hintStyleSmallDarkBoldOSL(),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Text(
                  products[index]['title'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: hintStyleSmallDarkBoldOSL(),
                ),
              ),
              isRatingAllowed
                  ? Expanded(
                      flex: 2,
                      child: (products[index]['productRating'] == null)
                          ? Container()
                          : Container(
                              child: Row(
                              children: <Widget>[
                                Text(
                                  products[index]['productDetails'][index]
                                          ['RatingInfo']
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
                    )
                  : Expanded(flex: 0, child: Container()),
              Expanded(
                flex: 3,
                child: Text(
                  '$currency' +
                      products[index]['totalPrice'].toStringAsFixed(2),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  static Widget _buildBottomPriceLine(
      double total, String paymentMode, String time, context, String currency) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsetsDirectional.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "${MyLocalizations.of(context).grandTotal}: $currency" +
                    total.toStringAsFixed(2),
                style: hintStyleSmallDarkBoldOSL(),
              ),
              Text(
                "${MyLocalizations.of(context).paymentMode}: " +
                    (paymentMode == 'Stripe' || paymentMode == "CREDIT CARD"
                        ? 'CC'
                        : paymentMode),
                overflow: TextOverflow.ellipsis,
                style: hintStyleSmallDarkBoldOSL(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(MyLocalizations.of(context).chargesIncluding),
              Text(
                time == null ? "" : time.toString(),
                style: hintStyleSmallDarkBoldOSL(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
