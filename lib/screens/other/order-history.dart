import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../screens/other/order-upcoming.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';

SentryError sentryError = new SentryError();


class OrderHistory extends StatefulWidget {
  final bool isRatingAllowed;

  OrderHistory({Key key, this.isRatingAllowed}) : super(key: key);
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
              message: 'Please check your internet connection!',
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          if (data.length > 0) {
            return OrderUpcomingState.buildOrderList(
                data, widget.isRatingAllowed);
          } else {
            return OrderUpcomingState.buildEmptyPage();
          }
        });
  }
}
