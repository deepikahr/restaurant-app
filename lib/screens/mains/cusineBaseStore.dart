import 'package:RestaurantSaas/screens/mains/product-list.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class CuisineBaseStores extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;
  final Map location;

  CuisineBaseStores({Key key, this.locale, this.localizedValues, this.location})
      : super(key: key);

  @override
  _CuisineBaseStoresState createState() => _CuisineBaseStoresState();
}

class _CuisineBaseStoresState extends State<CuisineBaseStores> {
  String review, branches;

  @override
  Widget build(BuildContext context) {
    review = MyLocalizations.of(context).reviews;
    branches = MyLocalizations.of(context).branches;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: new Text(
          widget.location['cuisineName'],
          style: textbarlowSemiBoldWhite(),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ((widget.location?.length ?? 0) > 0)
          ? ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.location['locations'].length == null
                  ? 0
                  : widget.location['locations'].length,
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    child: buildRestaurantCard(
                        widget.location['locations'][index],
                        review,
                        branches,
                        false),
                    onTap: () {
                      goToProductListPage(
                          context,
                          widget.location['locations'][index],
                          false,
                          widget.localizedValues,
                          widget.locale);
                    });
              })
          : Container(),
    );
  }

  static Widget buildRestaurantCard(
      info, review, branches, isNearByRestaurants) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        buildCardBottom(
            info['locationName'],
            info['restaurantID']['logo'] ?? null,
            info['restaurantID']['restaurantName'],
            double.parse(info['rating'].toString() ?? '0'),
            info['locationCount'] ?? 0,
            info['restaurantID']['reviewCount'] ?? 0,
            review,
            branches),
      ],
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
            shippingType: data['restaurantID']['shippingType'],
            deliveryCharge: data['restaurantID']['deliveryCharge'],
            minimumOrderAmount: data['restaurantID']['minimumOrderAmount'] ?? 0,
            localizedValues: localizedValues,
            locale: locale,
            restaurantName: data['restaurantID']['restaurantName'],
            locationName: data['locationName'],
            aboutUs: data['aboutUs'],
            imgUrl: data['restaurantID']['logo'] ?? '',
            address: data['address'],
            locationId: data['_id'],
            restaurantId: data['restaurantID']['_id'],
            cuisine: data['cuisine'] ?? null,
            workingHours: data['workingHours'],
            locationInfo: {
                  '_id': data['_id'],
                  "locationName": data['locationName'],
                  "workingHours": data['workingHours']
                } ??
                null,
            taxInfo: data['taxInfo'] ?? null),
      ),
    );
  }
}
