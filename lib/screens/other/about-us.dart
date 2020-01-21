import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

class AboutUs extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  var locale;
  AboutUs({Key key, this.locale, this.localizedValues}) : super(key: key);
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
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
          centerTitle: true,
          title: Text(MyLocalizations.of(context).aboutUs),
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
              new Image.asset('lib/assets/imgs/chicken.png'),
              new Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Text(
                        MyLocalizations.of(context).restaurantSass,
                        style: titleBoldOSL(),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: new Text(
                          MyLocalizations.of(context).shortDescription,
                          style: textOSL(),
                        ),
                      ),
                      new Text(
                        'Grilled Chicken Lorem ipsum dolor sit amet, consectetur adipiscing elit,'
                        ' sed do eiusmod tempor incididunt ut labore et dolore magna ',
                        style: textOS(),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: new Text(
                          MyLocalizations.of(context).mobileNumber,
                          style: textOSL(),
                        ),
                      ),
                      new Text(
                        '90989098000',
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
                        '1440 , South end , A road , Marenahalli, Bangalore',
                        style: textOS(),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
