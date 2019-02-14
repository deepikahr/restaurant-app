import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'order-upcoming.dart';
import 'order-history.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text("Orders"),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Material(
              color: PRIMARY,
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "Upcoming",
                      style: subTitleWhiteLightOSR(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "History",
                      style: subTitleWhiteLightOSR(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  OrderUpcoming(
                    isRatingAllowed: false,
                  ),
                  OrderHistory(
                    isRatingAllowed: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
