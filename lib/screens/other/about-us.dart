import 'package:RestaurantSaas/services/constant.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/localizations.dart';

class AboutUs extends StatefulWidget {
  final Map localizedValues;
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
        title: Text(MyLocalizations.of(context).getLocalizations("ABOUT_US")),
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
                    APP_NAME,
                    style: titleBoldOSL(),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      MyLocalizations.of(context)
                          .getLocalizations("SHORT_DISCRIPTION"),
                      style: textOSL(),
                    ),
                  ),
                  new Text(
                    MyLocalizations.of(context).getLocalizations("DISCRIPTION"),
                    style: textOS(),
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      MyLocalizations.of(context)
                          .getLocalizations("CONTACT_NUMBER"),
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
                      MyLocalizations.of(context).getLocalizations("EMAIL_ID"),
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
                      MyLocalizations.of(context).getLocalizations("ADDRESS"),
                      style: textOSL(),
                    ),
                  ),
                  new Text(
                    '1440 , South end , A road , Marenahalli, Bangalore',
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
