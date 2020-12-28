import 'package:RestaurantSaas/screens/other/order-details.dart';
import 'package:RestaurantSaas/screens/other/order-track.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget restaurantCard(BuildContext context, info, title) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        info['restaurantID']['logo'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  info['restaurantID']['logo'],
                  width: 138,
                  height: 108,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'lib/assets/images/dominos.png',
                width: 138,
                height: 108,
              ),
        SizedBox(
          width: 12,
        ),
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
                    title == MyLocalizations.of(context).restaurantsNearYou
                        ? info['rating'].toString()
                        : info['Locations']['rating'].toString(),
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

Widget orderCard(
    BuildContext context,
    orderData,
    isRatingAllowed,
    final String locale,
    Map<String, Map<String, String>> localizedValues,
    currency) {
  return Container(
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 10),
    color: Colors.white,
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            orderData['productDetails'][0]['imageUrl'] != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                      orderData['productDetails'][0]['imageUrl'],
                      width: 45,
                      height: 45, fit: BoxFit.cover,
                    ),
                )
                : Image.asset("lib/assets/bgImgs/loginbg.png",   width: 45,
              height: 45, fit: BoxFit.cover,),
            SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  orderData['productDetails'][0]['restaurant'],
                  style: textMuliSemiboldm(),
                ),
                Text(
                  MyLocalizations.of(context).type +
                      ": " +
                      orderData['orderType'],
                  style: textMuliRegularxswithop(),
                )
              ],
            )
          ],
        ),
        SizedBox(height: 14),
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Order ID:',
                    style: textMuliRegularxswithop(),
                  ),
                  Text(
                    orderData['orderID'].toString(),
                    style: textMuliRegularxswithop(),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Order On:',
                    style: textMuliRegularxswithop(),
                  ),
                  Text(
                    orderData['createdAtTime'] == null
                        ? ""
                        : DateFormat('dd-MMM-yy hh:mm a').format(
                            new DateTime.fromMillisecondsSinceEpoch(
                                orderData['createdAtTime']),
                          ),
                    style: textMuliRegularxswithop(),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'status:',
                    style: textMuliRegularxsgreen(),
                  ),
                  Text(
                    orderData['status'],
                    style: textMuliRegularxsgreen(),
                  ),
                ],
              )
            ],
          ),
        SizedBox(height: 14),
        MySeparator(color: secondary.withOpacity(0.2)),
        SizedBox(height: 14),
        ListView.builder(
            itemCount: orderData['productDetails'].length,
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    orderData['productDetails'][index]['title'],
                    style: textMuliSemiboldxs(),
                  ),
                  isRatingAllowed
                      ? Expanded(
                          flex: 2,
                          child: (orderData['productDetails'][index]
                                      ['productRating'] ==
                                  null)
                              ? Container()
                              : Container(
                                  child: Row(
                                  children: <Widget>[
                                    Text(
                                      orderData['productDetails'][index]
                                                  ['productDetails'][index]
                                              ['RatingInfo']
                                          .toString(),
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ],
                                )),
                        )
                      : Expanded(flex: 0, child: Container()),
                  Text(
                    '$currency' +
                        orderData['productDetails'][index]['totalPrice']
                            .toStringAsFixed(2),
                    style: textMuliSemiboldxs(),
                  ),
                ],
              );
            }),
        SizedBox(height: 10),
        orderData['orderType'] == 'Pickup'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${MyLocalizations.of(context).pickUpTime} : ',
                    style: textMuliSemiboldxsgreen(),
                  ),
                  Text(
                    '${orderData['pickupDate'] == null ? "" : orderData['pickupDate']} '
                    ' ${orderData['pickupTime'] == null ? "" : orderData['pickupTime']}',
                    style: textMuliSemiboldxsgreen(),
                  ),
                ],
              )
            : Container(),
        orderData['tableNumber'] != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${MyLocalizations.of(context).tableNo} : ',
                    style: textMuliSemiboldxsgreen(),
                  ),
                  Text(
                    '${orderData['tableNumber'].toString()}',
                    style: textMuliSemiboldxsgreen(),
                  ),
                ],
              )
            : Container(),
        SizedBox(height: 10),
        Text("${MyLocalizations.of(context).paymentMode}: " +
            (orderData['paymentOption'] == 'Stripe' || orderData['paymentOption'] == "CREDIT CARD"
                ? 'CC'
                : orderData['paymentOption']), style: textMuliSemiboldsec(),),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              // width: 155,
              height: 30,
              margin: EdgeInsets.all(8),
              child: RaisedButton(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                      side: BorderSide(color: secondary)),
                  onPressed: () {},
                  child: Text(
                    "${MyLocalizations.of(context).grandTotal}: $currency" +
                        orderData['grandTotal'].toStringAsFixed(2),
                    style: textMuliSemiboldsec(),
                  )),
            ),
            Container(
              // width: 155,
              height: 30,
              child: RaisedButton(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                      side: BorderSide(color: primary)),
                  onPressed: () {
                    if (!isRatingAllowed) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => OrderDetails(
                            orderId: orderData['_id'],
                            locale: locale,
                            localizedValues: localizedValues,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => OrderTrack(
                            orderId: orderData['_id'],
                            locale: locale,
                            localizedValues: localizedValues,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isRatingAllowed
                        ? MyLocalizations.of(context).view
                        : MyLocalizations.of(context).track,
                    style: textMuliSemiboldprimary(),
                  )),
            ),
          ],
        ),
      ],
    ),
  );
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
