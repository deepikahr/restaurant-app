// import 'package:flutter/material.dart';
// import '../../styles/styles.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import '../../services/common.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:location/location.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class LocationPage extends StatefulWidget {
//   @override
//   _LocationPageState createState() => _LocationPageState();
// }

// class _LocationPageState extends State<LocationPage> {
//   StreamSubscription<Map<String, double>> _locationStream;
//   String address;
//   Location _location = Location();
//   String error;
//   Map<String, dynamic> position;
//   bool isMapAvailable = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     if (_locationStream != null) _locationStream.cancel();
//   }

//   initPlatformState() async {
//     _locationStream = _location
//         .onLocationChanged()
//         .listen((Map<String, double> result) async {
//       Coordinates coordinates =
//           Coordinates(result['latitude'], result['longitude']);
//       List<Address> addresses;
//       try {
//         addresses =
//             await Geocoder.local.findAddressesFromCoordinates(coordinates);
//       } catch (e) {
//       }
//       if (addresses != null && mounted) {
//         setState(() {
//           position = {
//             'lat': result['latitude'],
//             'long': result['longitude'],
//             'name': addresses.first.addressLine
//           };
//           isMapAvailable = true;
//         });
//         await Common.savePositionInfo(position).then((onValue) {});
//       }
//     });
//     try {
//       await _location.getLocation();
//       error = null;
//     } on PlatformException catch (_) {
//       error = 'Permission denied. Please enable GPS from the app settings!';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     initPlatformState();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: PRIMARY,
//         elevation: 0.0,
//         title: Text("Choose Location"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // searchBar,
//             isMapAvailable ? _buildMapView() : Container(),
//             _buildRecentView(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMapView() {
//     return Container(
//       height: screenHeight(context) * 0.3,
//       width: screenWidth(context),
//       child: GoogleMap(
//         mapType: MapType.none,
//         scrollGesturesEnabled: false,
//         onMapCreated: (GoogleMapController controller) {
//           controller.addMarker(
//             MarkerOptions(
//               icon: BitmapDescriptor.fromAsset(
//                 "lib/assets/icon/marker.png",
//               ),
//               position: LatLng(12.916674, 77.5900977),
//             ),
//           );
//         },
//         initialCameraPosition: CameraPosition(
//           target: LatLng(12.916674, 77.5900977),
//           zoom: 6,
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentView() {
//     return Container(
//       margin: EdgeInsets.all(16.0),
//       width: screenWidth(context),
//       child: Card(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 8.0),
//               child: Text(
//                 "Recent Location",
//                 style: hintStyleGreyLightOSR(),
//               ),
//             ),
//             Divider(
//               color: Colors.grey.shade400,
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 8.0),
//               child: Text('1234, Marenahalli'),
//             ),
//             Divider(
//               color: Colors.grey.shade400,
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 12.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Text(
//                     "Current Location",
//                     style: hintStyleSmallRedLightOSR(),
//                   ),
//                   Icon(
//                     Icons.delete_outline,
//                     color: Colors.black87,
//                     size: 18.0,
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
