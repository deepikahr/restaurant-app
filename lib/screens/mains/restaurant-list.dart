import 'package:RestaurantSaas/screens/mains/cart.dart';
import 'package:RestaurantSaas/screens/mains/product-list.dart';
import '../../services/counter-service.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'home.dart';
import '../../services/main-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import 'location-list-sheet.dart';
import '../../services/common.dart';
import '../../services/sentry-services.dart';
import '../../services/localizations.dart';

SentryError sentryError = new SentryError();

class RestaurantListPage extends StatefulWidget {
  final String title;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  final Map taxInfo;

  RestaurantListPage(
      {Key key, this.title, this.locale, this.localizedValues, this.taxInfo})
      : super(key: key);

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  Map<String, dynamic> restaurantInfo;
  VoidCallback showBottomSheetCallback;
  int cartCount;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  getRestaurantsList() async {
    if (widget.title == MyLocalizations.of(context).topRated) {
      return await MainService.getTopRatedRestaurants();
    } else if (widget.title == MyLocalizations.of(context).newlyArrived) {
      return await MainService.getNewlyArrivedRestaurants();
    } else {
      List<dynamic> restaurants;
      await Common.getPositionInfo().then((position) async {
        try {
          await MainService.getNearByRestaurants(
                  position['lat'], position['long'])
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

  @override
  Widget build(BuildContext context) {
//    String review = MyLocalizations.of(context).reviews;

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
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          widget.title + MyLocalizations.of(context).restaurants,
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CartPage(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
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
                      right: 3,
                      top: 5,
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
      body: _buildGetRestaurantLoader(),
    );
  }

  Widget _buildGetRestaurantLoader() {
    return AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getRestaurantsList(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          return GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: data.length,
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (BuildContext context, int index) {
                return widget.title == MyLocalizations.of(context).nearBy
                    ? InkWell(
                        child: HomePageState.buildRestaurantCardNear(
                            data[index],
                            MyLocalizations.of(context).reviews,
                            MyLocalizations.of(context).branches),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProductListPage(
                                restaurantName: data[index]['list']
                                    ['restaurantID']['restaurantName'],
                                locationName: data[index]['list']
                                    ['locationName'],
                                aboutUs: data[index]['list']['aboutUs'],
                                imgUrl:
                                    data[index]['list']['restaurantID'] != null
                                        ? data[index]['list']['restaurantID']
                                            ['logo']
                                        : null,
                                address: data[index]['list']['address'],
                                locationId: data[index]['list']['_id'],
                                restaurantId: data[index]['list']
                                    ['restaurantID']['_id'],
                                cuisine: data[index]['list']['cuisine'],
                                deliveryInfo:
                                    data[index]['list']['deliveryInfo'] != null
                                        ? data[index]['list']['deliveryInfo']
                                            ['deliveryInfo']
                                        : null,
                                workingHours:
                                    data[index]['list']['workingHours'] ?? null,
                                locationInfo: data[index]['list'],
                                taxInfo: widget.taxInfo,
                                locale: widget.locale,
                                localizedValues: widget.localizedValues,
                              ),
                            ),
                          );
                        })
                    : InkWell(
                        child: HomePageState.buildRestaurantCard(
                            data[index],
                            MyLocalizations.of(context).reviews,
                            MyLocalizations.of(context).branches),
                        onTap: () async {
                          data[index]['list']['taxInfo'] = widget.taxInfo;
                          if (mounted) {
                            setState(() {
                              restaurantInfo = data[index];
                            });
                            _showBottomSheet();
                          }
                        });
              });
        });
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
