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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(
          widget.restaurantInfo['list']['restaurantName'],
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[HomePageState.buildCartIcon(context)],
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
