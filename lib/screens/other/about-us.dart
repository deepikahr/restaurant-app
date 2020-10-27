import 'package:RestaurantSaas/services/constant.dart';
import 'package:flutter/material.dart';

import '../../services/localizations.dart';
import '../../styles/styles.dart';

class AboutUs extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  AboutUs({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          MyLocalizations.of(context).aboutUs,
          style: textbarlowSemiBoldWhite(),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: new SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
                child:
                    new Image.asset('lib/assets/logos/logo.png', height: 200)),
            new Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Text(
                    APP_NAME,
                    style: titleBoldOSL(),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      MyLocalizations.of(context).mobileNumber,
                      style: textOSL(),
                    ),
                  ),
                  new Text(
                    '9098909800',
                    style: textOS(),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      MyLocalizations.of(context).emailId,
                      style: textOSL(),
                    ),
                  ),
                  new Text(
                    'ionicfirebaseapp@gmail.com',
                    style: textOS(),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      MyLocalizations.of(context).address,
                      style: textOSL(),
                    ),
                  ),
                  new Text(
                    'Saudi Arabia Eastern province Saihat',
                    style: textOS(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
