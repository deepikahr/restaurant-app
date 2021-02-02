import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:flutter/material.dart';
import '../../services/common.dart';
import '../../styles/styles.dart';

class ThankYou extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
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
    Common.removeCart();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.27),
            Center(
                child: Image.asset(
              'lib/assets/images/thnku.png',
              width: 226,
              height: 114,
            )),
            SizedBox(height: 6),
            Text(
              'Order Placed!',
              style: textMuliBoldlgprimary(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              "Thank You",
              style: textMuliSemiboldblue(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: 335,
        height: 41,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.09), blurRadius: 0)
            ]),
        child: RaisedButton(
          color: Color(0xFFF6F6F6),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0),
          ),
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
          child: Text(
            'Home',
            style: textMuliSemibold(),
          ),
        ),
      ),
      // Container(
      //   color: primary,
      //   height: screenHeight(context),
      //   width: screenWidth(context),
      //   alignment: AlignmentDirectional.center,
      //   child: Stack(
      //     alignment: AlignmentDirectional.center,
      //     children: <Widget>[
      //       Container(
      //         height: 280.0,
      //         color: Colors.black12,
      //         padding: EdgeInsets.all(16.0),
      //         margin: EdgeInsets.all(16.0),
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: <Widget>[
      //             Text(
      //               MyLocalizations.of(context).thankYou,
      //               style: titleWhiteOSR(),
      //             ),
      //             Text(
      //               MyLocalizations.of(context).orderPlaced,
      //               style: subTitleWhiteShadeLightOSR(),
      //             ),
      //             Text(
      //               MyLocalizations.of(context).thankYouMessage,
      //               style: hintStyleGreyLightOSRDescription(),
      //               textAlign: TextAlign.center,
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 36.0),
      //               child: RawMaterialButton(
      //                 onPressed: () {
      //                   Navigator.pushAndRemoveUntil(
      //                       context,
      //                       MaterialPageRoute(
      //                           builder: (BuildContext context) => HomePage(
      //                                 localizedValues: widget.localizedValues,
      //                                 locale: widget.locale,
      //                               )),
      //                       (Route<dynamic> route) => false);
      //                 },
      //                 fillColor: Colors.white,
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: <Widget>[
      //                     Text(
      //                       MyLocalizations.of(context).backTo,
      //                       style: hintStyleprimaryLightOSR(),
      //                     ),
      //                     Icon(
      //                       Icons.home,
      //                       color: primary,
      //                       size: 18.0,
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
