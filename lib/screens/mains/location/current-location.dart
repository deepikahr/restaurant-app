import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final Location _location = Location();
  var position;
  bool isPermissionAllowed = true, isPermissionCheckLoading = false;

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  void checkPermission() async {
    PermissionStatus _permissionGranted;
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      _getCurrentLocation();
      isPermissionAllowed = true;
    } else {
      isPermissionAllowed = false;
    }
    setState(() {
      isPermissionCheckLoading = false;
    });
  }

  selectChangeLocationMethod() async {
    LatLng initialPosition;
    checkPermission();
    if (isPermissionAllowed) {
      await _location.onLocationChanged.first.then((location) {
        initialPosition = LatLng(location.latitude, location.longitude);
        showMapLocationPicker(initialPosition);
      });
    } else {
      initialPosition = LatLng(12.9167995, 77.5878204);
      showMapLocationPicker(initialPosition);
    }
  }

  void showMapLocationPicker(initialPosition) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PlacePickerResult pickerResult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PlacePickerScreen(
                  googlePlacesApiKey: GOOGLE_API_KEY,
                  initialPosition: initialPosition,
                  mainColor: primary,
                  mapStrings: MapPickerStrings.english(
                      selectAddress: MyLocalizations.of(context).selectAddress,
                      cancel: MyLocalizations.of(context).cancel,
                      address: MyLocalizations.of(context).address),
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
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: bg,
        title: Text(
          MyLocalizations.of(context).deliveryLocation,
          style: textMuliSemibold(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 50),
          Image.asset(
            'lib/assets/icons/location.png',
            width: 335.0,
            height: 295,
          ),
          SizedBox(height: 125),
          isPermissionCheckLoading ? Container() : buildSelectedlocation(),
          isPermissionCheckLoading
              ? Center(child: CircularProgressIndicator())
              : Container(),
          isPermissionCheckLoading ? Container() : buildSelectLocation(),
        ],
      ),
      bottomNavigationBar: position == null
          ? Container(height: 1)
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 34),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 1)
              ]),
              child: InkWell(
                onTap: _goToHomepage,
                child: Container(
                    height: 41,
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 1)
                        ]),
                    child: Text(
                      MyLocalizations.of(context).saveandProceed,
                      style: textMuliSemiboldwhite(),
                    )),
              ),
            ),
    );
  }

  Widget buildSelectedlocation() {
    return position == null
        ? Container()
        : Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            height: 72,
            decoration: BoxDecoration(color: bg, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.26), blurRadius: 1)
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image.asset(
                      'lib/assets/icons/locationon.png',
                      width: 19,
                      height: 25,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 4),
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          position['name'],
                          style: textMuliSemiboldmd(),
                        ))
                  ],
                ),
                Container(
                  height: 26,
                  child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                      ),
                      onPressed: () {},
                      child: Text(
                        MyLocalizations.of(context).changeLocation,
                        style: textMuliSemiboldprimarysm(),
                      )),
                )
              ],
            ));
  }

  Widget buildSelectLocation() {
    return position != null
        ? Container()
        : Container(
            width: 217,
            height: 41,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
                ]),
            child: GFButton(
                color: primary,
                borderShape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                onPressed: selectChangeLocationMethod,
                icon: Image.asset("lib/assets/icon/location1.png",
                    width: 20, height: 20),
                child: Text(
                  MyLocalizations.of(context).selectlocation,
                  style: textMuliSemiboldwhite(),
                )),
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
        isPermissionCheckLoading = false;
        position = {
          'lat': currentLocation.latitude,
          'long': currentLocation.longitude,
          'name': addresses.first.addressLine
        };
      });
      await Common.savePositionInfo(position);
    } else {
      setState(() {
        isPermissionCheckLoading = false;
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
