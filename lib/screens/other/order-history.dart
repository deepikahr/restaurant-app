import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../screens/other/order-upcoming.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';


SentryError sentryError = new SentryError();


class OrderHistory extends StatefulWidget {
  final bool isRatingAllowed;
  final Map<String, Map<String, String>> localizedValues;
  var locale;

  OrderHistory({Key key, this.isRatingAllowed, this.localizedValues, this.locale}) : super(key: key);
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
                data, widget.isRatingAllowed, context);
          } else {
            return OrderUpcomingState.buildEmptyPage(context);
          }
        });
  }
}
