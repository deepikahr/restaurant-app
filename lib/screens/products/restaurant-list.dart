import 'package:RestaurantSaas/screens/mains/checkout/cart.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:RestaurantSaas/widgets/card.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import '../../services/common.dart';
import '../../services/counter-service.dart';
import '../../services/localizations.dart';
import '../../services/main-service.dart';
import '../../services/sentry-services.dart';
import '../../widgets/no-data.dart';
import '../mains/home/home.dart';

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
  // VoidCallback showBottomSheetCallback;
  int cartCount;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  getRestaurantsList() async {
    if (widget.title == MyLocalizations.of(context).topRatedRestaurants) {
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
      appBar: appBarWithCartAndTitle(
        context,
        widget.title,
        cartCount,
        () {
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
          return Container(
            alignment: AlignmentDirectional.topCenter,
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: ((data?.length ?? 0) > 0)
                ? ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: restaurantCard(
                                context, data[index], widget.title),
                          ),
                          // HomePageState.buildRestaurantCard(
                          //     data[index],
                          //     MyLocalizations.of(context).reviews,
                          //     MyLocalizations.of(context).branches,
                          //     widget.title ==
                          //             MyLocalizations.of(context).topRatedRestaurants
                          //         ? false
                          //         : widget.title ==
                          //                 MyLocalizations.of(context)
                          //                     .newlyArrived
                          //             ? false
                          //             : true),
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                restaurantInfo = data[index];
                              });
                              HomePageState().goToProductListPage(
                                  context,
                                  data[index],
                                  widget.title ==
                                          MyLocalizations.of(context)
                                              .topRatedRestaurants
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
