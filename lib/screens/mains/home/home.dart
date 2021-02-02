import 'dart:async';
import 'package:RestaurantSaas/screens/products/cusineBaseStore.dart';
import 'package:RestaurantSaas/screens/mains/home/search-restaurants.dart';
import 'package:RestaurantSaas/screens/webView/web_view.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/card.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/common.dart';
import '../../../services/counter-service.dart';
import '../../../services/localizations.dart';
import '../../../services/main-service.dart';
import '../../../services/profile-service.dart';
import '../../../services/sentry-services.dart';
import '../../../styles/styles.dart';
import '../../../widgets/no-data.dart';
import '../../products/product-list.dart';
import '../checkout/cart.dart';
import '../../products/cuisine-list.dart';
import 'drawer.dart';
import '../../products/restaurant-list.dart';

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
  Map<String, dynamic> restaurantInfo;
  int cartCount;
  bool isNearByRestaurants = false;
  List nearByRestaurentsList;
  bool isTopRatedRestaurants = false;
  List topRatedRestaurantsList;
  bool isAdvertisementList = false;
  List advertisementList;
  List cuisineList;
  bool isNewlyArrivedRestaurants = false;
  List newlyArrivedRestaurantsList;
  Map taxInfo;
  int cartCounter;
  bool getCuisionLoading = false;
  List removeDuplicationList;
  StreamSubscription<LocationData> _locationStream;
  String address;
  String itemCount = '4';
  bool isFirstStart = true;
  Map<String, dynamic> tableInfo;
  String barcodeError;
  LocationData currentLocation;
  var addressData;
  List renderArray = [];
  String fullname;
  bool isLoggedIn = false;
  String review, branches;

  @override
  void initState() {
    super.initState();
    getCuisinesList();
    _checkLoginStatus();
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
    Map<String, dynamic> restaurants;
    await Common.getPositionInfo().then((position) async {
      try {
        await MainService.getNearByRestaurants(
                position['lat'], position['long'],
                count: null)
            .then((onValue) {
          restaurants = onValue;
        });
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      print(onError);
      sentryError.reportError(onError, null);
    });
    return restaurants;
  }

  getTopRatedRestaurants() async {
    if (!isNearByRestaurants) {
      List<dynamic> restaurants;
      await Common.getPositionInfo().then((position) async {
        try {
          await MainService.getTopRatedRestaurants(
                  lat: position['lat'], long: position['long'])
              .then((onValue) {
            restaurants = onValue;
          });
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
      });
      return restaurants;
    }
  }

  getNewlyArrivedRestaurants() async {
    if (!isNewlyArrivedRestaurants) {
      List<dynamic> restaurants;
      await Common.getPositionInfo().then((position) async {
        try {
          await MainService.getNewlyArrivedRestaurants(
                  lat: position['lat'], long: position['long'])
              .then((onValue) {
            restaurants = onValue;
          });
        } catch (error, stackTrace) {
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((onError) {
        sentryError.reportError(onError, null);
      });
      return restaurants;
    }
  }

  getCuisinesList() async {
    setState(() {
      getCuisionLoading = true;
    });

    Common.getPositionInfo().then((position) async {
      if (position != null) {
        await MainService.getNearByRestaurants(
                position['lat'], position['long'],
                count: null)
            .then((value) {
          if (value != null) {
            List responseArray;
            responseArray = value['dataArr'];
            for (int i = 0; responseArray.length > i; i++) {
              for (int j = 0;
                  responseArray[i]['restaurantID']['cuisine'].length > j;
                  j++) {
                int matchedCuisineIndex;
                for (int k = 0; renderArray.length > k; k++) {
                  if (renderArray != [] &&
                      (renderArray[k]['cuisineName'] ==
                          responseArray[i]['restaurantID']['cuisine'][j]
                              ['cuisineName'])) {
                    matchedCuisineIndex = k;
                  }
                }
                if (matchedCuisineIndex == null) {
                  List locations = [];
                  locations.add(responseArray[i]);
                  renderArray.add({
                    'cuisineName': responseArray[i]['restaurantID']['cuisine']
                        [j]['cuisineName'],
                    'cuisineId': responseArray[i]['restaurantID']['cuisine'][j]
                        ['_id'],
                    'locations': locations,
                    'cuisineImgUrl': responseArray[i]['restaurantID']['cuisine']
                        [j]['cuisineImg']['imageUrl']
                  });
                } else {
                  renderArray[matchedCuisineIndex]['locations']
                      .add(responseArray[i]);
                }
              }
            }

            setState(() {
              getCuisionLoading = false;
            });
          } else {
            setState(() {
              renderArray = [];
              getCuisionLoading = false;
            });
          }
        });
      }
    }).catchError((onError) {
      setState(() {
        renderArray = [];
        getCuisionLoading = false;
      });
      print(onError);
    });
  }

  getAdvertisementList() async {
    return getNearByRestaurants();
  }

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

    Widget appBar() {
      return homeAppbar(
          context,
          isNearByRestaurants,
          () {
            showSearch(
                context: context,
                delegate: RestaurantSearch(
                    locale: widget.locale,
                    localizedValues: widget.localizedValues,
                    restaurantList: nearByRestaurentsList));
          },
          cartCount,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => CartPage(
                    localizedValues: widget.localizedValues,
                    locale: widget.locale),
              ),
            );
          },
          scaffoldKey);
    }

    return Scaffold(
      backgroundColor: bg,
      key: scaffoldKey,
      drawer: DrawerPage(
          scaffoldKey: scaffoldKey,
          locale: widget.locale,
          localizedValues: widget.localizedValues),
      appBar: appBar(),
      body: ListView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: <Widget>[
          (isNearByRestaurants == true ||
                  isTopRatedRestaurants == true ||
                  isAdvertisementList == true ||
                  isNewlyArrivedRestaurants == true)
              ? Container()
              : Column(
                  children: <Widget>[
                    SizedBox(
                      height: 250,
                    ),
                    Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ),
          _buildAdvertisementLoader(),
          renderArray != []
              ? _buildCuisineOfferSlider(renderArray)
              : Container(),
          Container(
            color: Colors.white70,
            margin: EdgeInsets.only(bottom: 10),
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                ((nearByRestaurentsList?.length ?? 0) > 0)
                    ? _buildGridHeader(
                        MyLocalizations.of(context).restaurantsNearYou)
                    : Container(),
                _buildGetNearByLocationLoader(),
              ],
            ),
          ),
          Container(
            color: Colors.white70,
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              children: <Widget>[
                ((topRatedRestaurantsList?.length ?? 0) > 0)
                    ? _buildGridHeader(
                        MyLocalizations.of(context).topRatedRestaurants)
                    : Container(),
                _buildTopRatedRestaurantLoader(),
              ],
            ),
          ),
          Container(
            color: Colors.white70,
            margin: EdgeInsets.only(bottom: 10),
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                ((newlyArrivedRestaurantsList?.length ?? 0) > 0)
                    ? _buildGridHeader(MyLocalizations.of(context).newlyArrived)
                    : Container(),
                _buildNewlyArrivedRestaurantLoader(),
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
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          isAdvertisementList = true;
          if (data != null) {
            advertisementList = data['Banners'];
          }
          return ((advertisementList?.length ?? 0) > 0)
              ? Container(
                  color: Colors.white70,
                  height: 180,
                  margin: EdgeInsets.only(bottom: 10),
                  width: screenWidth(context),
                  child: Swiper(
                    autoplay: advertisementList.length > 1 ? true : false,
                    itemCount: advertisementList.length > 10
                        ? 10
                        : advertisementList.length,
                    // pagination: new SwiperPagination(),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (advertisementList[index]['type'] ==
                              'externalLink') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                          title: '',
                                          url: advertisementList[index]
                                              ['externalLink']['link'],
                                        )));
                          } else if (advertisementList[index]['type'] ==
                              'restaurant') {
                            matchLocationIdAndNavigate(
                                advertisementList[index]['locationId']);
                          } else if (advertisementList[index]['type'] ==
                              'cuisine') {
                            matchCuisineIdAndNavigate(
                                advertisementList[index]['cuisine']);
                          }
                        },
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: new Image(
                                      image: advertisementList[index]
                                                  ['bannerImage']['imageUrl'] !=
                                              null
                                          ? NetworkImage(
                                              advertisementList[index]
                                                  ['bannerImage']['imageUrl'])
                                          : AssetImage(
                                              'lib/assets/imgs/chicken.png'),
                                      fit: BoxFit.cover,
                                      width: screenWidth(context),
                                      height: 140,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Container();
        });
  }

  Widget _buildCuisineOfferSlider(List<dynamic> list) {
    return list.length > 0
        ? Container(
            margin: EdgeInsets.only(bottom: 10),
            color: Colors.white70,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        MyLocalizations.of(context).cuisinesNearYou,
                        style: textOSR(),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => CuisineList(
                                cuisineList: renderArray,
                                title:
                                    MyLocalizations.of(context).cuisinesNearYou,
                                localizedValues: widget.localizedValues,
                                locale: widget.locale,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          MyLocalizations.of(context).viewAll,
                          style: textregulargreen(),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  height: 110,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list == null ? 0 : list.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CuisineBaseStores(
                                  locale: widget.locale,
                                  localizedValues: widget.localizedValues,
                                  location: list[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 5, left: 5),
                            child: Column(
                              children: [
                                ClipRRect(
                                  child: Image(
                                    image: list[index]['cuisineImgUrl'] != null
                                        ? NetworkImage(
                                            list[index]['cuisineImgUrl'])
                                        : AssetImage(
                                            'lib/assets/imgs/chicken.png'),
                                    width: 75,
                                    height: 81,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  list[index]['cuisineName'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textMuliSemiboldsm(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          )
        : Container();
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
            nearByRestaurentsList = data['dataArr'];
          }
          return Container(
              height: 156,
              child: ((nearByRestaurentsList?.length ?? 0) > 0)
                  ? Container(
                      child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: nearByRestaurentsList.length <
                                  int.parse(itemCount)
                              ? nearByRestaurentsList.length
                              : int.parse(itemCount),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                // child: buildRestaurantCard(
                                //     nearByRestaurentsList[index],
                                //     review,
                                //     branches,
                                //     true),
                                onTap: () {
                                  nearByRestaurentsList[index]['taxInfo'] =
                                      taxInfo;
                                  goToProductListPage(
                                      context,
                                      nearByRestaurentsList[index],
                                      true,
                                      widget.localizedValues,
                                      widget.locale);
                                },
                                child: Container(
                                  width: 81,
                                  margin: EdgeInsets.only(
                                      left: 5, right: 10, top: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ClipRRect(
                                        child: Image(
                                          image: nearByRestaurentsList[index]
                                                          ['restaurantID']
                                                      ['logo'] !=
                                                  null
                                              ? NetworkImage(
                                                  nearByRestaurentsList[index]
                                                      ['restaurantID']['logo'])
                                              : AssetImage(
                                                  'lib/assets/imgs/chicken.png'),
                                          width: 75,
                                          height: 81,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        nearByRestaurentsList[index]
                                            ['restaurantID']['restaurantName'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textMuliSemiboldsm(),
                                      ),
                                      Text(
                                        nearByRestaurentsList[index]
                                            ['locationName'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: textMuliRegularxs(),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                    )
                  : Container(
                      color: whitec,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                          ),
                          NoData(
                              message: MyLocalizations.of(context)
                                  .noNearByLocationsFound,
                              icon: Icons.data_usage),
                        ],
                      ),
                    ));
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
          return ((topRatedRestaurantsList?.length ?? 0) > 0)
              ? Container(
                  height: 245,
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio:
                                  MediaQuery.of(context).size.width /
                                      MediaQuery.of(context).size.height *
                                      0.7,
                              crossAxisCount: 2),
                      itemCount:
                          topRatedRestaurantsList.length < int.parse(itemCount)
                              ? topRatedRestaurantsList.length
                              : int.parse(itemCount),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            child: restaurantCard(
                                context,
                                topRatedRestaurantsList[index],
                                MyLocalizations.of(context)
                                    .topRatedRestaurants),
                            // buildRestaurantCard(
                            //     topRatedRestaurantsList[index],
                            //     review,
                            //     branches,
                            //     false),
                            onTap: () {
                              goToProductListPage(
                                  context,
                                  topRatedRestaurantsList[index],
                                  false,
                                  widget.localizedValues,
                                  widget.locale);
                            });
                      }),
                )
              : Container();
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
          return ((newlyArrivedRestaurantsList?.length ?? 0) > 0)
              ? Container(
                  height: 245,
                  width: MediaQuery.of(context).size.width,
                  child: GridView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio:
                                  MediaQuery.of(context).size.width /
                                      MediaQuery.of(context).size.height *
                                      0.7,
                              crossAxisCount: 2),
                      itemCount: newlyArrivedRestaurantsList.length <
                              int.parse(itemCount)
                          ? newlyArrivedRestaurantsList.length
                          : int.parse(itemCount),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            child: restaurantCard(
                                context,
                                newlyArrivedRestaurantsList[index],
                                MyLocalizations.of(context).newlyArrived),
                            // buildRestaurantCard(newlyArrivedRestaurantsList[index], review, branches, false),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  restaurantInfo =
                                      newlyArrivedRestaurantsList[index];
                                });
                                goToProductListPage(
                                    context,
                                    newlyArrivedRestaurantsList[index],
                                    false,
                                    widget.localizedValues,
                                    widget.locale);
                              }
                            });
                      }),
                )
              : Container();
        });
  }

  Widget _buildGridHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: textOSR(),
          ),
          InkWell(
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
            child: Text(
              MyLocalizations.of(context).viewAll,
              style: textregulargreen(),
            ),
          ),
        ],
      ),
    );
  }

  void goToProductListPage(
      context, data, isNearByRestaurant, localizedValues, locale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ProductListPage(
            shippingType: isNearByRestaurant
                ? data['restaurantID']['shippingType']
                : data['restaurantID']['shippingType'],
            deliveryCharge: isNearByRestaurant
                ? data['restaurantID']['deliveryCharge']
                : data['restaurantID']['deliveryCharge'],
            minimumOrderAmount: isNearByRestaurant
                ? data['restaurantID']['minimumOrderAmount'] ?? 0
                : data['restaurantID']['minimumOrderAmount'] ?? 0,
            localizedValues: localizedValues,
            locale: locale,
            restaurantName: isNearByRestaurant
                ? data['restaurantID']['restaurantName']
                : data['restaurantID']['restaurantName'],
            locationName: isNearByRestaurant
                ? data['locationName']
                : data['Locations']['locationName'],
            aboutUs: isNearByRestaurant
                ? data['aboutUs']
                : data['Locations']['aboutUs'],
            imgUrl: isNearByRestaurant
                ? data['restaurantID']['logo']
                : data['restaurantID']['logo'] ?? '',
            address: isNearByRestaurant
                ? data['address']
                : data['Locations']['address'],
            locationId:
                isNearByRestaurant ? data['_id'] : data['Locations']['_id'],
            restaurantId: isNearByRestaurant
                ? data['restaurantID']['_id']
                : data['restaurantID']['_id'],
            cuisine: isNearByRestaurant
                ? data['restaurantID']['cuisine']
                : data['Locations']['cuisine'] ?? null,
            workingHours: isNearByRestaurant
                ? data['workingHours'] ?? null
                : data['Locations']['workingHours'],
            locationInfo: {
                  '_id': isNearByRestaurant
                      ? data['_id']
                      : data['Locations']['_id'],
                  "locationName": isNearByRestaurant
                      ? data['locationName']
                      : data['Locations']['locationName'],
                  "workingHours": isNearByRestaurant
                      ? data['workingHours'] ?? null
                      : data['Locations']['workingHours'],
                } ??
                null,
            taxInfo: isNearByRestaurant
                ? data['restaurantID']['taxInfo'] ?? null
                : data['Locations']['taxInfo'] ?? null),
      ),
    );
  }

  void matchLocationIdAndNavigate(locationId) {
    nearByRestaurentsList.map((item) {
      if (item['_id'] == locationId) {
        goToProductListPage(
            context, item, true, widget.localizedValues, widget.locale);
      }
    }).toList();
  }

  void matchCuisineIdAndNavigate(cuisineId) {
    renderArray.map((cuisineItem) {
      if (cuisineItem['cuisineId'] == cuisineId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CuisineBaseStores(
              locale: widget.locale,
              localizedValues: widget.localizedValues,
              location: cuisineItem,
            ),
          ),
        );
      }
    }).toList();
  }
}
