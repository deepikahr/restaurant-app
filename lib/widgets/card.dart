import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';

Widget restaurantCard(BuildContext context, info, title) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        info['restaurantID']['logo'] != null ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            info['restaurantID']['logo'],
            width: 138,
            height: 108,
            fit: BoxFit.cover,
          ),
        ) : Image.asset(
          'lib/assets/images/dominos.png',
          width: 138,
          height: 108,
        ),
        SizedBox(width: 12,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 3),
            Text(
              info['restaurantID']['restaurantName'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textMuliSemiboldsm(),
            ),
            SizedBox(height: 5),
            Text(
              '${info['Locations']['locationName']}',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: textMuliRegularxs(),
            ),
            SizedBox(height: 3),
            Text(
              'Closes at 11:30 pm',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: textMuliRegularxs(),
            ),
            SizedBox(height: 3),
            Container(
              width: 30,
              height: 15,
              padding: EdgeInsets.only(left: 1, right: 1),
              color: Color(0xFF39B24A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 10,
                  ),
                  Text(
                    title == MyLocalizations.of(context).restaurantsNearYou ?
                    info['rating'].toString() : info['Locations']['rating'].toString(),
                    style: textMuliSemiboldwhitexs(),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    ),
  );
}


