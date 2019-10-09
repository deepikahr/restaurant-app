import 'package:RestaurantSass/screens/mains/cart.dart';
import 'package:RestaurantSass/screens/other/CounterModel.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'location-list-sheet.dart';
import 'home.dart';

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
      setState(() {
        cartCount = res;
      });
      print("responce   $cartCount");
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(
          widget.restaurantInfo['list']['restaurantName'],
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[
          // HomePageState.buildCartIcon(context)
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CartPage(),
                  ),
                );
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: (cartCount == null || cartCount == 0)
                        ? Text(
                            '',
                            style: TextStyle(fontSize: 14.0),
                          )
                        : Text(
                            '${cartCount.toString()}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.shopping_cart)),
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
