import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentLocation extends StatefulWidget {
  final Map localizedValues;
  final String locale;

  const CurrentLocation({Key key, this.localizedValues, this.locale})
      : super(key: key);

  @override
  _CurrentLocationState createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Location _location = Location();
  var position;
  bool isPermissionAllowed = true, getDataLoading = false;

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  checkPermission() async {
    PermissionStatus _permissionGranted;
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      setState(() {
        _getCurrentLocation();
        isPermissionAllowed = true;
        getDataLoading = true;
      });
    } else {
      setState(() {
        isPermissionAllowed = false;
      });
    }
  }

  selectChangeLocationMethod(latLng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PlacePickerResult pickerResult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlacePickerScreen(
                  googlePlacesApiKey: GOOGLE_API_KEY,
                  initialPosition: LatLng(latLng['lat'], latLng['long']),
                  mainColor: PRIMARY,
                  mapStrings: MapPickerStrings.english(),
                  placeAutoCompleteLanguage:
                      prefs.getString('selectedLanguage') ?? 'en',
                )));
    if (pickerResult != null) {
      setState(() {
        position = {
          'lat': pickerResult.latLng.latitude,
          'long': pickerResult.latLng.longitude,
          'name': pickerResult.address
        };
      });
      await Common.savePositionInfo(position);
    }
  }

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
          buildSelectedlocation(),
          getDataLoading
              ? Center(child: CircularProgressIndicator())
              : Container(),
          isPermissionAllowed ? Container() : buildSelectLocation()
        ],
      ),
      bottomNavigationBar: position == null
          ? Container(height: 1)
          : Container(
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
                onPressed: _goToHomepage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(MyLocalizations.of(context).saveandProceed,
                        style: textbarlowSemiBoldWhite()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildSelectedlocation() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(position == null ? '' : position['name'],
              style: textbarlowSemiBoldBlack()),
        ));
  }

  Widget buildSelectLocation() {
    return Container(
      width: 305,
      height: 44,
      margin: EdgeInsets.only(left: 30, right: 30),
      child: RaisedButton(
        onPressed: () {
          if (position != null) {
            selectChangeLocationMethod(
                {'lat': position['lat'], 'long': position['long']});
          } else {
            selectChangeLocationMethod({'lat': 12.9167995, 'long': 77.5878204});
          }
        },
        color: PRIMARY,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("lib/assets/icon/location1.png", width: 20, height: 20),
            SizedBox(width: 10),
            Text(
                position != null
                    ? MyLocalizations.of(context).changeLocation
                    : MyLocalizations.of(context).selectlocation,
                style: textbarlowSemiBoldWhite()),
          ],
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    LocationData currentLocation = await _location.getLocation();
    final coordinates =
        new Coordinates(currentLocation.latitude, currentLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    if (currentLocation != null && mounted) {
      setState(() {
        getDataLoading = false;
        position = {
          'lat': currentLocation.latitude,
          'long': currentLocation.longitude,
          'name': addresses.first.addressLine
        };
      });
      await Common.savePositionInfo(position);
    } else {
      setState(() {
        getDataLoading = false;
      });
      showError(
          MyLocalizations.of(context).enableTogetlocation,
          MyLocalizations.of(context)
              .thereisproblemusingyourdevicelocationPleasecheckyourGPSsettings);
    }
  }

  showError(error, message) async {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            top: 10.0,
          ),
          title: new Text("$error",
              style: hintSfsemiboldb(), textAlign: TextAlign.center),
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

  void _goToHomepage() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(
              locale: widget.locale, localizedValues: widget.localizedValues),
        ),
        (Route<dynamic> route) => false);
  }
}
