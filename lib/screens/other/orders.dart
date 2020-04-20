import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'order-upcoming.dart';
import 'order-history.dart';
import '../../services/localizations.dart';

class OrdersPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  OrdersPage({Key key, this.locale, this.localizedValues}) : super(key: key);
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
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(MyLocalizations.of(context).myOrders),
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
                      MyLocalizations.of(context).upcoming,
                      style: subTitleWhiteLightOSR(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      MyLocalizations.of(context).history,
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
      ),
    );
  }
}
