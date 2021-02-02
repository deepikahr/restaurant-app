import 'dart:async';

import 'package:RestaurantSaas/screens/mains/home/home.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/login.dart';
import '../checkout/cart.dart';
import '../../../services/common.dart';
import '../../../services/localizations.dart';
import '../../../services/profile-service.dart';
import '../../../styles/styles.dart';
import '../../other/about-us.dart';
import '../orders/orders.dart';
import '../../other/profile.dart';

class DrawerPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  DrawerPage({Key key, this.scaffoldKey, this.locale, this.localizedValues})
      : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int cartCounter;
  String profilePic, fullname, email;
  bool isLoggedIn = false;

  @override
  void initState() {
    _checkLoginStatus();
    _getCartLength();
    selectedLanguages();
    super.initState();
  }

  var selectedLanguage;

  selectedLanguages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selectedLanguage = prefs.getString('selectedLanguage');
      });
    }
  }

  void _getCartLength() async {
    await Common.getCart().then((onValue) {
      if (onValue != null) {
        if (mounted) {
          setState(() {
            cartCounter = onValue['productDetails'].length;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            cartCounter = 0;
          });
        }
      }
    });
  }

  Future _checkLoginStatus() async {
    Common.getToken().then((token) {
      if (token != null) {
        if (mounted) {
          setState(() {
            isLoggedIn = true;
          });
        }
        ProfileService.getUserInfo().then((value) {
          // print('vv ${value['email']}');
          if (value != null && mounted) {
            if (mounted) {
              setState(() {
                profilePic = value['logo'];
                fullname = value['name'];
                email = value['email'];
                isLoggedIn = true;
              });
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            isLoggedIn = false;
          });
        }
      }
    });
  }

  Widget titleRow(title, image, navigateTo) {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: secondary.withOpacity(0.1)))),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navigateTo),
          );
        },
        child: Row(
          children: <Widget>[
            Image.asset(
              image,
              width: 25,
              height: 25,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: textMuliRegularwithop(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          ListView(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(
                            locale: widget.locale,
                            localizedValues: widget.localizedValues)),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  height: 148,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFFFF9C5D),
                      Color(0xFFFF764D),
                    ],
                  )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GFAvatar(
                            size: 36,
                            shape: GFAvatarShape.circle,
                            backgroundImage: profilePic != null
                                ? NetworkImage(profilePic)
                                : AssetImage('lib/assets/imgs/na.jpg'),
                          ),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                fullname != null ? fullname.toUpperCase() : '',
                                style: textMuliSemiboldwhitee(),
                              ),
                              Text(
                                email != null ? email : '',
                                style: textMuliRegularwhitesm(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 15, color: Colors.white),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              titleRow(
                  'Home',
                  'lib/assets/icons/home.png',
                  HomePage(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues)),
              isLoggedIn
                  ? titleRow(
                      'My Cart',
                      'lib/assets/icons/cart.png',
                      CartPage(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues))
                  : Container(),
              isLoggedIn
                  ? titleRow(
                      'Order History',
                      'lib/assets/icons/orders.png',
                      OrdersPage(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues))
                  : Container(),
              isLoggedIn
                  ? titleRow(
                      'Profile',
                      'lib/assets/icons/fav.png',
                      Profile(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues))
                  : Container(),
              titleRow(
                  'About Us',
                  'lib/assets/icons/about.png',
                  AboutUs(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues)),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 270,
              height: 41,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.09), blurRadius: 0)
                  ]),
              child: RaisedButton(
                color: Color(0xFFF6F6F6),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                onPressed: () {
                  if (!isLoggedIn) {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(
                                locale: widget.locale,
                                localizedValues: widget.localizedValues)));
                  } else {
                    if (mounted) {
                      setState(() {
                        isLoggedIn = true;
                      });
                    }
                    Common.removeToken().then((onValue) {
                      showSnackbar(
                          MyLocalizations.of(context).logoutSuccessfully + '!');
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          isLoggedIn = false;
                        });
                      }
                    });
                  }
                },
                child: Text(
                  isLoggedIn ? 'Logout' : 'Login',
                  style: textMuliSemibold(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    //   Container(
    //   child: Drawer(
    //     child: Container(
    //       child: Drawer(
    //         child: Center(
    //           child: ListView(
    //             children: <Widget>[
    //               Stack(
    //                 fit: StackFit.passthrough,
    //                 children: <Widget>[
    //                   _buildMenuBg(),
    //                   Column(
    //                     children: <Widget>[
    //                       _buildMenuProfileLogo(profilePic),
    //                       fullname != null
    //                           ? Text(fullname.toUpperCase(),
    //                               style: TextStyle(color: Colors.white))
    //                           : Container(height: 0, width: 0),
    //                       _buildMenuTileList(
    //                         'lib/assets/icon/spoon.png',
    //                         MyLocalizations.of(context).homePage,
    //                         0,
    //                         route: HomePage(
    //                           locale: widget.locale,
    //                           localizedValues: widget.localizedValues,
    //                         ),
    //                       ),
    //                       _buildMenuTileList(
    //                         'lib/assets/icon/carte.png',
    //                         MyLocalizations.of(context).cart,
    //                         cartCounter != null ? cartCounter : 0,
    //                         route: CartPage(
    //                           locale: widget.locale,
    //                           localizedValues: widget.localizedValues,
    //                         ),
    //                       ),
    //                       isLoggedIn
    //                           ? _buildMenuTileList(
    //                               'lib/assets/icon/orderHistory.png',
    //                               MyLocalizations.of(context).myOrders,
    //                               0,
    //                               route: OrdersPage(
    //                                 locale: widget.locale,
    //                                 localizedValues: widget.localizedValues,
    //                               ),
    //                             )
    //                           : Container(height: 0, width: 0),
    //                       // isLoggedIn
    //                       //     ? _buildMenuTileList(
    //                       //         'lib/assets/icon/favorite.png',
    //                       //         MyLocalizations.of(context).favourites,
    //                       //         0,
    //                       //         route: Favorites(
    //                       //           locale: widget.locale,
    //                       //           localizedValues: widget.localizedValues,
    //                       //         ),
    //                       //       )
    //                       //     : Container(height: 0, width: 0),
    //                       isLoggedIn
    //                           ? _buildMenuTileList(
    //                               'lib/assets/icon/settings.png',
    //                               MyLocalizations.of(context).profile,
    //                               0,
    //                               route: ProfileApp(
    //                                   locale: widget.locale,
    //                                   localizedValues: widget.localizedValues),
    //                             )
    //                           : Container(height: 0, width: 0),
    //                       _buildMenuTileList(
    //                         'lib/assets/icon/about.png',
    //                         MyLocalizations.of(context).aboutUs,
    //                         0,
    //                         route: AboutUs(
    //                           locale: widget.locale,
    //                           localizedValues: widget.localizedValues,
    //                         ),
    //                       ),
    //                       !isLoggedIn
    //                           ? _buildMenuTileList(
    //                               'lib/assets/icon/loginIcon.png',
    //                               MyLocalizations.of(context).login,
    //                               0,
    //                               route: LoginPage(
    //                                 locale: widget.locale,
    //                                 localizedValues: widget.localizedValues,
    //                               ),
    //                             )
    //                           : Container(height: 0, width: 0),
    //                       isLoggedIn
    //                           ? _buildMenuTileList(
    //                               'lib/assets/icon/loginIcon.png',
    //                               MyLocalizations.of(context).logout,
    //                               0,
    //                               check: false)
    //                           : Container(height: 0, width: 0),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1500),
    );
    widget.scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
