import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../screens/other/order-upcoming.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';

import 'package:RestaurantSaas/localizations.dart' show MyLocalizations;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class OrderHistory extends StatefulWidget {
  final bool isRatingAllowed;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  OrderHistory(
      {Key key, this.isRatingAllowed, this.localizedValues, this.locale})
      : super(key: key);
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory>
    with TickerProviderStateMixin {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();

  getDelieveredOrders() async {
    return await ProfileService.getDeliveredOrdersList();
  }

  @override
  void initState() {
    super.initState();
    getGlobalSettingsData();
  }

  String currency = '';

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getDelieveredOrders(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          if (data.length > 0) {
            return OrderUpcomingState.buildOrderList(
                data,
                widget.isRatingAllowed,
                context,
                widget.locale,
                widget.localizedValues,
                currency);
          } else {
            return OrderUpcomingState.buildEmptyPage(context);
          }
        });
  }
}
