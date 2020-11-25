import 'dart:async';
import 'package:RestaurantSaas/screens/mains/cusineBaseStore.dart';
import 'package:RestaurantSaas/screens/other/search-restaurants.dart';
import 'package:RestaurantSaas/screens/webView/web_view.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
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
import 'cuisine-list.dart';
import 'drawer.dart';
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
  String itemCount = '4';
  bool isFirstStart = true;
  Map<String, dynamic> tableInfo;
  String barcodeError;
  LocationData currentLocation;
  var addressData;
  List renderArray = [];

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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: PRIMARY,
        title: Text(
          APP_NAME,
          style: textbarlowSemiBoldWhite(),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isNearByRestaurants
                    ? IconButton(
                        icon: Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          showSearch(
                              context: context,
                              delegate: RestaurantSearch(
                                  locale: widget.locale,
                                  localizedValues: widget.localizedValues,
                                  restaurantList: nearByRestaurentsList));
                        })
                    : Container(),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => CartPage(
                              localizedValues: widget.localizedValues,
                              locale: widget.locale),
                        ),
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        Icon(Icons.shopping_cart, color: Colors.white),
                        Positioned(
                            right: 1,
                            top: 6,
                            child: (cartCount == null || cartCount == 0)
                                ? Text('', style: TextStyle(fontSize: 14.0))
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
              ],
            ),
          ),
        ],
      ),
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
                            child: CircularProgressIndicator())),
                  ],
                ),
          _buildAdvertisementLoader(),
          renderArray != []
              ? _buildCuisineOfferSlider(renderArray)
              : Container(),
          Container(
            color: Colors.white70,
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
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                ((topRatedRestaurantsList?.length ?? 0) > 0)
                    ? _buildGridHeader(MyLocalizations.of(context).topRated)
                    : Container(),
                _buildTopRatedRestaurantLoader(),
              ],
            ),
          ),
          Container(
            color: Colors.white70,
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
            nearByRestaurentsList = data['dataArr'];
          }
          return Container(
              child: ((nearByRestaurentsList?.length ?? 0) > 0)
                  ? Container(
                      color: Colors.white70,
                      margin: EdgeInsets.only(bottom: 5),
                      child: ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: nearByRestaurentsList.length <
                                  int.parse(itemCount)
                              ? nearByRestaurentsList.length
                              : int.parse(itemCount),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                child: buildRestaurantCard(
                                    nearByRestaurentsList[index],
                                    review,
                                    branches,
                                    true),
                                onTap: () {
                                  nearByRestaurentsList[index]['taxInfo'] =
                                      taxInfo;
                                  goToProductListPage(
                                      context,
                                      nearByRestaurentsList[index],
                                      true,
                                      widget.localizedValues,
                                      widget.locale);
                                });
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
              ? ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      topRatedRestaurantsList.length < int.parse(itemCount)
                          ? topRatedRestaurantsList.length
                          : int.parse(itemCount),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        child: buildRestaurantCard(
                            topRatedRestaurantsList[index],
                            review,
                            branches,
                            false),
                        onTap: () {
                          goToProductListPage(
                              context,
                              topRatedRestaurantsList[index],
                              false,
                              widget.localizedValues,
                              widget.locale);
                        });
                  })
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
          return Column(
            children: <Widget>[
              buildNewlyArrived(newlyArrivedRestaurantsList),
            ],
          );
        });
  }

  Widget buildNewlyArrived(List<dynamic> data) {
    return ((data?.length ?? 0) > 0)
        ? ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length < int.parse(itemCount)
                ? data.length
                : int.parse(itemCount),
            padding: const EdgeInsets.all(0.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  child:
                      buildRestaurantCard(data[index], review, branches, false),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        restaurantInfo = data[index];
                      });
                      goToProductListPage(context, data[index], false,
                          widget.localizedValues, widget.locale);
                    }
                  });
            })
        : Container();
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
          _buildViewAllButton(title)
        ],
      ),
    );
  }

  Widget _buildViewAllButton(String title) {
    return InkWell(
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
    );
  }

  Widget _buildCuisineOfferSlider(List<dynamic> list) {
    return list.length > 0
        ? Container(
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
                SizedBox(
                  height: 150,
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
                          child: Column(
                            children: [
                              Image(
                                  image: list[index]['cuisineImgUrl'] != null
                                      ? NetworkImage(
                                          list[index]['cuisineImgUrl'])
                                      : AssetImage(
                                          'lib/assets/imgs/chicken.png'),
                                  width: 100,
                                  height: 100),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    list[index]['cuisineName'],
                                    style: textsemiboldblack(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget _buildOfferSlider(List<dynamic> list) {
    return ((list?.length ?? 0) > 0)
        ? Container(
            color: Color(0xFFF4F4F4),
            height: 230,
            width: screenWidth(context),
            child: Swiper(
              autoplay: list.length > 1 ? true : false,
              itemCount: list.length > 10 ? 10 : list.length,
              pagination: new SwiperPagination(),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (list[index]['type'] == 'externalLink') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewPage(
                                    title: '',
                                    url: list[index]['externalLink']['link'],
                                  )));
                    } else if (list[index]['type'] == 'restaurant') {
                      matchLocationIdAndNavigate(list[index]['locationId']);
                    } else if (list[index]['type'] == 'cuisine') {
                      matchCuisineIdAndNavigate(list[index]['cuisine']);
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
                                image: list[index]['bannerImage']['imageUrl'] !=
                                        null
                                    ? NetworkImage(
                                        list[index]['bannerImage']['imageUrl'])
                                    : AssetImage('lib/assets/imgs/chicken.png'),
                                fit: BoxFit.cover,
                                width: screenWidth(context),
                                height: 180,
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
  }

  static Widget buildRestaurantCard(
      info, review, branches, isNearByRestaurants) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        buildCardBottom(
            isNearByRestaurants
                ? info['locationName'] ?? null
                : info['Locations']['locationName'],
            isNearByRestaurants
                ? info['restaurantID']['logo'] ?? null
                : info['restaurantID']['logo'] ?? null,
            isNearByRestaurants
                ? info['restaurantID']['restaurantName']
                : info['restaurantID']['restaurantName'],
            isNearByRestaurants
                ? double.parse(info['restaurantID']['rating'].toString())
                : double.parse(info['Locations']['rating'].toString() ?? '0'),
            info['locationCount'],
            isNearByRestaurants
                ? info['restaurantID']['reviewCount'] ?? 0
                : info['reviewCount'] ?? 0,
            review,
            branches),
      ],
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
      String locationName,
      String imageUrl,
      String restaurantName,
      double rating,
      int locationCounter,
      int reviews,
      String review,
      branches) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GFListTile(
        color: Color(0xFFF4F4F4),
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.only(top: 0, right: 10, left: 0, bottom: 0),
        avatar: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
                child: Image(
                    fit: BoxFit.cover,
                    height: 65,
                    width: 60,
                    image: NetworkImage(imageUrl)),
              )
            : ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5)),
                child: Image.asset(
                  'lib/assets/imgs/na.jpg',
                  height: 65,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
        title: Text(
          restaurantName,
          style: textsemiboldblack(),
        ),
        subTitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            locationName ?? '',
            style: textbarlowRegular(),
          ),
          Text(
            '',
            style: textbarlowRegular(),
          )
        ]),
        icon: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: <Widget>[
              Icon(
                Icons.star,
                size: 11,
                color: Colors.black.withOpacity(0.50),
              ),
              Text(
                rating.toString(),
                style: textbarlowRegular(),
              )
            ],
          ),
          Text(
            '${reviews ?? 0} $review',
            style: textbarlowRegular(),
          )
        ]),
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
