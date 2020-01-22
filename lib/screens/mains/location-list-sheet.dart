import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';
import '../../styles/styles.dart';
import '../../services/main-service.dart';
import '../../widgets/no-data.dart';
import '../../widgets/location-card.dart';
import 'product-list.dart';
import 'location-list.dart';
import '../../services/sentry-services.dart';

import 'package:RestaurantSaas/localizations.dart' show MyLocalizations;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class LocationListSheet extends StatelessWidget {
  final Map<String, dynamic> restaurantInfo, locationInfo;
  final Map<String, Map<String, String>> localizedValues;
  var locale;
  LocationListSheet(
      {Key key,
      this.restaurantInfo,
      this.locationInfo,
      this.localizedValues,
      this.locale})
      : super(key: key);

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  int cartCount;

  String currency = "";
  getLocationListByRestaurantId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');

    return await MainService.getLocationsByRestaurantId(
        restaurantInfo['list']['_id']);
  }

  @override
  Widget build(BuildContext context) {
    AsyncLoader asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => getLocationListByRestaurantId(),
        renderLoad: () => new Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return new Center(
            child: NoData(
                message: MyLocalizations.of(context).connectionError,
                icon: Icons.block),
          );
        },
        renderSuccess: ({data}) {
          return buildLocationSheetView(context, data, restaurantInfo, true,
              localizedValues, locale, currency);
        });

    return Container(
      height: screenHeight(context) * 0.6,
      width: screenHeight(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSheetHeader(
              restaurantInfo['list']['logo'],
              restaurantInfo['list']['restaurantName'],
              restaurantInfo['list']['reviewCount'],
              context),
          buildOutletInfo(restaurantInfo['locationCount'], context),
          Divider(),
          asyncLoader,
        ],
      ),
    );
  }

  static Widget buildLocationSheetView(
      BuildContext context,
      List<dynamic> data,
      Map<String, dynamic> restaurantInfo,
      bool isLimited,
      Map<String, Map<String, String>> localizedValues,
      String locale,
      String currency) {
    if (data.length > 0) {
      return ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            if (!isLimited) {
              return getLocationCard(data, index, context, restaurantInfo,
                  data[index]['location'], localizedValues, locale, currency);
            } else {
              if (index < 2) {
                return getLocationCard(data, index, context, restaurantInfo,
                    data[index]['location'], localizedValues, locale, currency);
              } else {
                if (index == 2) {
                  return buildViewMoreButton(
                      context, restaurantInfo, data, localizedValues, locale);
                }
                return null;
              }
            }
          });
    } else {
      return NoData(
          message: MyLocalizations.of(context).noLocationsFound, icon: null);
    }
  }

  static Widget getLocationCard(
      List<dynamic> data,
      int index,
      BuildContext context,
      Map<String, dynamic> restaurantInfo,
      Map<String, dynamic> locationInfo,
      Map<String, Map<String, String>> localizedValues,
      var locale,
      String currency) {
    String locationName = data[index]['location']['locationName'];
    double rating = double.parse(data[index]['location']['rating'].toString());
    dynamic cuisine = data[index]['location']['cuisine'];
    String deliveryTime, deliveryChargeText, freeDeliveryText;
    if (data[index]['location']['deliveryInfo'] == null ||
        data[index]['location']['deliveryInfo']['deliveryInfo'] == null) {
      deliveryTime = deliveryChargeText = freeDeliveryText = null;
    } else {
      deliveryTime = data[index]['location']['deliveryInfo']['deliveryInfo']
              ['deliveryTime'] +
          ' M';
      deliveryChargeText = data[index]['location']['deliveryInfo']
              ['deliveryInfo']['freeDelivery']
          ? 'No Delivery charge'
          : 'Delivery charge $currency' +
              data[index]['deliveryInfo']['deliveryInfo']['deliveryCharges']
                  .toString();
      freeDeliveryText = data[index]['location']['deliveryInfo']['deliveryInfo']
              ['freeDelivery']
          ? 'Free delivery available'
          : 'Free delivery above \$' +
              data[index]['location']['deliveryInfo']['deliveryInfo']
                      ['amountEligibility']
                  .toString();
    }
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ProductListPage(
                localizedValues: localizedValues,
                locale: locale,
                restaurantName: restaurantInfo['list']['restaurantName'],
                locationName: locationName,
                aboutUs: data[index]['location']['aboutUs'],
                imgUrl: restaurantInfo['list']['logo'],
                address: data[index]['location']['address'],
                locationId: data[index]['location']['_id'],
                restaurantId: restaurantInfo['list']['_id'],
                cuisine: data[index]['location']['cuisine'],
                deliveryInfo: data[index]['location']['deliveryInfo'] != null
                    ? data[index]['location']['deliveryInfo']['deliveryInfo']
                    : null,
                workingHours: data[index]['location']['workingHours'] ?? null,
                locationInfo: locationInfo,
                taxInfo: restaurantInfo['list']['taxInfo']),
          ),
        );
      },
      child: LocationCard(
        locationName: locationName,
        rating: rating,
        cuisine: cuisine,
        deliveryTime: deliveryTime,
        deliveryChargeText: deliveryChargeText,
        freeDeliveryText: freeDeliveryText,
      ),
    );
  }

  static Widget buildSheetHeader(
      String logo, String name, int reviewCount, context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Image(
              image: logo != null
                  ? NetworkImage(logo)
                  : AssetImage('lib/assets/imgs/na.jpg'),
            ),
          ),
          Expanded(
            flex: 10,
            child: Column(
              children: [
                Text(
                  "${name[0].toUpperCase()}${name.substring(1)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
                reviewCount > 0
                    ? Text(
                        reviewCount.toString() +
                            " " +
                            MyLocalizations.of(context).usersReview,
                        textAlign: TextAlign.left,
                      )
                    : Text(''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildOutletInfo(int locationCount, context) {
    return locationCount != null
        ? Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              locationCount.toString() +
                  " " +
                  MyLocalizations.of(context).outletsDelivering,
              style: subBoldTitle(),
              textAlign: TextAlign.left,
            ),
          )
        : Container();
  }

  static Widget buildViewMoreButton(
    BuildContext context,
    Map<String, dynamic> restaurantInfo,
    List<dynamic> locations,
    Map<String, Map<String, String>> localizedValues,
    var locale,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: 120.0,
        right: 120.0,
        top: 5.0,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => LocationListPage(
                      restaurantInfo: restaurantInfo,
                      locations: locations,
                      locale: locale,
                      localizedValues: localizedValues,
                    )),
          );
        },
        child: Container(
          color: primaryLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add, size: 20.0),
              Text(MyLocalizations.of(context).viewAll),
            ],
          ),
        ),
      ),
    );
  }
}
