import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'order-upcoming.dart';
import 'order-history.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';

class OrdersPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  var locale;
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
      ),
    );
  }
}
