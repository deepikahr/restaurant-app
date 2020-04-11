import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../services/localizations.dart';

class LocationCard extends StatelessWidget {
  final String locationName;
  final double rating;
  final List<dynamic> cuisine;
  final String deliveryTime;
  final String deliveryChargeText;
  final String freeDeliveryText;

  LocationCard(
      {Key key,
      this.locationName,
      this.rating,
      this.cuisine,
      this.deliveryTime,
      this.deliveryChargeText,
      this.freeDeliveryText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCardHeader(),
            buildCuisineHolder(context),
            deliveryTime != null ? buildCardBottom() : Text(''),
          ],
        ),
      ),
    );
  }

  Widget buildCardHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            locationName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              height: 1.0,
            ),
          ),
          flex: 6,
        ),
        Expanded(
          child: rating > 0
              ? Container(
                  margin: EdgeInsets.only(
                    right: 3.0,
                    top: 3.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(' '),
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12.0,
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: PRIMARY,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                )
              : Text(''),
          flex: 1,
        ),
      ],
    );
  }

  Widget buildCuisineHolder(context) {
    return Text(
      getCuisines(cuisine, context),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 11.0,
        height: 1.4,
      ),
    );
  }

  Widget buildCardBottom() {
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.timelapse,
                    size: 13.0,
                  ),
                  Text(' ' + deliveryTime),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.monetization_on,
                    size: 13.0,
                  ),
                  Text(' ' + deliveryChargeText),
                ],
              ),
            ),
          ],
        ),
        Divider(),
        Row(
          children: <Widget>[
            Icon(
              Icons.explore,
              color: Colors.amber,
              size: 17.0,
            ),
            Text(
              '  ' + freeDeliveryText,
              style: TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ],
    );
  }

  static String getCuisines(cuisines, context) {
    String cuisine = '';
    cuisines.forEach((c) {
      String cui = c['itemName'] ?? c['cuisineName'] ?? '';
      cuisine = cuisine + cui + ', ';
    });
    if (cuisine.length > 2)
      return cuisine.substring(0, cuisine.length - 2).toUpperCase();
    else
      return MyLocalizations.of(context).noCuisines;
  }
}
