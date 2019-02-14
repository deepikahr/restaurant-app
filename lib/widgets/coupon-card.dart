import 'package:flutter/material.dart';

class CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;

  CouponCard({Key key, this.coupon}) : super(key: key);

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
            buildCuisineHolder(),
            buildCardBottom(context),
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
            coupon['couponName'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              height: 1.0,
            ),
          ),
          flex: 6,
        ),
      ],
    );
  }

  Widget buildCuisineHolder() {
    return Text(
      coupon['description'].toUpperCase(),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 11.0,
        height: 1.4,
      ),
    );
  }

  Widget buildCardBottom(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: Row(
                children: <Widget>[
                  Text(coupon['offPrecentage'].toString() + '% off',
                      style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, coupon);
                },
                child: Text('APPLY', style: TextStyle(color: Colors.amber)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
