import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

Widget homeAppbar(BuildContext context, isNearByRestaurants, searchOnTap,
    cartCount, cartOnTap, scaffoldKey) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.black),
    elevation: 0,
    backgroundColor: Colors.transparent,
    centerTitle: true,
    leading: InkWell(
      onTap: () => scaffoldKey.currentState.openDrawer(),
      child: Image.asset(
        'lib/assets/icons/drawer.png',
        scale: 2.4,
      ),
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isNearByRestaurants
                ? Padding(
                    padding: EdgeInsets.only(top: 14.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 28,
                        color: secondary,
                      ),
                      onPressed: searchOnTap,
                    ),
                  )
                : Container(),
            Stack(
              children: [
                InkWell(
                  onTap: cartOnTap,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0, right: 10),
                    child: Image.asset(
                      'lib/assets/icons/cart.png',
                      scale: 2.4,
                    ),
                  ),
                ),
                Positioned(
                    right: 6,
                    top: 10,
                    child: (cartCount == null || cartCount == 0)
                        ? Container()
                        : GFBadge(
                            shape: GFBadgeShape.circle,
                            color: Colors.black,
                            size: 35,
                            child: Text(
                              '${cartCount.toString()}',
                              style: textboldWhitesm(),
                            ),
                          )),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget appBarWithCartAndTitle(BuildContext context, title, cartCount, cartOnTap) {
  return AppBar(
    elevation: 2.0,
    backgroundColor: Colors.white,
    centerTitle: true,
    title: Text(
      title,
      style: textMuliSemibold(),
    ),
    actions: <Widget>[
      Stack(
        children: [
          InkWell(
            onTap: cartOnTap,
            child: Padding(
              padding: EdgeInsets.only(top: 16.0, right: 10),
              child: Image.asset(
                'lib/assets/icons/cart.png',
                scale: 2.4,
              ),
            ),
          ),
          Positioned(
              right: 6,
              top: 10,
              child: (cartCount == null || cartCount == 0)
                  ? Container()
                  : GFBadge(
                shape: GFBadgeShape.circle,
                color: Colors.black,
                size: 35,
                child: Text(
                  '${cartCount.toString()}',
                  style: textboldWhitesm(),
                ),
              )),
        ],
      ),
    ],
  );
}


Widget appBarWithCart(BuildContext context, cartCount, cartOnTap) {
  return AppBar(
    elevation: 2.0,
    backgroundColor: Colors.white,
    actions: <Widget>[
      Stack(
        children: [
          InkWell(
            onTap: cartOnTap,
            child: Padding(
              padding: EdgeInsets.only(top: 16.0, right: 10),
              child: Image.asset(
                'lib/assets/icons/cart.png',
                scale: 2.4,
              ),
            ),
          ),
          Positioned(
              right: 6,
              top: 10,
              child: (cartCount == null || cartCount == 0)
                  ? Container()
                  : GFBadge(
                      shape: GFBadgeShape.circle,
                      color: Colors.black,
                      size: 35,
                      child: Text(
                        '${cartCount.toString()}',
                        style: textboldWhitesm(),
                      ),
                    )),
        ],
      ),
    ],
  );
}

Widget appBarWithTitle(BuildContext context, title) {
  return AppBar(
    elevation: 2.0,
    backgroundColor: Colors.white,
    centerTitle: true,
    title: Text(
      title,
      style: textMuliSemibold(),
    ),
  );
}

Widget authAppBarWithTitle(BuildContext context, title) {
  return AppBar(
    elevation: 2.0,
    backgroundColor: Colors.white,
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: Text(
      title,
      style: textMuliSemibold(),
    ),
  );
}
