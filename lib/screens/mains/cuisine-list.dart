import 'package:RestaurantSaas/services/counter-service.dart';
import 'package:RestaurantSaas/services/localizations.dart';
import 'package:RestaurantSaas/services/sentry-services.dart';
import 'package:RestaurantSaas/styles/styles.dart';
import 'package:RestaurantSaas/widgets/no-data.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';

import 'cart.dart';
import 'cusineBaseStore.dart';

SentryError sentryError = new SentryError();

class CuisineList extends StatefulWidget {
  final List<dynamic> cuisineList;
  final String title;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  const CuisineList(
      {Key key,
      this.localizedValues,
      this.locale,
      this.cuisineList,
      this.title})
      : super(key: key);

  @override
  _CuisineListState createState() => _CuisineListState();
}

class _CuisineListState extends State<CuisineList> {
  int cartCount;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
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
          widget.title,
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
      body: ((widget.cuisineList?.length ?? 0) > 0)
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.cuisineList.length,
                  padding: const EdgeInsets.all(0.0),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                CuisineBaseStores(
                              locale: widget.locale,
                              localizedValues: widget.localizedValues,
                              location: widget.cuisineList[index],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GFListTile(
                              color: Color(0xFFF4F4F4),
                              margin: EdgeInsets.all(0),
                              padding: EdgeInsets.only(
                                  top: 0, right: 10, left: 0, bottom: 0),
                              avatar: widget.cuisineList[index]
                                          ['cuisineImgUrl'] !=
                                      null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5)),
                                      child: Image(
                                          fit: BoxFit.cover,
                                          height: 65,
                                          width: 60,
                                          image: NetworkImage(
                                              widget.cuisineList[index]
                                                  ['cuisineImgUrl'])),
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
                                widget?.cuisineList[index]['cuisineName'] ?? '',
                                style: textsemiboldblack(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
                  }),
            )
          : NoData(
              message: MyLocalizations.of(context).noCuisines,
              icon: Icons.block),
    );
  }
}
