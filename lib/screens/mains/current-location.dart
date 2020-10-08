import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:location/location.dart';

class CurrentLocation extends StatefulWidget {
  final Map localizedValues;
  final String locale;

  const CurrentLocation({
    Key key,
    this.localizedValues,
    this.locale,
  }) : super(key: key);

  @override
  _CurrentLocationState createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Location location = Location();
  var locationData;
  var locationAddress, locationAddressMap;

  PlacePickerResult pickedLocation;
  LocationData currentLocation;
  Location _location = new Location();

  Map<String, dynamic> position;

  var addressData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        title: Text(
          MyLocalizations.of(context).deliveryLocation,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 50),
          Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Image.asset("lib/assets/imgs/man.png")),
          SizedBox(height: 30),
          buildLocation(),
          SizedBox(height: 30),
          buildSelectedlocation()
        ],
      ),
      bottomNavigationBar: locationData != null
          ? Container(
              height: 55,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.29), blurRadius: 5)
                  ]),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                color: PRIMARY,
                // blockButton: true,
                onPressed: _saveCurrentLocation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      MyLocalizations.of(context).saveandProceed,
                      style: textbarlowSemiBoldWhite(),
                    ),
                  ],
                ),
              ),
            )
          : Container(height: 1),
    );
  }

  Widget buildSelectedlocation() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            locationAddress == null && locationAddressMap == null
                ? MyLocalizations.of(context).selectlocation
                : locationAddress == null
                    ? locationAddressMap
                    : locationAddress.addressLine,
            style: textbarlowSemiBoldBlack(),
          ),
        ));
  }

  Widget buildLocation() {
    return Container(
      width: 305,
      height: 44,
      margin: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        onPressed: _getCurrentLocation,
        color: PRIMARY,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "lib/assets/icon/location1.png",
              width: 20,
              height: 20,
            ),
            SizedBox(width: 10),
            Text(
              MyLocalizations.of(context).useCurrentLocation,
              style: textbarlowSemiBoldWhite(),
            ),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        locationAddressMap = null;
      });
    }
    currentLocation = await _location.getLocation();
    final coordinates =
        new Coordinates(currentLocation.latitude, currentLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    addressData = first.addressLine;
    if (currentLocation != null && mounted) {
      setState(() {
        locationData = currentLocation;
        locationAddress = addresses.first;
        position = {
          'lat': currentLocation.latitude,
          'long': currentLocation.longitude,
          'name': addressData
        };
      });
      await Common.savePositionInfo(position).then((onValue) {});
    }
  }

  showError(error, message) async {
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            top: 10.0,
          ),
          title: new Text(
            "$error",
            style: hintSfsemiboldb(),
            textAlign: TextAlign.center,
          ),
          content: Container(
            height: 100.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: new Text(
                    "$message",
                    style: hintSfLightsm(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Divider(),
                    IntrinsicHeight(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 12.0),
                                height: 30.0,
                                decoration: BoxDecoration(),
                                child: Text(
                                  MyLocalizations.of(context).ok,
                                  style: hintSfLightbig(),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveCurrentLocation() async {
    if (locationData != null) {
      position = {
        'lat': currentLocation.latitude,
        'long': currentLocation.longitude,
        'name': addressData
      };
      await Common.savePositionInfo(position).then((onValue) {});
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomePage(
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      showError(
          MyLocalizations.of(context).enableTogetlocation,
          MyLocalizations.of(context)
              .thereisproblemusingyourdevicelocationPleasecheckyourGPSsettings);
    }
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
