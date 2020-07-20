import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:flutter/material.dart';

import '../../services/common.dart';
import '../../services/localizations.dart';
import '../../styles/styles.dart';

class ThankYou extends StatefulWidget {
  final Map localizedValues;
  final String locale;

  ThankYou({Key key, this.localizedValues, this.locale}) : super(key: key);

  @override
  _ThankYouState createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    Common.addProduct([]);
    Common.removeCart();
    return Scaffold(
      body: Container(
        color: PRIMARY,
        height: screenHeight(context),
        width: screenWidth(context),
        alignment: AlignmentDirectional.center,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              height: 280.0,
              color: Colors.black12,
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    MyLocalizations.of(context).getLocalizations("THANK_YOU"),
                    style: titleWhiteOSR(),
                  ),
                  Text(
                    MyLocalizations.of(context)
                        .getLocalizations("ORDER_PLACED"),
                    style: subTitleWhiteShadeLightOSR(),
                  ),
                  Text(
                    MyLocalizations.of(context)
                        .getLocalizations("THANK_YOU_MSG"),
                    style: hintStyleGreyLightOSRDescription(),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => HomePage(
                                      localizedValues: widget.localizedValues,
                                      locale: widget.locale,
                                    )),
                            (Route<dynamic> route) => false);
                      },
                      fillColor: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            MyLocalizations.of(context)
                                .getLocalizations("BACK_TO"),
                            style: hintStylePrimaryLightOSR(),
                          ),
                          Icon(
                            Icons.home,
                            color: PRIMARY,
                            size: 18.0,
                          ),
                        ],
                      ),
                    ),
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
