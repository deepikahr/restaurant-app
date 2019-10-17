import 'package:RestaurantSaas/screens/mains/cart.dart';
import 'package:RestaurantSaas/screens/other/CounterModel.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'location-list-sheet.dart';
import 'home.dart';
import '../../services/sentry-services.dart';

SentryError sentryError = new SentryError();

class LocationListPage extends StatefulWidget {
  final Map<String, dynamic> restaurantInfo;
  final List<dynamic> locations;

  LocationListPage({Key key, this.restaurantInfo, this.locations})
      : super(key: key);

  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  int cartCount;
  @override
  Widget build(BuildContext context) {
    CounterModel().getCounter().then((res) {
      try {
        setState(() {
          cartCount = res;
        });
        print("responce   $cartCount");
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(
          "${widget.restaurantInfo['list']['restaurantName'][0].toUpperCase()}${widget.restaurantInfo['list']['restaurantName'].substring(1)}",
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CartPage(),
                  ),
                );
              },
              child: Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 20.0, right: 10),
                      child: Icon(Icons.shopping_cart)),
                  Positioned(
                      right: 3,
                      top: 5,
                      child: (cartCount == null || cartCount == 0)
                          ? Text(
                              '',
                              style: TextStyle(fontSize: 14.0),
                            )
                          : Container(
                              height: 20,
                              width: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: Text('${cartCount.toString()}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "bold",
                                      fontSize: 11)),
                            )),
                ],
              )),
          Padding(padding: EdgeInsets.only(left: 7.0)),
          // buildLocationIcon(),
          // Padding(padding: EdgeInsets.only(left: 7.0)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 10)),
            LocationListSheet.buildSheetHeader(
                widget.restaurantInfo['list']['logo'],
                widget.restaurantInfo['list']['restaurantName'],
                widget.restaurantInfo['list']['reviewCount']),
            LocationListSheet.buildOutletInfo(
                widget.restaurantInfo['locationCount']),
            Divider(),
            LocationListSheet.buildLocationSheetView(
                context, widget.locations, widget.restaurantInfo, false),
          ],
        ),
      ),
    );
  }
}
