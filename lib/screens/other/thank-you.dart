import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/common.dart';

class ThankYou extends StatefulWidget {
  @override
  _ThankYouState createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  @override
  Widget build(BuildContext context) {
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
                    "Thank you",
                    style: titleWhiteOSR(),
                  ),
                  Text(
                    "Your Order has been placed",
                    style: subTitleWhiteShadeLightOSR(),
                  ),
                  Text(
                    "We love our customer and try our best for better services, If there are any queries or any concern then please letus know",
                    style: hintStyleGreyLightOSRDescription(),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      fillColor: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Back to ",
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
