import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/profile-service.dart';
import 'order-details.dart';
import 'order-track.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class OrderUpcoming extends StatefulWidget {
  final bool isRatingAllowed;
  final Map<String, Map<String, String>> localizedValues;
  var locale;
  OrderUpcoming({Key key, this.isRatingAllowed, this.locale, this.localizedValues}) : super(key: key);

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

  String currency;

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
    print('currency............. $currency');
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
            return buildOrderList(data, widget.isRatingAllowed, context, widget.locale, widget.localizedValues, currency);
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

  static Widget buildOrderList(List<dynamic> orders, bool isRatingAllowed, context, var locale,  Map<String, Map<String, String>> localizedValues,
      String currency) {
    return Container(
      color: Colors.grey[300],
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: orders.length,
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 13.0),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: screenWidth(context),
            margin: EdgeInsetsDirectional.only(top: 8.0),
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                _buildImageHead(
                    orders[index]['productDetails'][0]['imageUrl'],
                    orders[index]['productDetails'].length,
                    orders[index]['status'],
                    context),
                _buildOrderInfo(
                    orders[index]['status'],
                    'Date',
                    orders[index]['orderID'],
                    context,
                    isRatingAllowed,
                    orders[index]['_id'],locale,
                  localizedValues,),
                _buildProductList(orders[index]['productDetails'], currency),
                _buildBottomPriceLine(
                    context,
                    double.parse(orders[index]['grandTotal'].toString()),
                    orders[index]['paymentOption'],
                    orders[index]['createdAt'].substring(0, 10),
                  currency
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildImageHead(
      String imgUrl, int itemCount, String status, BuildContext context) {
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
          height: 85.0,
          width: screenWidth(context),
        ),
        Column(
          children: <Widget>[
            Text(
              itemCount.toString() + ' item',
              style: titleLightWhiteOSR(),
            ),
            Text(
              MyLocalizations.of(context).status + ': $status',
              style: hintStyleSmallWhiteBoldOSL(),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildOrderInfo(String status, String time, int orderId,
      BuildContext context, bool isRatingAllowed, String orderIdUniq, var locale,
      Map<String, Map<String, String>> localizedValues,) {
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
                  color: PRIMARY,
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
                  status,
                  style: hintStyleSmallDarkBoldOSL(),
                ),
                // Text(time, style: titleBlackLightOSB()),
                Text(
                  "Order ID: " + orderId.toString(),
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
                          builder: (BuildContext context) =>
                              OrderDetails(orderId: orderIdUniq, locale: locale, localizedValues: localizedValues,),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              OrderTrack(orderId: orderIdUniq, locale: locale, localizedValues: localizedValues, ),
                        ),
                      );
                    }
                  },
                  fillColor: PRIMARY,
                  child: new Text(
                    isRatingAllowed ? MyLocalizations.of(context).view :
                    MyLocalizations.of(context).track,
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

  static Widget _buildProductList(List<dynamic> products, String currency) {
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
          child: Container(
            padding: EdgeInsetsDirectional.only(top: 5.0, bottom: 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      (index + 1).toString(),
                      style: hintStyleSmallDarkBoldOSL(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Text(
                    products[index]['title'],
                    style: hintStyleSmallDarkBoldOSL(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                      '$currency' + products[index]['totalPrice'].toStringAsFixed(2)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildBottomPriceLine(context,
      double total, String paymentMode, String time, String currency) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsetsDirectional.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                MyLocalizations.of(context).total + ": $currency" + total.toStringAsFixed(2),
                style: titleBold(),
              ),
              Text(
              MyLocalizations.of(context).paymentMode + ":" + paymentMode,
                style: hintStyleSmallDarkBoldOSL(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(MyLocalizations.of(context).chargesIncluding),
              Text(
                time,
                style: hintStyleSmallDarkBoldOSL(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
