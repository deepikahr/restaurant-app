import 'package:RestaurantSaas/widgets/appbar.dart';
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
      backgroundColor: bg,
      appBar: appBarWithTitle(context, MyLocalizations.of(context).aboutUs),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                SizedBox(
                  height: 35,
                ),
                Image.asset(
                  'lib/assets/icons/logo.png',
                  width: 80,
                  height: 108,
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: "RESTAURANT", style: textMuliBoldprimary()),
                        TextSpan(
                          text: ' SAAS',
                          style: textMuliBold(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Description', style: textMuliSemiboldsec()),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                    'Lorem ipsum dolor sit amet, consetetur sadipscing Stet clita  sadipscing',
                    style: textMuliRegularwithop(),
                  ),
                ),
              ],
            ),
          ),
          Container(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(MyLocalizations.of(context).address,
                      style: textMuliSemiboldsec()),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    'Saudi Arabia Eastern province Saihat',
                    style: textMuliRegularwithop(),
                  ),
                ],
              )),
          Container(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(MyLocalizations.of(context).contactInformation,
                      style: textMuliSemiboldsec()),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    MyLocalizations.of(context).mobileNumber,
                    style: textMuliBold(),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    '9098909800',
                    style: textMuliRegularwithop(),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    MyLocalizations.of(context).emailId,
                    style: textMuliBold(),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    'ionicfirebaseapp@gmail.com',
                    style: textMuliRegularwithop(),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
