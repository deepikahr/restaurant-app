import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:flutter/material.dart';

import '../../services/localizations.dart';
import '../../styles/styles.dart';
import 'order-history.dart';
import 'order-upcoming.dart';
import 'package:getwidget/getwidget.dart';

class OrdersPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  OrdersPage({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithTitle(context, MyLocalizations.of(context).myOrders),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Container(
              height: 40,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20, left: 45, right: 45, bottom: 20),
              child: GFSegmentTabs(
                tabController: tabController,
                width: 280,
                // initialIndex: 0,
                length: 2,
                tabs: const <Widget>[
                  Text(
                    'Upcoming',
                  ),
                  Tab(
                    child: Text(
                      'History',
                    ),
                  ),
                ],
                tabBarColor: GFColors.LIGHT,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: GFColors.WHITE,
                labelStyle: textMuliRegularwhitesm(),
                unselectedLabelStyle: textMuliRegularsmsec(),
                unselectedLabelColor: Color(0xFF53596B),
                indicator: const BoxDecoration(
                  color: Color(0xFFFF9C5D),
                ),
                borderRadius: BorderRadius.circular(6),
                indicatorPadding: const EdgeInsets.all(8),
                indicatorWeight: 2,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 140,
            child: GFTabBarView(
              controller: tabController,
              children: <Widget>[
                OrderUpcoming(
                  isRatingAllowed: false,
                  locale: widget.locale,
                  localizedValues: widget.localizedValues,
                ),
                OrderHistory(
                  isRatingAllowed: true,
                  locale: widget.locale,
                  localizedValues: widget.localizedValues,
                ),
              ],
            ),
          ),
        ],
      ),
      // DefaultTabController(
      //   length: 2,
      //   child: Column(
      //     children: <Widget>[
      //       Material(
      //         color: primary,
      //         child: TabBar(
      //           tabs: [
      //             Tab(
      //               child: Text(
      //                 MyLocalizations.of(context).upcoming,
      //                 style: subTitleWhiteLightOSR(),
      //               ),
      //             ),
      //             Tab(
      //               child: Text(
      //                 MyLocalizations.of(context).history,
      //                 style: subTitleWhiteLightOSR(),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       Expanded(
      //         child: TabBarView(
      //           children: [
      //             OrderUpcoming(
      //               isRatingAllowed: false,
      //               locale: widget.locale,
      //               localizedValues: widget.localizedValues,
      //             ),
      //             OrderHistory(
      //               isRatingAllowed: true,
      //               locale: widget.locale,
      //               localizedValues: widget.localizedValues,
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
