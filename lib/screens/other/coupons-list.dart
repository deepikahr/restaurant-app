import 'package:flutter/material.dart';
import '../../widgets/coupon-card.dart';
import '../../styles/styles.dart';
import '../../services/main-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

SentryError sentryError = new SentryError();

class CouponsList extends StatefulWidget {
  final String locationId;
  final Map<String, Map<String, String>> localizedValues;
  var locale;

  CouponsList({Key key, this.locationId, this.locale, this.localizedValues})
      : super(key: key);

  @override
  _CouponsListState createState() => _CouponsListState();
}

class _CouponsListState extends State<CouponsList> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();

  Future<dynamic> getCouponsByLocationId() async {
    return await MainService.getCouponsByLocationId(widget.locationId);
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
          backgroundColor: whiteTextb,
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            backgroundColor: PRIMARY,
            title: new Text(MyLocalizations.of(context).coupon,
                style: titleBoldWhiteOSS()),
            centerTitle: true,
          ),
          body: AsyncLoader(
            key: _asyncLoaderState,
            initState: () async => await getCouponsByLocationId(),
            renderLoad: () => Center(child: CircularProgressIndicator()),
            renderError: ([error]) {
              sentryError.reportError(error, null);
              return NoData(
                  message: MyLocalizations.of(context).connectionError,
                  icon: Icons.block);
            },
            renderSuccess: ({data}) {
              if (data is Map<String, dynamic> && data['message'] != null) {
                return buildEmptyPage(data['message']);
              } else if (data.length > 0) {
                return ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CouponCard(
                        coupon: data[index],
                      );
                    });
              }
            },
          ),
        ));
  }

  static Widget buildEmptyPage(String msg) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: NoData(message: msg),
    );
  }
}
