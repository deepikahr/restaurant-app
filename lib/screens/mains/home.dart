import 'package:RestaurantSaas/screens/other/CounterModel.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/styles/styles.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawer.dart';
import 'package:async_loader/async_loader.dart';
import '../../styles/styles.dart';
import '../../services/main-service.dart';
import 'location-list-sheet.dart';
import '../../widgets/no-data.dart';
import 'cart.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'restaurant-list.dart';
import '../mains/product-list.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import '../../services/common.dart';
import 'dart:async';
import '../../services/profile-service.dart';
// import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
// import '../other/search.dart';
import '../../services/sentry-services.dart';



import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();


//class App extends StatefulWidget {
//  final Map<String, Map<String, String>> localizedValues;
//  String locale;
//  App({Key key, this.locale, this.localizedValues}) : super(key: key);
//  @override
//  _AppState createState() => _AppState();
//}
//
//class _AppState extends State<App> {
//
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      locale: Locale(widget.locale),
//      debugShowCheckedModeBanner: false,
//      localizationsDelegates: [
//        MyLocalizationsDelegate(widget.localizedValues),
//        GlobalMaterialLocalizations.delegate,
//        GlobalWidgetsLocalizations.delegate,
//      ],
//      supportedLocales: languages.map((language) => Locale(language, '')),
//      home: HomePage(locale: widget.locale, localizedValues: widget.localizedValues),
//    );
//  }
//}


class HomePage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  var locale;
  HomePage({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForAdvertisement =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForTableInfo =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForNearByLocations =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForTopRatedRestaurants =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState>
      _asyncLoaderStateForNewlyArrivedRestaurants =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  VoidCallback _showBottomSheetCallback;
  Map<String, dynamic> restaurantInfo;
  int nearByLength;
  int cartCount;
  bool isNearByRestaurants = false;
  List nearByRestaurentsList;
  bool isTopRatedRestaurants = false;
  List topRatedRestaurantsList;
  bool isAdvertisementList = false;
  List advertisementList;
  bool isNewlyArrivedRestaurants = false;
  List newlyArrivedRestaurantsList;
  int cartCounter;

  @override
  void initState() {
    // checkAndValidateToken();
    _showBottomSheetCallback = _showBottomSheet;
    super.initState();
    _checkLoginStatus();
    selectedLanguages();
  }

  var selectedLanguage;

  selectedLanguages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage');
    });
    print('selectedLanguage............$selectedLanguage');
  }

  String fullname;
  bool isLoggedIn = false;

  Future _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Common.getToken().then((token) {
      if (token != null) {
        setState(() {
          isLoggedIn = true;
        });
        ProfileService.getUserInfo().then((value) {
          print(value);
          if (value != null && mounted) {
            setState(() {
              fullname = value['name'];
              isLoggedIn = true;
            });
          }
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    });
  }

  StreamSubscription<LocationData> _locationStream;
  String address;
  Location _location = Location();
  Map<String, dynamic> position;
  String itemCount = '4';
  bool isFirstStart = true;
  Map<String, dynamic> tableInfo;
  String barcodeError;

  @override
  void dispose() {
    super.dispose();
    // _getCartLength();
    if (_locationStream != null) _locationStream.cancel();
  }

  void _getCartLength() async {
    await Common.getCart().then((onValue) {
      try{
        if (onValue != null) {
          setState(() {
            cartCounter = onValue['productDetails'].length;
          });
          // print(cartCounter);
        } else {
          setState(() {
            cartCounter = 0;
          });
        }
      }
      catch (error, stackTrace) {
      sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }
  // getLocationInfoByTableId() async {
  //   showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title:
  //             Text('Book Table Number: ' + tableInfo['tableNumber'].toString()),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[Center(child: CircularProgressIndicator())],
  //           ),
  //         ),
  //       );
  //     },
  //   );

  //   return await MainService.getLocationInfoByTableId(tableInfo['tableId'])
  //       .then((res) {
  //     var data = res;
  //     Navigator.of(context).pop();
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (BuildContext context) => ProductListPage(
  //           restaurantName: data['restaurantId']['restaurantName'],
  //           locationName: data['locationId']['locationName'],
  //           aboutUs: data['locationId']['aboutUs'],
  //           imgUrl: data['restaurantId']['logo'],
  //           address: data['locationId']['address'],
  //           locationId: data['locationId']['_id'],
  //           restaurantId: data['restaurantId']['_id'],
  //           cuisine: data['locationId']['cuisine'],
  //           deliveryInfo: data['locationId']['deliveryInfo'] != null
  //               ? data['locationId']['deliveryInfo']['deliveryInfo']
  //               : null,
  //           workingHours: data['locationId']['workingHours'] ?? null,
  //           locationInfo: data['locationId'],
  //           taxInfo: data['restaurantId']['taxInfo'],
  //           tableInfo: tableInfo,
  //         ),
  //       ),
  //     );
  //   });
  // }

  // Future barcodeScanning() async {
  //   try {
  //     String code = await BarcodeScanner.scan();
  //     // setState(() {
  //     Map<String, dynamic> barcode = json.decode(code);
  //     tableInfo = barcode;
  //     // });
  //     getLocationInfoByTableId();
  //     // _showBottomSheetForBarcodeView();
  //   } on PlatformException catch (e) {
  //     if (e.code == BarcodeScanner.CameraAccessDenied) {
  //       setState(() {
  //         barcodeError = 'No camera permission!';
  //       });
  //     } else {
  //       setState(() => barcodeError = 'Unknown error: $e');
  //     }
  //   } on FormatException {
  //     setState(() => barcodeError = 'Nothing captured.');
  //   } catch (e) {
  //     setState(() => barcodeError = 'Unknown error: $e');
  //   }
  // }

  void checkAndValidateToken() {
    Common.getToken().then((onValue) {
      try{
        if (onValue != null) {
          ProfileService.validateToken().then((value) {
            if (!value) {
              Common.removeToken();
            }
          });
        }
      }
      catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  getNearByRestaurants() async {
    if (!isNearByRestaurants) {
      _locationStream =
          _location.onLocationChanged().listen((LocationData result) async {
        Coordinates coordinates =
            Coordinates(result.latitude, result.longitude);
        List<Address> addresses;
        try {
          addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
        } catch (e) {
          print(e);
        }
        if (addresses != null && mounted) {
          setState(() {
            position = {
              'lat': result.latitude,
              'long': result.longitude,
              'name': addresses.first.addressLine
            };
          });
          await Common.savePositionInfo(position).then((onValue) {});
        }
      });
      if (isFirstStart) {
        await Future.delayed(Duration(milliseconds: 5000), () {});
        isFirstStart = false;
      }
      if (position != null) {
        return await MainService.getNearByRestaurants(
            position['lat'], position['long'],
            count: itemCount);
      }
    }
  }

  getTopRatedRestaurants() async {
    if (!isTopRatedRestaurants) {
      return await MainService.getTopRatedRestaurants(count: itemCount);
    }
  }

  getNewlyArrivedRestaurants() async {
    if (!isNewlyArrivedRestaurants) {
      return await MainService.getNewlyArrivedRestaurants(count: itemCount);
    }
  }

  getAdvertisementList() async {
    if (!isAdvertisementList) {
      return await MainService.getAdvertisementList();
    }
  }

  Widget build(BuildContext context) {
    CounterModel().getCounter().then((res) {
      try{
        setState(() {
          cartCount = res;
        });
      }
      // print("res   $cartCount");
      catch (error, stackTrace) {
      sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return MaterialApp(
      locale: Locale(widget.locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        MyLocalizationsDelegate(widget.localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: languages.map((language) => Locale(language, '')),
      home: Scaffold(
        backgroundColor: whitec,
        key: scaffoldKey,
        drawer: Menu(scaffoldKey: scaffoldKey, locale: widget.locale, localizedValues: widget.localizedValues),
        appBar: AppBar(
          backgroundColor: PRIMARY,
          title: Text(APP_NAME),
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
        body: ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            Container(
              alignment: AlignmentDirectional.center,
              height: 28.0,
              color: prefix0.PRIMARY.withOpacity(0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(MyLocalizations.of(context).hello , style: hintStyleWhiteLightOSR(),),
                  Text(" "),
                  Text(MyLocalizations.of(context).greetTo('$fullname'), style: hintStyleWhiteLightOSR(),),
                ],
              ),
            ),
            Container(
              height: 180.0,
              width: screenWidth(context),
              child: _buildAdvertisementLoader(),
            ),
            (isNearByRestaurants == true ||
                    isTopRatedRestaurants == true ||
                    isAdvertisementList == true ||
                    isNewlyArrivedRestaurants == true)
                ? Container()
                : Container(
                    alignment: AlignmentDirectional.center,
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    height: 56.0,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.white70)),
                    child: Image.asset(
                      'lib/assets/icon/spinner.gif',
                      width: 40.0,
                      height: 40.0,
                    ),
                  ),
            Container(
              color: Colors.white70,
              margin: EdgeInsets.only(bottom: 5.0),
              child: ListView(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  isNearByRestaurants != true
                      ? Container()
                      : _buildGridHeader('Restaurants Near You'),
                  _buildGetNearByLocationLoader(),
                  isNearByRestaurants != true
                      ? Container()
                      : _buildViewAllButton('Near By'),
                ],
              ),
            ),
            Container(
              color: Colors.white70,
              margin: EdgeInsets.only(bottom: 5.0),
              child: ListView(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  isTopRatedRestaurants != true
                      ? Container()
                      : _buildGridHeader('Top Rated Restaurants'),
                  _buildTopRatedRestaurantLoader(),
                  isTopRatedRestaurants != true
                      ? Container()
                      : _buildViewAllButton('Top Rated'),
                ],
              ),
            ),
            Container(
              color: Colors.white70,
              margin: EdgeInsets.only(bottom: 5.0),
              child: ListView(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  isNewlyArrivedRestaurants != true
                      ? Container()
                      : _buildGridHeader('Newly Arrived Restaurants'),
                  _buildNewlyArrivedRestaurantLoader(),
                  isNewlyArrivedRestaurants != true
                      ? Container()
                      : _buildViewAllButton('Newly Arrived'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertisementLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForAdvertisement,
        initState: () async => await getAdvertisementList(),
        renderLoad: () => Center(),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return Container(
            height: 20,
            child: Icon(
              Icons.block,
              size: 100.0,
              color: Colors.grey[300],
            ),
          );
        },
        renderSuccess: ({data}) {
          isAdvertisementList = true;
          if (data != null) {
            advertisementList = data;
          }
          return _buildOfferSlider(advertisementList);
        });
  }

  Widget _buildGetNearByLocationLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForNearByLocations,
        initState: () async => await getNearByRestaurants(),
        renderLoad: () => Center(),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: 'Please check your internet connection!',
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          isNearByRestaurants = true;
          if (data != null) {
            nearByRestaurentsList = data;
          } else {
            return Container();
          }
          nearByLength = nearByRestaurentsList.length;
          return nearByLength > 0
              ? Container(
                  color: Colors.white70,
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: ListView(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        // _buildGridHeader('Restaurants Near You'),
                        GridView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: nearByRestaurentsList.length <
                                    int.parse(itemCount)
                                ? nearByRestaurentsList.length
                                : int.parse(itemCount),
                            padding: const EdgeInsets.all(0.0),
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  child: buildRestaurantCard(
                                      nearByRestaurentsList[index]),
                                  onTap: () {
                                    setState(() {
                                      restaurantInfo =
                                          nearByRestaurentsList[index];
                                    });
                                    _showBottomSheet();
                                  });
                            }),
                        // _buildViewAllButton('Near By'),
                      ]))
              : Container();
        });
  }

  Widget _buildTopRatedRestaurantLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForTopRatedRestaurants,
        initState: () async => await getTopRatedRestaurants(),
        renderLoad: () => Center(),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: 'Please check your internet connection!',
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          isTopRatedRestaurants = true;
          if (data != null) {
            topRatedRestaurantsList = data;
          }
          return GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: topRatedRestaurantsList.length < int.parse(itemCount)
                  ? topRatedRestaurantsList.length
                  : int.parse(itemCount),
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    child: buildRestaurantCard(topRatedRestaurantsList[index]),
                    onTap: () {
                      setState(() {
                        restaurantInfo = topRatedRestaurantsList[index];
                      });
                      _showBottomSheet();
                    });
              });
        });
  }

  Widget _buildNewlyArrivedRestaurantLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForNewlyArrivedRestaurants,
        initState: () async => await getNewlyArrivedRestaurants(),
        renderLoad: () => Center(),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: 'Please check your internet connection!',
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          isNewlyArrivedRestaurants = true;
          if (data != null) {
            newlyArrivedRestaurantsList = data;
          }
          return buildNewlyArrived(newlyArrivedRestaurantsList);
        });
  }

  Widget buildNewlyArrived(List<dynamic> data) {
    return GridView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: data.length < int.parse(itemCount)
            ? data.length
            : int.parse(itemCount),
        padding: const EdgeInsets.all(0.0),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              child: buildRestaurantCard(data[index]),
              onTap: () {
                setState(() {
                  restaurantInfo = data[index];
                });
                _showBottomSheet();
              });
        });
  }

  // static Widget buildCartIcon(context) {
  //   return GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (BuildContext context) => CartPage(),
  //           ),
  //         );
  //       },
  //       child: Row(
  //         children: <Widget>[
  //           Container(
  //               padding: EdgeInsets.only(right: 10.0),
  //               child: Icon(Icons.shopping_cart)),
  //           Text(
  //             ' ',
  //             style: TextStyle(fontSize: 24.0),
  //           ),
  //         ],
  //       ));
  // }

  Widget _buildGridHeader(String title) {
    return Container(
      height: 36.0,
      width: screenWidth(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.restaurant_menu,
            color: PRIMARY,
            size: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              style: textOSR(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildViewAllButton(String title) {
    return Container(
      height: 36.0,
      width: screenWidth(context),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  RestaurantListPage(title: title),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "View All",
                style: hintStylePrimaryLightOSR(),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: PRIMARY,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  // Widget buildLocationIcon() {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (BuildContext context) => LocationPage(),
  //         ),
  //       );
  //     },
  //     child: Container(
  //       padding: EdgeInsets.only(right: 10.0),
  //       child: Image.asset(
  //         "lib/assets/icon/location.png",
  //         color: Colors.white,
  //         width: 15.0,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildOfferSlider(List<dynamic> list) {
    return Swiper(
      autoplay: true,
      itemCount: list.length,
      pagination: new SwiperPagination(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ProductListPage(
                    restaurantName: list[index]['restaurantName'],
                    locationName: list[index]['locationName'],
                    aboutUs: list[index]['locationInfo']['aboutUs'],
                    imgUrl: list[index]['restaurantInfo'] != null
                        ? list[index]['restaurantInfo']['logo']
                        : null,
                    address: list[index]['address'],
                    locationId: list[index]['locationInfo']['_id'],
                    restaurantId: list[index]['restaurantID'],
                    cuisine: list[index]['locationInfo']['cuisine'],
                    deliveryInfo:
                        list[index]['locationInfo']['deliveryInfo'] != null
                            ? list[index]['locationInfo']['deliveryInfo']
                                ['deliveryInfo']
                            : null,
                    workingHours:
                        list[index]['locationInfo']['workingHours'] ?? null,
                    locationInfo: list[index]['locationInfo'],
                    taxInfo: list[index]['locationInfo']['restaurantID']
                        ['taxInfo']),
              ),
            );
          },
          child: Stack(
            children: <Widget>[
              new Image(
                image: list[index]['homeUrl'] != null
                    ? NetworkImage(list[index]['homeUrl'])
                    : AssetImage('lib/assets/imgs/chicken.png'),
                fit: BoxFit.cover,
                width: screenWidth(context),
                height: 200.0,
              ),
              new Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Container(
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 00.0),
                  child: new Container(
                    color: Colors.black26,
                    height: 200.0,
                    padding: new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                    alignment: FractionalOffset.centerLeft,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          list[index]['restaurantName'],
                          style: hintStyleGreyLightOSL(),
                        ),
                        new Padding(
                          padding:
                              new EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                          child: new Text(
                            list[index]['locationName'],
                            style: hintStyleSmallYellowLightOSR(),
                          ),
                        ),
                        new Text(
                          list[index]['message'],
                          style: category(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget buildRestaurantCard(info) {
    // print(info);
    return Card(
      child: Column(
        children: <Widget>[
          buildCardImg(info), //for later use
          buildCardBottom(
              info['list']['restaurantName'],
              double.parse(info['list']['rating'].toString()),
              info['locationCount'],
              info['list']['reviewCount']),
        ],
      ),
    );
  }

  static Widget buildCardImg(info) {
    return Container(
      padding: EdgeInsets.all(0.0),
      height: 120.0,
      width: 180.0,
      decoration: getBgDecoration(info['list']['logo'] ?? null),
      child: null, //buildFavIcon(),
    );
  }

  static Decoration getBgDecoration(imgUrl) {
    return BoxDecoration(
      image: DecorationImage(
          image: imgUrl != null
              ? NetworkImage(imgUrl)
              : AssetImage('lib/assets/imgs/na.jpg'),
          repeat: ImageRepeat.noRepeat,
          matchTextDirection: false,
          alignment: Alignment.center,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2), BlendMode.darken)),
    );
  }

  Widget buildFavIcon() {
    return Container(
      alignment: FractionalOffset.topRight,
      padding: EdgeInsets.only(right: 5.0),
      child: IconButton(
          icon: const Icon(Icons.favorite, semanticLabel: 'Favorite'),
          iconSize: 30.0,
          onPressed: () {},
          color: Colors.white),
    );
  }

  static Widget buildCardBottom(
      String restaurantName, double rating, int locationCounter, int reviews) {
    return Container(
      padding: EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                restaurantName,
                style: titleStyle(),
              ),
              locationCounter != null
                  ? Text(
                      locationCounter.toString() + ' Branches',
                      style: subBoldTitle(),
                    )
                  : Container(),
            ],
          ),
          rating > 0
              ? Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(rating.toStringAsFixed(1),
                            style: priceDescription()),
                        Icon(Icons.star, color: PRIMARY, size: 16.0),
                      ],
                    ),
                    Text(
                      '(' + reviews.toString() + ' Reviews)',
                      style: hintStyleSmallTextDarkOSR(),
                    )
                  ],
                )
              : Text(''),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    setState(() {
      _showBottomSheetCallback = null;
    });
    scaffoldKey.currentState
        .showBottomSheet<void>((BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: PRIMARY, width: 6.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: LocationListSheet(restaurantInfo: restaurantInfo),
            ),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _showBottomSheetCallback = _showBottomSheet;
            });
          }
        });
  }
}
