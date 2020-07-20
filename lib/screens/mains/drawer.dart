import 'dart:async';

import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/styles.dart';
import '../other/orders.dart';
import '../../services/common.dart';
import '../../screens/auth/login.dart';
import '../../screens/mains/cart.dart';
import '../other/about-us.dart';
import '../other/profile.dart';
import '../../services/profile-service.dart';
import '../../services/localizations.dart';

class DrawerPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Map localizedValues;
  final String locale;
  DrawerPage({Key key, this.scaffoldKey, this.locale, this.localizedValues})
      : super(key: key);
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int cartCounter;
  String profilePic, fullname;
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
          if (value != null && mounted) {
            if (mounted) {
              setState(() {
                profilePic = value['logo'];
                fullname = value['name'];
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: Container(
          child: Drawer(
            child: Center(
              child: ListView(
                children: <Widget>[
                  Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      _buildMenuBg(),
                      Column(
                        children: <Widget>[
                          _buildMenuProfileLogo(profilePic),
                          fullname != null
                              ? Text(fullname.toUpperCase(),
                                  style: TextStyle(color: Colors.white))
                              : Container(height: 0, width: 0),
                          _buildMenuTileList(
                            'lib/assets/icon/spoon.png',
                            MyLocalizations.of(context)
                                .getLocalizations("HOME"),
                            0,
                            route: HomePage(
                              locale: widget.locale,
                              localizedValues: widget.localizedValues,
                            ),
                          ),
                          _buildMenuTileList(
                            'lib/assets/icon/carte.png',
                            MyLocalizations.of(context)
                                .getLocalizations("CART"),
                            cartCounter != null ? cartCounter : 0,
                            route: CartPage(
                              locale: widget.locale,
                              localizedValues: widget.localizedValues,
                            ),
                          ),
                          isLoggedIn
                              ? _buildMenuTileList(
                                  'lib/assets/icon/orderHistory.png',
                                  MyLocalizations.of(context)
                                      .getLocalizations("MY_ORDERS"),
                                  0,
                                  route: OrdersPage(
                                    locale: widget.locale,
                                    localizedValues: widget.localizedValues,
                                  ),
                                )
                              : Container(height: 0, width: 0),
                          // isLoggedIn
                          //     ? _buildMenuTileList(
                          //         'lib/assets/icon/favorite.png',
                          //         MyLocalizations.of(context).favourites,
                          //         0,
                          //         route: Favorites(
                          //           locale: widget.locale,
                          //           localizedValues: widget.localizedValues,
                          //         ),
                          //       )
                          //     : Container(height: 0, width: 0),
                          isLoggedIn
                              ? _buildMenuTileList(
                                  'lib/assets/icon/settings.png',
                                  MyLocalizations.of(context)
                                      .getLocalizations("PROFILE"),
                                  0,
                                  route: ProfileApp(
                                      locale: widget.locale,
                                      localizedValues: widget.localizedValues),
                                )
                              : Container(height: 0, width: 0),
                          _buildMenuTileList(
                            'lib/assets/icon/about.png',
                            MyLocalizations.of(context)
                                .getLocalizations("ABOUT_US"),
                            0,
                            route: AboutUs(
                              locale: widget.locale,
                              localizedValues: widget.localizedValues,
                            ),
                          ),
                          !isLoggedIn
                              ? _buildMenuTileList(
                                  'lib/assets/icon/loginIcon.png',
                                  MyLocalizations.of(context)
                                      .getLocalizations("LOGIN"),
                                  0,
                                  route: LoginPage(
                                    locale: widget.locale,
                                    localizedValues: widget.localizedValues,
                                  ),
                                )
                              : Container(height: 0, width: 0),
                          isLoggedIn
                              ? _buildMenuTileList(
                                  'lib/assets/icon/loginIcon.png',
                                  MyLocalizations.of(context)
                                      .getLocalizations("LOGOUT"),
                                  0,
                                  check: false)
                              : Container(height: 0, width: 0),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBg() {
    return Image(
        image: AssetImage("lib/assets/bgImgs/confirmedbg.png"),
        fit: BoxFit.fill,
        height: 800.0);
  }

  Widget _buildMenuProfileLogo(String imgUrl) {
    return Padding(
      padding: EdgeInsets.only(top: 30.0, bottom: 20.0),
      child: imgUrl == null
          ? Image.asset(
              'lib/assets/imgs/na.jpg',
              width: 150.0,
              height: 50.0,
            )
          : Container(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              height: 90.0,
              width: 130.0,
              child: new CircleAvatar(
                backgroundImage: new NetworkImage(
                  "$imgUrl",
                ),
              ),
            ),
    );
  }

  Widget _buildMenuTileList(String icon, String name, int count,
      {Widget route, bool check}) {
    return GestureDetector(
      onTap: () {
        if (check == null) {
          if (route != null) {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => route));
          } else {
            Navigator.pop(context);
          }
        } else {
          if (!check) {
            if (mounted) {
              setState(() {
                isLoggedIn = true;
              });
            }
            Common.removeToken().then((onValue) {
              Common.removeCart().then((onValue) {
                showSnackbar(MyLocalizations.of(context)
                        .getLocalizations("LOGOUT_SUCCESSFULLY") +
                    '!');
                Navigator.pop(context);
                if (mounted) {
                  setState(() {
                    isLoggedIn = false;
                  });
                }
              });
            });
          }
        }
      },
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ListTile(
              leading: Image.asset(icon, width: 25.0),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              name,
              style: TextStyle(color: Colors.white, fontFamily: "bold"),
            ),
          ),
          count > 0
              ? Expanded(
                  flex: 1,
                  child: Container(
                    width: 26.0,
                    height: 26.0,
                    alignment: AlignmentDirectional.center,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: PRIMARY),
                    child: Text(
                      count.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Expanded(
                  flex: 0,
                  child: Container(height: 0, width: 0),
                ),
          Expanded(
            flex: 2,
            child: ListTile(
              trailing: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1500),
    );
    widget.scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
