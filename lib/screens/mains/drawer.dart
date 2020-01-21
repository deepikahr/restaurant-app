import 'package:RestaurantSaas/screens/mains/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../styles/styles.dart';
import '../other/orders.dart';
import '../other/favorites.dart';
import '../../services/common.dart';
import '../../screens/auth/login.dart';
import '../../screens/mains/cart.dart';
import '../other/about-us.dart';
import '../other/profile.dart';
import '../../services/profile-service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

class drawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Map<String, Map<String, String>> localizedValues;
  var locale;
  drawer({Key key, this.scaffoldKey, this.locale, this.localizedValues})
      : super(key: key);
  @override
  _drawerState createState() => _drawerState();
}

class _drawerState extends State<drawer> {
  String name;
  String email;
  String profileImage;
  String gender;
  int phone;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int cartCounter;
  String profilePic;
  String fullname;
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
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage');
    });
  }

  void _getCartLength() async {
    await Common.getCart().then((onValue) {
      if (onValue != null) {
        setState(() {
          cartCounter = onValue['productDetails'].length;
        });
      } else {
        setState(() {
          cartCounter = 0;
        });
      }
    });
  }

  Future _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Common.getToken().then((token) {
      if (token != null) {
        setState(() {
          isLoggedIn = true;
        });
        ProfileService.getUserInfo().then((value) {
          if (value != null && mounted) {
            setState(() {
              profilePic = value['logo'];
              fullname = value['name'];
              isLoggedIn = true;
            });
          }
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Drawer(
            child: MaterialApp(
      locale: Locale(widget.locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        MyLocalizationsDelegate(widget.localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: languages.map((language) => Locale(language, '')),
      home: Container(
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
                        _buildMenuProfileLogo(profileImage),
                        fullname != null
                            ? Text(fullname.toUpperCase(),
                                style: TextStyle(color: Colors.white))
                            : Container(height: 0, width: 0),
                        _buildMenuTileList(
                          'lib/assets/icon/spoon.png',
                          MyLocalizations.of(context).home,
                          0,
                          route: HomePage(
                            locale: widget.locale,
                            localizedValues: widget.localizedValues,
                          ),
                        ),
                        _buildMenuTileList(
                          'lib/assets/icon/carte.png',
                          MyLocalizations.of(context).cart,
                          cartCounter != null ? cartCounter : 0,
                          route: CartPage(
                            locale: widget.locale,
                            localizedValues: widget.localizedValues,
                          ),
                        ),
                        isLoggedIn
                            ? _buildMenuTileList(
                                'lib/assets/icon/orderHistory.png',
                                MyLocalizations.of(context).myOrders,
                                0,
                                route: OrdersPage(
                                  locale: widget.locale,
                                  localizedValues: widget.localizedValues,
                                ),
                              )
                            : Container(height: 0, width: 0),
                        isLoggedIn
                            ? _buildMenuTileList(
                                'lib/assets/icon/favorite.png',
                                MyLocalizations.of(context).favourites,
                                0,
                                route: Favorites(
                                  locale: widget.locale,
                                  localizedValues: widget.localizedValues,
                                ),
                              )
                            : Container(height: 0, width: 0),
                        isLoggedIn
                            ? _buildMenuTileList(
                                'lib/assets/icon/settings.png',
                                MyLocalizations.of(context).profile,
                                0,
                                route: ProfileApp(
                                    locale: widget.locale,
                                    localizedValues: widget.localizedValues),
                              )
                            : Container(height: 0, width: 0),
                        _buildMenuTileList(
                          'lib/assets/icon/about.png',
                          MyLocalizations.of(context).aboutUs,
                          0,
                          route: AboutUs(
                            locale: widget.locale,
                            localizedValues: widget.localizedValues,
                          ),
                        ),
                        !isLoggedIn
                            ? _buildMenuTileList(
                                'lib/assets/icon/loginIcon.png',
                                MyLocalizations.of(context).login,
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
                                MyLocalizations.of(context).logout,
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
    )));
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
                )));
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
            setState(() {
              isLoggedIn = true;
            });
            Common.removeToken().then((onValue) {
              Common.removeCart().then((onValue) {
                showSnackbar(
                    MyLocalizations.of(context).logoutSuccessfully + '!');
                //
                Navigator.pop(context);
                setState(() {
                  isLoggedIn = false;
                });
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
                      // style: hintStyleLightOSB(),
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
