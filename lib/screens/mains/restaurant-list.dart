import 'package:RestaurantSaas/screens/mains/cart.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';

import '../../services/common.dart';
import '../../services/counter-service.dart';
import '../../services/localizations.dart';
import '../../services/main-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';
import 'home.dart';

SentryError sentryError = new SentryError();

class RestaurantListPage extends StatefulWidget {
  final String title;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  RestaurantListPage({Key key, this.title, this.locale, this.localizedValues})
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
    } else if (widget.title == MyLocalizations.of(context).newlyArrived) {
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
    if (widget.title == MyLocalizations.of(context).restaurantsNearYou) {
      List<dynamic> restaurants;
      await Common.getPositionInfo().then((position) async {
        try {
          await MainService.getNearByRestaurants(
                  position['lat'], position['long'])
              .then((onValue) {
            restaurants = onValue['dataArr'];
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
  }

  @override
  Widget build(BuildContext context) {
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
          widget.title == MyLocalizations.of(context).restaurantsNearYou
              ? widget.title
              : widget.title + MyLocalizations.of(context).restaurants,
          style: textbarlowSemiBoldWhite(),
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
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      )),
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
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ((data?.length ?? 0) > 0)
                ? ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    padding: const EdgeInsets.all(0.0),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          child: HomePageState.buildRestaurantCard(
                              data[index],
                              MyLocalizations.of(context).reviews,
                              MyLocalizations.of(context).branches,
                              widget.title ==
                                      MyLocalizations.of(context).topRated
                                  ? false
                                  : widget.title ==
                                          MyLocalizations.of(context)
                                              .newlyArrived
                                      ? false
                                      : true),
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                restaurantInfo = data[index];
                              });
                              HomePageState().goToProductListPage(
                                  context,
                                  data[index],
                                  widget.title ==
                                          MyLocalizations.of(context).topRated
                                      ? false
                                      : widget.title ==
                                              MyLocalizations.of(context)
                                                  .newlyArrived
                                          ? false
                                          : true,
                                  widget.localizedValues,
                                  widget.locale);
                            }
                          });
                    })
                : NoData(
                    message: MyLocalizations.of(context).connectionError,
                    icon: Icons.block),
          );
        });
  }
}
