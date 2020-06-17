import 'dart:async';

import 'package:RestaurantSaas/services/constant.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/common.dart';
import '../../services/counter-service.dart';
import '../../services/localizations.dart';
import '../../services/main-service.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';
import '../mains/product-list.dart';
import 'cart.dart';
import 'drawer.dart';
import 'location-list-sheet.dart';
import 'restaurant-list.dart';

SentryError sentryError = new SentryError();

class HomePage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  HomePage({Key key, this.locale, this.localizedValues}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForAdvertisement =
  GlobalKey<AsyncLoaderState>();

  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForNearByLocations =
  GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateForTopRatedRestaurants =
  GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState>
  _asyncLoaderStateForNewlyArrivedRestaurants =
  GlobalKey<AsyncLoaderState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  VoidCallback showBottomSheetCallback;
  Map<String, dynamic> restaurantInfo;
  int cartCount;
  bool isNearByRestaurants = false;
  List nearByRestaurentsList;
  bool isTopRatedRestaurants = false;
  List topRatedRestaurantsList;
  bool isAdvertisementList = false;
  List advertisementList;
  bool isNewlyArrivedRestaurants = false;
  List newlyArrivedRestaurantsList;
  Map taxInfo;
  int cartCounter;

  @override
  void initState() {
    // checkAndValidateToken();
    showBottomSheetCallback = _showBottomSheet;
    super.initState();
    _checkLoginStatus();
//    selectedLanguages();
    getGlobalSettingsData();
  }

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await MainService.getAdminSettings().then((onValue) {
      try {
        var adminSettings = onValue;
        taxInfo = onValue['taxInfo'];
        if (adminSettings['currency'] == null) {
          prefs.setString('currency', '\$');
        } else {
          prefs.setString(
              'currency', '${adminSettings['currency']['currencySymbol']}');
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      sentryError.reportError(error, null);
    });
  }

  String fullname;
  bool isLoggedIn = false;

  Future _checkLoginStatus() async {
    Common.getToken().then((token) {
      if (token != null) {
        if (mounted) {
          setState(() {
            isLoggedIn = true;
          });
        }
        ProfileService.getUserInfo().then((value) {
          if (value != null && mounted) {
            if (mounted) {
              setState(() {
                fullname = value['name'];

                isLoggedIn = true;
              });
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            isLoggedIn = false;
          });
        }
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
  LocationData currentLocation;
  var addressData;

  @override
  void dispose() {
    if (_locationStream != null) _locationStream.cancel();
    super.dispose();
  }

  void checkAndValidateToken() {
    Common.getToken().then((onValue) {
      try {
        if (onValue != null) {
          ProfileService.validateToken().then((value) {
            if (!value) {
              Common.removeToken();
            }
          });
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  getNearByRestaurants() async {
    // if (!isNearByRestaurants) {
    currentLocation = await _location.getLocation();
    final coordinates =
    new Coordinates(currentLocation.latitude, currentLocation.longitude);
    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    addressData = first.addressLine;
    if (currentLocation != null && mounted) {
      setState(() {
        position = {
          'lat': currentLocation.latitude,
          'long': currentLocation.longitude,
          'name': addressData
        };
      });
      await Common.savePositionInfo(position).then((onValue) {});
    }

    if (isFirstStart) {
      await Future.delayed(Duration(milliseconds: 5000), () {});
      isFirstStart = false;
    }
    if (position != null) {
      return await MainService.getNearByRestaurants(
          position['lat'], position['long'],
          count: itemCount);
    }
    // return first;
    // }
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

  String review, branches;

  Widget build(BuildContext context) {
    review = MyLocalizations.of(context).reviews;
    branches = MyLocalizations.of(context).branches;
    CounterService().getCounter().then((res) {
      try {
        if (mounted) {
          setState(() {
            cartCount = res;
          });
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return Scaffold(
      backgroundColor: whitec,
      key: scaffoldKey,
      drawer: DrawerPage(
          scaffoldKey: scaffoldKey,
          locale: widget.locale,
          localizedValues: widget.localizedValues),
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
                    builder: (BuildContext context) => CartPage(
                      localizedValues: widget.localizedValues,
                      locale: widget.locale,
                    ),
                  ),
                );
              },
              child: Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 20.0, right: 10),
                      child: Icon(Icons.shopping_cart)),
                  Positioned(
                      right: 1,
                      top: 6,
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
      body: ListView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: <Widget>[
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
              : Center(
              child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator())),
          Container(
            color: Colors.white70,
            margin: EdgeInsets.only(bottom: 5.0),
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                isNearByRestaurants != true
                    ? Container()
                    : _buildGridHeader(
                    MyLocalizations.of(context).restaurantsNearYou),
                _buildGetNearByLocationLoader(),
                isNearByRestaurants != true || nearByRestaurentsList == null
                    ? Container()
                    : _buildViewAllButton(MyLocalizations.of(context).nearBy),
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
                    : _buildGridHeader(
                    MyLocalizations.of(context).topRatedRestaurants),
                _buildTopRatedRestaurantLoader(),
                isTopRatedRestaurants != true || topRatedRestaurantsList == null
                    ? Container()
                    : _buildViewAllButton(MyLocalizations.of(context).topRated),
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
                    : _buildGridHeader(
                    MyLocalizations.of(context).newlyArrivedRestaurants),
                _buildNewlyArrivedRestaurantLoader(),
                isNewlyArrivedRestaurants != true ||
                    newlyArrivedRestaurantsList == null
                    ? Container()
                    : _buildViewAllButton(
                    MyLocalizations.of(context).newlyArrived),
              ],
            ),
          ),
        ],
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
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          isNearByRestaurants = true;
          if (data != null) {
            nearByRestaurentsList = data;
          } else {
            return Container();
          }
          return Container(
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
                        itemCount:
                        nearByRestaurentsList.length < int.parse(itemCount)
                            ? nearByRestaurentsList.length
                            : int.parse(itemCount),
                        padding: const EdgeInsets.all(0.0),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              child: buildRestaurantCard(
                                  nearByRestaurentsList[index],
                                  review,
                                  branches),
                              onTap: () {
                                nearByRestaurentsList[index]['list']
                                ['taxInfo'] = taxInfo;
                                if (mounted) {
                                  setState(() {
                                    restaurantInfo =
                                    nearByRestaurentsList[index];
                                  });
                                  _showBottomSheet();
                                }
                              });
                        }),
                    // _buildViewAllButton('Near By'),
                  ]));
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
              message: MyLocalizations.of(context).connectionError,
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
                    child: buildRestaurantCard(
                        topRatedRestaurantsList[index], review, branches),
                    onTap: () {
                      if (mounted) {
                        topRatedRestaurantsList[index]['list']['taxInfo'] =
                            taxInfo;
                        setState(() {
                          restaurantInfo = topRatedRestaurantsList[index];
                        });
                        _showBottomSheet();
                      }
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
              message: MyLocalizations.of(context).connectionError,
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
              child: buildRestaurantCard(data[index], review, branches),
              onTap: () {
                data[index]['list']['taxInfo'] = taxInfo;
                if (mounted) {
                  setState(() {
                    restaurantInfo = data[index];
                  });
                  _showBottomSheet();
                }
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
              builder: (BuildContext context) => RestaurantListPage(
                title: title,
                localizedValues: widget.localizedValues,
                locale: widget.locale,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                MyLocalizations.of(context).viewAll,
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

  Widget _buildOfferSlider(List<dynamic> list) {
    return list.length > 0
        ? Swiper(
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
                  taxInfo: taxInfo,
                  locale: widget.locale,
                  localizedValues: widget.localizedValues,
                ),
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
                  padding: EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 00.0),
                  child: new Container(
                    color: Colors.black26,
                    height: 200.0,
                    padding:
                    new EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
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
                          padding: new EdgeInsets.fromLTRB(
                              0.0, 15.0, 0.0, 15.0),
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
    )
        : Container(
      child: new Image(
        image: AssetImage('lib/assets/imgs/chicken.png'),
        fit: BoxFit.cover,
        width: screenWidth(context),
        height: 200.0,
      ),
    );
  }

  static Widget buildRestaurantCard(info, review, branches) {
    return Card(
      child: Column(
        children: <Widget>[
          buildCardImg(info), //for later use
          buildCardBottom(
              info['list']['restaurantName'],
              double.parse(info['list']['rating'].toString()),
              info['locationCount'],
              info['list']['reviewCount'],
              review,
              branches),
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

  static Widget buildCardBottom(String restaurantName, double rating,
      int locationCounter, int reviews, String review, branches) {
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurantName,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle(),
                      ),
                    ),
                    rating > 0
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(" " + rating.toStringAsFixed(1),
                            style: priceDescription()),
                        Icon(Icons.star, color: PRIMARY, size: 16.0),
                      ],
                    )
                        : Container(),
                  ],
                ),
                locationCounter != null
                    ? Text(
                  locationCounter.toString() + ' $branches',
                  style: subBoldTitle(),
                )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    if (mounted) {
      setState(() {
        showBottomSheetCallback = null;
      });
    }
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
          child: LocationListSheet(
            restaurantInfo: restaurantInfo,
            localizedValues: widget.localizedValues,
            locale: widget.locale,
          ),
        ),
      );
    })
        .closed
        .whenComplete(() {
      if (mounted) {
        if (mounted) {
          setState(() {
            showBottomSheetCallback = _showBottomSheet;
          });
        }
      }
    });
  }
}
