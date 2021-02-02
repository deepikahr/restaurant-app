import 'package:RestaurantSaas/widgets/card.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/localizations.dart';
import '../../../services/profile-service.dart';
import '../../../services/sentry-services.dart';
import '../../../styles/styles.dart';
import '../../../widgets/no-data.dart';

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
        },
      ),
    );
  }
}
