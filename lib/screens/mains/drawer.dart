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
import 'restaurant-list.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
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
    print(widget.locale);
    print(widget.localizedValues);
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

  // void _getFavLength() {
  //   ProfileService.getFavouritList().then((onValue) {
  //     if (onValue != null) {
  //       setState(() {
  //         favCounter = onValue.length;
  //       });
  //     } else {
  //       setState(() {
  //         favCounter = 0;
  //       });
  //     }
  //   });
  // }

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
                        // _buildMenuTileList(
                        //   'lib/assets/icon/carte.png',
                        //   MyLocalizations.of(context).o,
                        //   0,
                        //   route: offers(
                        //     locale: widget.locale,
                        //     localizedValues: widget.localizedValues,
                        //   ),
                        // ),
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
                        // isLoggedIn
                        //     ? _buildMenuTileList('lib/assets/icon/chat.png',
                        //         MyLocalizations.of(context).chat, 0,
                        //         route: Chat(
                        //           locale: widget.locale,
                        //           localizedValues: widget.localizedValues,
                        //         ))
                        //     : Container(height: 0, width: 0),
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

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../styles/styles.dart';
// import '../other/orders.dart';
// import '../other/favorites.dart';
// import '../../services/common.dart';
// import '../../screens/auth/login.dart';
// import '../../screens/mains/cart.dart';
// import '../other/about-us.dart';
// import '../other/profile.dart';
// import '../../services/profile-service.dart';
// import 'restaurant-list.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';

// import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
// import 'package:RestaurantSaas/constant.dart' show languages;
// import 'package:RestaurantSaas/localizations.dart'
//     show MyLocalizations, MyLocalizationsDelegate;

// class Menu extends StatefulWidget {
//   final GlobalKey<ScaffoldState> scaffoldKey;
//   final Map<String, Map<String, String>> localizedValues;
//   String locale;
//   Menu({Key key, this.scaffoldKey, this.locale, this.localizedValues})
//       : super(key: key);
//   @override
//   _MenuState createState() => _MenuState();
// }

// class _MenuState extends State<Menu> {
//   int cartCounter;
//   int favCounter;
//   String profilePic;
//   String fullname;
//   bool isLoggedIn = false;

//   @override
//   void initState() {
//     _checkLoginStatus();
//     _getCartLength();
//     selectedLanguages();
//     super.initState();
//   }

//   var selectedLanguage;

//   selectedLanguages() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedLanguage = prefs.getString('selectedLanguage');
//     });
//   }

//   void _getCartLength() async {
//     await Common.getCart().then((onValue) {
//       if (onValue != null) {
//         setState(() {
//           cartCounter = onValue['productDetails'].length;
//         });
//       } else {
//         setState(() {
//           cartCounter = 0;
//         });
//       }
//     });
//   }

//   void _getFavLength() {
//     ProfileService.getFavouritList().then((onValue) {
//       if (onValue != null) {
//         setState(() {
//           favCounter = onValue.length;
//         });
//       } else {
//         setState(() {
//           favCounter = 0;
//         });
//       }
//     });
//   }

//   Future _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Common.getToken().then((token) {
//       if (token != null) {
//         setState(() {
//           isLoggedIn = true;
//         });
//         ProfileService.getUserInfo().then((value) {
//           if (value != null && mounted) {
//             setState(() {
//               profilePic = value['logo'];
//               fullname = value['name'];
//               isLoggedIn = true;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isLoggedIn = false;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         locale: Locale(widget.locale),
//         debugShowCheckedModeBanner: false,
//         localizationsDelegates: [
//           MyLocalizationsDelegate(widget.localizedValues),
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//         ],
//         supportedLocales: languages.map((language) => Locale(language, '')),
//         home: Container(
//           child: Drawer(
//             child: Center(
//               child: ListView(
//                 children: <Widget>[
//                   Stack(
//                     fit: StackFit.passthrough,
//                     children: <Widget>[
//                       _buildMenuBg(),
//                       Column(
//                         children: <Widget>[
//                           _buildMenuProfileLogo(profilePic),
//                           fullname != null
//                               ? Text(fullname.toUpperCase(),
//                                   style: hintStyleWhitePNR())
//                               : Container(height: 0, width: 0),
//                           Divider(color: Colors.white12),
//                           _buildMenuTileList('lib/lib/assets/icon/spoon.png',
//                               MyLocalizations.of(context).home, 0),
//                           Divider(color: Colors.white12),
//                           // _buildMenuTileList(
//                           //     'lib/lib/assets/icon/spoon.png', 'Near by me', 0,
//                           //     route: RestaurantListPage(title: 'Near By')),
//                           // Divider(color: Colors.white12),
//                           _buildMenuTileList(
//                               'lib/lib/assets/icon/carte.png',
//                               MyLocalizations.of(context).cart,
//                               cartCounter != null ? cartCounter : 0,
//                               route: CartPage(
//                                 locale: widget.locale,
//                                 localizedValues: widget.localizedValues,
//                               )),
//                           isLoggedIn
//                               ? Divider(color: Colors.white12)
//                               : Container(height: 0, width: 0),
//                           isLoggedIn
//                               ? _buildMenuTileList(
//                                   'lib/lib/assets/icon/orderHistory.png',
//                                   MyLocalizations.of(context).myOrders,
//                                   0,
//                                   route: OrdersPage(
//                                       locale: widget.locale,
//                                       localizedValues: widget.localizedValues))
//                               : Container(height: 0, width: 0),
//                           isLoggedIn
//                               ? Divider(color: Colors.white12)
//                               : Container(height: 0, width: 0),
//                           isLoggedIn
//                               ? _buildMenuTileList(
//                                   'lib/lib/assets/icon/favorite.png',
//                                   MyLocalizations.of(context).favourites,
//                                   0,
//                                   route: Favorites(
//                                       locale: widget.locale,
//                                       localizedValues: widget.localizedValues))
//                               : Container(height: 0, width: 0),
//                           // Divider(color: Colors.white12),
//                           // isLoggedIn
//                           //     ? _buildMenuTileList(
//                           //         'lib/assets/icon/chat.png', 'Chat', 0)
//                           //     : Container(height: 0, width: 0),
//                           // isLoggedIn
//                           //     ? Divider(color: Colors.white12)
//                           //     : Container(height: 0, width: 0),
//                           isLoggedIn
//                               ? _buildMenuTileList(
//                                   'lib/assets/icon/settings.png',
//                                   MyLocalizations.of(context).profile,
//                                   0,
//                                   route: Profile(
//                                       locale: widget.locale,
//                                       localizedValues: widget.localizedValues))
//                               : Container(height: 0, width: 0),
//                           Divider(color: Colors.white12),
//                           _buildMenuTileList('lib/assets/icon/about.png',
//                               MyLocalizations.of(context).aboutUs, 0,
//                               route: AboutUs(
//                                   locale: widget.locale,
//                                   localizedValues: widget.localizedValues)),
//                           !isLoggedIn
//                               ? Divider(color: Colors.white12)
//                               : Container(height: 0, width: 0),
//                           !isLoggedIn
//                               ? _buildMenuTileList(
//                                   'lib/assets/icon/loginIcon.png',
//                                   MyLocalizations.of(context).login,
//                                   0,
//                                   route: LoginPage(
//                                       locale: widget.locale,
//                                       localizedValues: widget.localizedValues))
//                               : Container(height: 0, width: 0),
//                           isLoggedIn
//                               ? Divider(color: Colors.white12)
//                               : Container(height: 0, width: 0),
//                           isLoggedIn
//                               ? _buildMenuTileList(
//                                   'lib/assets/icon/loginIcon.png',
//                                   MyLocalizations.of(context).logout,
//                                   0,
//                                   check: false)
//                               : Container(height: 0, width: 0),
//                           Divider(color: Colors.white12),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }

//   Widget _buildMenuBg() {
//     return Image(
//         image: AssetImage("lib/assets/bgImgs/confirmedbg.png"),
//         fit: BoxFit.fill,
//         height: 800.0);
//   }

//   Widget _buildMenuProfileLogo(String imgUrl) {
//     return Padding(
//         padding: EdgeInsets.only(top: 30.0, bottom: 20.0),
//         child: imgUrl == null
//             ? Image.asset(
//                 'lib/assets/imgs/na.jpg',
//                 width: 150.0,
//                 height: 50.0,
//               )
//             : Container(
//                 padding: EdgeInsets.only(
//                   left: 20.0,
//                   right: 20.0,
//                 ),
//                 height: 90.0,
//                 width: 130.0,
//                 child: new CircleAvatar(
//                   backgroundImage: new NetworkImage(
//                     "$imgUrl",
//                   ),
//                 )));
//   }

//   Widget _buildMenuTileList(String icon, String name, int count,
//       {Widget route, bool check}) {
//     return GestureDetector(
//       onTap: () {
//         if (check == null) {
//           if (route != null) {
//             Navigator.pop(context);
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (BuildContext context) => route));
//           } else {
//             Navigator.pop(context);
//           }
//         } else {
//           if (!check) {
//             Common.removeToken().then((onValue) {
//               setState(() {
//                 isLoggedIn = false;
//               });
//               Common.removeCart().then((onValue) {
//                 showSnackbar('Logout Successfully!');
//                 Navigator.pop(context);
//               });
//             });
//           }
//         }
//       },
//       child: Row(
//         children: <Widget>[
//           Expanded(
//             flex: 2,
//             child: ListTile(
//               leading: Image.asset(icon, width: 25.0),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: Text(
//               name,
//               style: hintStyleWhitePNR(),
//             ),
//           ),
//           count > 0
//               ? Expanded(
//                   flex: 1,
//                   child: Container(
//                     width: 26.0,
//                     height: 26.0,
//                     alignment: AlignmentDirectional.center,
//                     decoration:
//                         BoxDecoration(shape: BoxShape.circle, color: PRIMARY),
//                     child: Text(
//                       count.toString(),
//                       textAlign: TextAlign.center,
//                       style: hintStyleLightOSB(),
//                     ),
//                   ),
//                 )
//               : Expanded(
//                   flex: 0,
//                   child: Container(height: 0, width: 0),
//                 ),
//           Expanded(
//             flex: 2,
//             child: ListTile(
//               trailing: Icon(Icons.chevron_right, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void showSnackbar(message) {
//     final snackBar = SnackBar(
//       content: Text(message),
//       duration: Duration(milliseconds: 3000),
//     );
//     widget.scaffoldKey.currentState.showSnackBar(snackBar);
//   }
// }

// // import 'package:RestaurantSaas/screens/mains/home.dart';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../styles/styles.dart';
// // import '../other/orders.dart';
// // import '../other/favorites.dart';
// // import '../../services/common.dart';
// // import '../../screens/auth/login.dart';
// // import '../../screens/mains/cart.dart';
// // import '../other/about-us.dart';
// // import '../other/profile.dart';
// // import '../../services/profile-service.dart';

// // import 'package:flutter_localizations/flutter_localizations.dart';

// // import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
// // import 'package:RestaurantSaas/constant.dart' show languages;
// // import 'package:RestaurantSaas/localizations.dart'
// //     show MyLocalizations, MyLocalizationsDelegate;

// // class Menu extends StatefulWidget {
// //   final GlobalKey<ScaffoldState> scaffoldKey;
// //   final Map<String, Map<String, String>> localizedValues;
// //   String locale;
// //   Menu({Key key, this.scaffoldKey, this.locale, this.localizedValues})
// //       : super(key: key);

// //   @override
// //   _MenuState createState() => _MenuState();
// // }

// // class _MenuState extends State<Menu> {
// //   int cartCounter;
// //   int favCounter;
// //   String profilePic;
// //   String fullname;
// //   bool isLoggedIn = false;

// //   @override
// //   void initState() {
// //     _checkLoginStatus();
// //     _getCartLength();
// //     selectedLanguages();
// //     super.initState();
// //   }

// //   var selectedLanguage;

// //   selectedLanguages() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       selectedLanguage = prefs.getString('selectedLanguage');
// //     });
// //     print(
// //         'selectedLanguage drawer............$selectedLanguage ${widget.localizedValues}');
// //   }

// //   void _getCartLength() async {
// //     await Common.getCart().then((onValue) {
// //       if (onValue != null) {
// //         setState(() {
// //           cartCounter = onValue['productDetails'].length;
// //         });
// //       } else {
// //         setState(() {
// //           cartCounter = 0;
// //         });
// //       }
// //     });
// //   }

// //   void _getFavLength() {
// //     ProfileService.getFavouritList().then((onValue) {
// //       if (onValue != null) {
// //         setState(() {
// //           favCounter = onValue.length;
// //         });
// //       } else {
// //         setState(() {
// //           favCounter = 0;
// //         });
// //       }
// //     });
// //   }

// //   Future _checkLoginStatus() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     Common.getToken().then((token) {
// //       if (token != null) {
// //         setState(() {
// //           isLoggedIn = true;
// //         });
// //         ProfileService.getUserInfo().then((value) {
// //           print(value);
// //           if (value != null && mounted) {
// //             setState(() {
// //               profilePic = value['logo'];
// //               fullname = value['name'];
// //               print(profilePic);
// //               isLoggedIn = true;
// //             });
// //           }
// //         });
// //       } else {
// //         setState(() {
// //           isLoggedIn = false;
// //         });
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       locale: Locale(widget.locale),
// //       debugShowCheckedModeBanner: false,
// //       localizationsDelegates: [
// //         MyLocalizationsDelegate(widget.localizedValues),
// //         GlobalMaterialLocalizations.delegate,
// //         GlobalWidgetsLocalizations.delegate,
// //       ],
// //       supportedLocales: languages.map((language) => Locale(language, '')),
// //       home: Container(
// //         child: new Drawer(
// //           child: new Center(
// //             child: new Container(
// //               alignment: FractionalOffset.center,
// //               decoration: new BoxDecoration(
// //                 image: new DecorationImage(
// //                   image: AssetImage("lib/assets/bgImgs/confirmedbg.png"),
// //                   fit: BoxFit.fill,
// //                   //     height: 710.0,
// //                   colorFilter: new ColorFilter.mode(
// //                       Colors.black.withOpacity(0.65), BlendMode.lighten),
// //                 ),
// //               ),
// //               child: new ListView(
// //                 children: <Widget>[
// //                   fullname == null && profilePic == null
// //                       ? Container(
// //                           height: 100.0,
// //                         )
// //                       : Row(children: <Widget>[
// //                           Flexible(
// //                               flex: 3,
// //                               fit: FlexFit.tight,
// //                               child: Container(
// //                                 padding: EdgeInsets.only(
// //                                     left: 20.0, right: 20.0, top: 20.0),
// //                                 height: 80.0,
// //                                 child: profilePic != null
// //                                     ? new CircleAvatar(
// //                                         backgroundImage: new NetworkImage(
// //                                           "$profilePic",
// //                                         ),
// //                                       )
// //                                     : new CircleAvatar(
// //                                         backgroundImage: new AssetImage(
// //                                             'lib/assets/imgs/na.jpg')),
// //                               )),
// //                           Flexible(
// //                               flex: 6,
// //                               fit: FlexFit.tight,
// //                               child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: <Widget>[
// //                                     Padding(
// //                                       padding: EdgeInsets.only(
// //                                           top: 13.0, bottom: 3.0),
// //                                       child: new Text(
// //                                           "${fullname == null ? "" : fullname}",
// //                                           style: TextStyle(
// //                                               color: Colors.white,
// //                                               fontFamily: "bold")),
// //                                     ),
// //                                   ]))
// //                         ]),
// //                   new ListTile(
// //                     title: new Text(MyLocalizations.of(context).home,
// //                         style:
// //                             TextStyle(color: Colors.white, fontFamily: "bold")),
// //                     leading:
// //                         Image.asset("lib/assets/icon/spoon.png", width: 25.0),
// //                     trailing: new Icon(
// //                       Icons.keyboard_arrow_right,
// //                       color: Colors.white70,
// //                     ),
// //                     onTap: () {
// //                       Navigator.of(context).pop();
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (BuildContext context) => HomePage(
// //                             locale: widget.locale,
// //                             localizedValues: widget.localizedValues,
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   new ListTile(
// //                     title: new Text(
// //                         MyLocalizations.of(context).cart +
// //                             "   ${cartCounter == 0 || cartCounter == null ? "" : cartCounter.toString()}",
// //                         style:
// //                             TextStyle(color: Colors.white, fontFamily: "bold")),
// //                     leading:

// //                         Image.asset("lib/assets/icon/carte.png", width: 25.0),
// //                     trailing: new Icon(
// //                       Icons.keyboard_arrow_right,
// //                       color: Colors.white70,
// //                     ),
// //                     onTap: () {
// //                       Navigator.of(context).pop();
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (BuildContext context) => CartPage(),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   isLoggedIn
// //                       ? new ListTile(
// //                           title: new Text(MyLocalizations.of(context).myOrders,
// //                               style: TextStyle(
// //                                   color: Colors.white, fontFamily: "bold")),
// //                           leading: Image.asset(
// //                               'lib/assets/icon/orderHistory.png',
// //                               width: 25.0),
// //                           trailing: new Icon(
// //                             Icons.keyboard_arrow_right,
// //                             color: Colors.white70,
// //                           ),
// //                           onTap: () {
// //                             Navigator.of(context).pop();
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (BuildContext context) => OrdersPage(locale: widget.locale, localizedValues: widget.localizedValues,),
// //                               ),
// //                             );
// //                           },
// //                         )
// //                       : Container(),
// //                   isLoggedIn
// //                       ? new ListTile(
// //                           title: new Text(
// //                               MyLocalizations.of(context).favourites,
// //                               style: TextStyle(
// //                                   color: Colors.white, fontFamily: "bold")),
// //                           leading: Image.asset('lib/assets/icon/favorite.png',
// //                               width: 25.0),
// //                           trailing: new Icon(
// //                             Icons.keyboard_arrow_right,
// //                             color: Colors.white70,
// //                           ),
// //                           onTap: () {
// //                             Navigator.of(context).pop();
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (BuildContext context) => Favorites(locale: widget.locale, localizedValues: widget.localizedValues,),
// //                               ),
// //                             );
// //                           },
// //                         )
// //                       : Container(),
// //                   isLoggedIn
// //                       ? new ListTile(
// //                           title: new Text(MyLocalizations.of(context).profile,
// //                               style: TextStyle(
// //                                   color: Colors.white, fontFamily: "bold")),
// //                           leading: Image.asset('lib/assets/icon/settings.png',
// //                               width: 25.0),
// //                           trailing: new Icon(
// //                             Icons.keyboard_arrow_right,
// //                             color: Colors.white70,
// //                           ),
// //                           onTap: () {
// //                             Navigator.of(context).pop();
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (BuildContext context) => ProfileApp(
// //                                     locale: widget.locale,
// //                                     localizedValues: widget.localizedValues),
// //                               ),
// //                             );
// //                           },
// //                         )
// //                       : Container(),
// //                   new ListTile(
// //                     title: new Text(MyLocalizations.of(context).aboutUs,
// //                         style:
// //                             TextStyle(color: Colors.white, fontFamily: "bold")),
// //                     leading:
// //                         Image.asset('lib/assets/icon/about.png', width: 25.0),
// //                     trailing: new Icon(
// //                       Icons.keyboard_arrow_right,
// //                       color: Colors.white70,
// //                     ),
// //                     onTap: () {
// //                       Navigator.of(context).pop();
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (BuildContext context) => AboutUs(
// //                               locale: widget.locale,
// //                               localizedValues: widget.localizedValues),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   !isLoggedIn
// //                       ? new ListTile(
// //                           leading: Image.asset("lib/assets/icon/loginIcon.png",
// //                               width: 25.0),
// //                           title: new Text(MyLocalizations.of(context).login,
// //                               style: TextStyle(
// //                                   color: Colors.white, fontFamily: "bold")),
// //                           trailing: new Icon(
// //                             Icons.exit_to_app,
// //                             color: Colors.white70,
// //                           ),
// //                           onTap: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (BuildContext context) => LoginPage(
// //                                   isDrawe: true,
// //                                   locale: widget.locale,
// //                                   localizedValues: widget.localizedValues,
// //                                 ),
// //                               ),
// //                             );
// //                           })
// //                       : Container(),
// //                   isLoggedIn
// //                       ? new ListTile(
// //                           leading: Image.asset("lib/assets/icon/loginIcon.png",
// //                               width: 25.0),
// //                           title: new Text(MyLocalizations.of(context).logout,
// //                               style: TextStyle(
// //                                   color: Colors.white, fontFamily: "bold")),
// //                           trailing: new Icon(
// //                             Icons.exit_to_app,
// //                             color: Colors.white70,
// //                           ),
// //                           onTap: () {
// //                             Common.removeToken().then((onValue) {
// //                               setState(() {
// //                                 isLoggedIn = false;
// //                               });
// //                               Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                       builder: (BuildContext context) =>
// //                                           HomePage(
// //                                               locale: widget.locale,
// //                                               localizedValues:
// //                                                   widget.localizedValues)));
// //                               showSnackbar('Logout Successfully!');
// //                               // Navigator.pop(context);
// //                             });
// //                           })
// //                       : Container(
// //                           height: 50.0,
// //                         ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   //   return Container(
// //   //     child: Drawer(
// //   //       child: Center(
// //   //         child: ListView(
// //   //           children: <Widget>[
// //   //             Stack(
// //   //               fit: StackFit.passthrough,
// //   //               children: <Widget>[
// //   //                 _buildMenuBg(),
// //   //                 Column(
// //   //                   children: <Widget>[
// //   //                     Row(
// //   //                       children: <Widget>[
// //   //                         _buildMenuProfileLogo(profilePic),
// //   //                         Padding(
// //   //                           padding: EdgeInsets.only(left: 20.0),
// //   //                         ),
// //   //                         fullname != null
// //   //                             ? Text(fullname.toUpperCase(),
// //   //                                 style: hintStyleWhitePNR())
// //   //                             : Container(height: 0, width: 0),
// //   //                       ],
// //   //                     ),

// //   //                     Divider(color: Colors.white12),
// //   //                     _buildMenuTileList(
// //   //                         'lib/assets/icon/spoon.png', 'Home', 0),
// //   //                     Divider(color: Colors.white12),
// //   //                     _buildMenuTileList('lib/assets/icon/carte.png', 'Cart',
// //   //                         cartCounter != null ? cartCounter : 0,
// //   //                         route: CartPage()),
// //   //                     isLoggedIn
// //   //                         ? Divider(color: Colors.white12)
// //   //                         : Container(height: 0, width: 0),
// //   //                     isLoggedIn
// //   //                         ? _buildMenuTileList(
// //   //                             'lib/assets/icon/orderHistory.png',
// //   //                             'My Orders',
// //   //                             0,
// //   //                             route: OrdersPage())
// //   //                         : Container(height: 0, width: 0),
// //   //                     isLoggedIn
// //   //                         ? Divider(color: Colors.white12)
// //   //                         : Container(height: 0, width: 0),
// //   //                     isLoggedIn
// //   //                         ? _buildMenuTileList(
// //   //                             'lib/assets/icon/favorite.png', 'Favourites', 0,
// //   //                             route: Favorites())
// //   //                         : Container(height: 0, width: 0),
// //   //                     // Divider(color: Colors.white12),
// //   //                     // _buildMenuTileList('lib/assets/icon/chat.png', 'Chat', 0)
// //   //                     isLoggedIn
// //   //                         ? Divider(color: Colors.white12)
// //   //                         : Container(height: 0, width: 0),
// //   //                     isLoggedIn
// //   //                         ? _buildMenuTileList(
// //   //                             'lib/assets/icon/settings.png', 'Profile', 0,
// //   //                             route: Profile())
// //   //                         : Container(height: 0, width: 0),
// //   //                     Divider(color: Colors.white12),
// //   //                     _buildMenuTileList(
// //   //                         'lib/assets/icon/about.png', 'About Us', 0,
// //   //                         route: AboutUs()),
// //   //                     !isLoggedIn
// //   //                         ? Divider(color: Colors.white12)
// //   //                         : Container(height: 0, width: 0),
// //   //                     !isLoggedIn
// //   //                         ? _buildMenuTileList(
// //   //                             'lib/assets/icon/loginIcon.png', 'Login', 0,
// //   //                             route: LoginPage())
// //   //                         : Container(height: 0, width: 0),
// //   //                     isLoggedIn
// //   //                         ? Divider(color: Colors.white12)
// //   //                         : Container(height: 0, width: 0),
// //   //                     isLoggedIn
// //   //                         ? InkWell(
// //   //                             onTap: () {
// //   //                               setState(() {
// //   //                                 isLoggedIn = true;
// //   //                               });
// //   //                               Common.removeToken().then((onValue) {
// //   //                                 showSnackbar('Logout Successfully!');
// //   //                                 Navigator.pop(context);

// //   //                               });
// //   //                             },
// //   //                             child: _buildMenuTileList(
// //   //                                 'lib/assets/icon/loginIcon.png', 'Logout', 0,
// //   //                                 check: false),
// //   //                           )
// //   //                         : Container(height: 0, width: 0),
// //   //                     Divider(color: Colors.white12),
// //   //                   ],
// //   //                 ),
// //   //               ],
// //   //             ),
// //   //           ],
// //   //         ),
// //   //       ),
// //   //     ),
// //   //   );
// //   // }

// //   // Widget _buildMenuBg() {
// //   //   return Image(
// //   //     image: AssetImage("lib/assets/bgImgs/confirmedbg.png"),
// //   //     fit: BoxFit.fill,
// //   //     height: 710.0,
// //   //   );
// //   // }

// //   // Widget _buildMenuProfileLogo(String imgUrl) {
// //   //   return Padding(
// //   //     padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
// //   //     child: Container(
// //   //       height: 80.0,
// //   //       width: 80.0,
// //   //       decoration: new BoxDecoration(
// //   //         border: new Border.all(color: Colors.black, width: 2.0),
// //   //         borderRadius: BorderRadius.circular(80.0),
// //   //       ),
// //   //       child: imgUrl == null
// //   //           ? new CircleAvatar(
// //   //               backgroundImage: new AssetImage('lib/assets/logos/logo.png'))
// //   //           : new CircleAvatar(
// //   //               backgroundImage: new NetworkImage(imgUrl),
// //   //               radius: 80.0,
// //   //             ),
// //   //     ),
// //   //   );
// //   // }

// //   // Widget _buildMenuTileList(String icon, String name, int count,
// //   //     {Widget route, bool check}) {
// //   //   return GestureDetector(
// //   //     onTap: () {
// //   //       if (check == null) {
// //   //         if (route != null) {
// //   //           Navigator.pop(context);
// //   //           Navigator.push(context,
// //   //               MaterialPageRoute(builder: (BuildContext context) => route));
// //   //         } else {
// //   //           Navigator.pop(context);
// //   //         }
// //   //       }
// //   //     },
// //   //     child: Row(
// //   //       children: <Widget>[
// //   //         Expanded(
// //   //           child: ListTile(
// //   //             leading: Image.asset(icon, width: 25.0),
// //   //           ),
// //   //         ),
// //   //         Expanded(
// //   //           child: Text(
// //   //             name,
// //   //             style: hintStyleWhitePNR(),
// //   //           ),
// //   //         ),
// //   //         count > 0
// //   //             ? Expanded(
// //   //                 child: Container(
// //   //                   width: 26.0,
// //   //                   height: 26.0,
// //   //                   alignment: AlignmentDirectional.center,
// //   //                   decoration:
// //   //                       BoxDecoration(shape: BoxShape.circle, color: PRIMARY),
// //   //                   child: Text(
// //   //                     count.toString(),
// //   //                     textAlign: TextAlign.center,
// //   //                     style: hintStyleLightOSB(),
// //   //                   ),
// //   //                 ),
// //   //               )
// //   //             : Expanded(
// //   //                 child: Container(height: 0, width: 0),
// //   //               ),
// //   //         Expanded(
// //   //           child: ListTile(
// //   //             trailing: Icon(Icons.chevron_right, color: Colors.white),
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

// //   void showSnackbar(message) {
// //     final snackBar = SnackBar(
// //       content: Text(message),
// //       duration: Duration(milliseconds: 3000),
// //     );
// //     widget.scaffoldKey.currentState.showSnackBar(snackBar);
// //   }
// // }
