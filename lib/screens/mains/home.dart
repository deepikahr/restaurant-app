import 'package:flutter/material.dart';
import 'drawer.dart';
import 'package:async_loader/async_loader.dart';
import '../../styles/styles.dart';
import '../../services/main-service.dart';
import 'location-list-sheet.dart';
import '../../widgets/no-data.dart';
import 'cart.dart';
import '../other/location.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'restaurant-list.dart';
import '../../services/constant.dart';
import '../mains/product-list.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import '../../services/common.dart';
import 'dart:async';
import '../../services/profile-service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

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
  VoidCallback _showBottomSheetCallback;
  Map<String, dynamic> restaurantInfo;

  @override
  void initState() {
    checkAndValidateToken();
    _showBottomSheetCallback = _showBottomSheet;
    super.initState();
  }

  StreamSubscription<Map<String, double>> _locationStream;
  String address;
  Location _location = Location();
  Map<String, dynamic> position;
  String itemCount = '4';
  bool isFirstStart = true;

  @override
  void dispose() {
    super.dispose();
    if (_locationStream != null) _locationStream.cancel();
  }

  void checkAndValidateToken() {
    Common.getToken().then((onValue) {
      if (onValue != null) {
        ProfileService.validateToken().then((value) {
          if (!value) {
            Common.removeToken();
          }
        });
      }
    });
  }

  getNearByRestaurants() async {
    _locationStream = _location
        .onLocationChanged()
        .listen((Map<String, double> result) async {
      Coordinates coordinates =
          Coordinates(result['latitude'], result['longitude']);
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
            'lat': result['latitude'],
            'long': result['longitude'],
            'name': addresses.first.addressLine
          };
        });
        await Common.savePositionInfo(position).then((onValue) {});
      }
    });
    if (isFirstStart) {
      await Future.delayed(Duration(milliseconds: 4000), () {});
      isFirstStart = false;
    }
    if (position != null) {
      return await MainService.getNearByRestaurants(
          position['lat'], position['long'],
          count: itemCount);
    }
  }

  getTopRatedRestaurants() async {
    return await MainService.getTopRatedRestaurants(count: itemCount);
  }

  getNewlyArrivedRestaurants() async {
    return await MainService.getNewlyArrivedRestaurants(count: itemCount);
  }

  getAdvertisementList() async {
    return await MainService.getAdvertisementList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitec,
      key: scaffoldKey,
      drawer: Menu(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        backgroundColor: PRIMARY,
        title: Text(APP_NAME),
        centerTitle: true,
        actions: <Widget>[
          buildCartIcon(context),
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
          Container(
            color: Colors.white70,
            margin: EdgeInsets.only(bottom: 5.0),
            child: ListView(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                _buildGridHeader('Restaurants Near You'),
                _buildGetNearByLocationLoader(),
                _buildViewAllButton('Near By'),
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
                _buildGridHeader('Top Rated Restaurants'),
                _buildTopRatedRestaurantLoader(),
                _buildViewAllButton('Top Rated'),
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
                _buildGridHeader('Newly Arrived Restaurants'),
                _buildNewlyArrivedRestaurantLoader(),
                _buildViewAllButton('Newly Arrived'),
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
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => Container(
              height: 20,
              child: Icon(
                Icons.block,
                size: 100.0,
                color: Colors.grey[300],
              ),
            ),
        renderSuccess: ({data}) {
          return _buildOfferSlider(data);
        });
  }

  Widget _buildGetNearByLocationLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForNearByLocations,
        initState: () async => await getNearByRestaurants(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          return GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
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
        });
  }

  Widget _buildTopRatedRestaurantLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForTopRatedRestaurants,
        initState: () async => await getTopRatedRestaurants(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          return GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
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
        });
  }

  Widget _buildNewlyArrivedRestaurantLoader() {
    return AsyncLoader(
        key: _asyncLoaderStateForNewlyArrivedRestaurants,
        initState: () async => await getNewlyArrivedRestaurants(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          return GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
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
        });
  }

  static Widget buildCartIcon(context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CartPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(right: 10.0),
        child: Image.asset(
          "lib/assets/icon/cart.png",
          width: 18.0,
        ),
      ),
    );
  }

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

  Widget buildLocationIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LocationPage(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(right: 10.0),
        child: Image.asset(
          "lib/assets/icon/location.png",
          color: Colors.white,
          width: 15.0,
        ),
      ),
    );
  }

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
