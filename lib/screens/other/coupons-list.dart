import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/constant.dart';
import '../../styles/styles.dart';
import '../../services/main-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/sentry-services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class CouponsList extends StatefulWidget {
  final String locationId;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

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
        supportedLocales: LANGUAGES.map((language) => Locale(language, '')),
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
                      return couponCard(
                        data[index],
                      );
                    });
              } else {
                return Container(
                  child: Text('Invalid response'),
                );
              }
            },
          ),
        ));
  }

  Widget couponCard(Map data) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCardHeader(data),
            buildCuisineHolder(data),
            buildCardBottom(context, data),
          ],
        ),
      ),
    );
  }

  Widget buildCardHeader(Map coupon) {
    return Row(
      children: [
        Expanded(
          child: Text(
            coupon['couponName'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              height: 1.0,
            ),
          ),
          flex: 6,
        ),
      ],
    );
  }

  Widget buildCuisineHolder(Map coupon) {
    return Text(
      coupon['description'].toUpperCase(),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 11.0,
        height: 1.4,
      ),
    );
  }

  Widget buildCardBottom(BuildContext context, Map coupon) {
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: Row(
                children: <Widget>[
                  Text(coupon['offPrecentage'].toString() + '% off',
                      style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, coupon);
                },
                child: Text(MyLocalizations.of(context).apply,
                    style: TextStyle(color: Colors.amber)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildEmptyPage(String msg) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: NoData(message: msg),
    );
  }
}
