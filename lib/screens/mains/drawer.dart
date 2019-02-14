import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../other/orders.dart';
import '../other/favorites.dart';
import '../../services/common.dart';
import '../../screens/auth/login.dart';
import '../../screens/mains/cart.dart';
import '../other/about-us.dart';
import '../other/profile.dart';
import '../../services/profile-service.dart';

class Menu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  Menu({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int cartCounter;
  String profilePic;
  String fullname;
  bool isLoggedIn = false;

  @override
  void initState() {
    _checkLoginStatus();
    _getCartLength();
    super.initState();
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

  void _checkLoginStatus() {
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
                              style: hintStyleWhitePNR())
                          : Container(height: 0, width: 0),
                      Divider(color: Colors.white12),
                      _buildMenuTileList(
                          'lib/assets/icon/spoon.png', 'Home', 0),
                      Divider(color: Colors.white12),
                      _buildMenuTileList('lib/assets/icon/carte.png', 'Cart',
                          cartCounter != null ? cartCounter : 0,
                          route: CartPage()),
                      isLoggedIn
                          ? Divider(color: Colors.white12)
                          : Container(height: 0, width: 0),
                      isLoggedIn
                          ? _buildMenuTileList(
                              'lib/assets/icon/orderHistory.png',
                              'My Orders',
                              0,
                              route: OrdersPage())
                          : Container(height: 0, width: 0),
                      isLoggedIn
                          ? Divider(color: Colors.white12)
                          : Container(height: 0, width: 0),
                      isLoggedIn
                          ? _buildMenuTileList(
                              'lib/assets/icon/favorite.png', 'Favourites', 0,
                              route: Favorites())
                          : Container(height: 0, width: 0),
                      // Divider(color: Colors.white12),
                      // _buildMenuTileList('lib/assets/icon/chat.png', 'Chat', 0)
                      isLoggedIn
                          ? Divider(color: Colors.white12)
                          : Container(height: 0, width: 0),
                      isLoggedIn
                          ? _buildMenuTileList(
                              'lib/assets/icon/settings.png', 'Profile', 0,
                              route: Profile())
                          : Container(height: 0, width: 0),
                      Divider(color: Colors.white12),
                      _buildMenuTileList(
                          'lib/assets/icon/about.png', 'About Us', 0,
                          route: AboutUs()),
                      !isLoggedIn
                          ? Divider(color: Colors.white12)
                          : Container(height: 0, width: 0),
                      !isLoggedIn
                          ? _buildMenuTileList(
                              'lib/assets/icon/loginIcon.png', 'Login', 0,
                              route: LoginPage())
                          : Container(height: 0, width: 0),
                      isLoggedIn
                          ? Divider(color: Colors.white12)
                          : Container(height: 0, width: 0),
                      isLoggedIn
                          ? InkWell(
                              onTap: () {
                                Common.removeToken().then((onValue) {
                                  setState(() {
                                    isLoggedIn = false;
                                  });
                                  showSnackbar('Logout Successfully!');
                                  Navigator.pop(context);
                                });
                              },
                              child: _buildMenuTileList(
                                  'lib/assets/icon/loginIcon.png', 'Logout', 0,
                                  check: false),
                            )
                          : Container(height: 0, width: 0),
                      Divider(color: Colors.white12),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBg() {
    return Image(
      image: AssetImage("lib/assets/bgImgs/confirmedbg.png"),
      fit: BoxFit.fill,
      height: 710.0,
    );
  }

  Widget _buildMenuProfileLogo(String imgUrl) {
    return Padding(
      padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
      child: imgUrl == null
          ? Image.asset(
              'lib/assets/logos/logo.png',
              width: 100.0,
            )
          : Image.network(
              imgUrl,
              width: 100.0,
              height: 100.0,
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
        }
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: Image.asset(icon, width: 25.0),
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: hintStyleWhitePNR(),
            ),
          ),
          count > 0
              ? Expanded(
                  child: Container(
                    width: 26.0,
                    height: 26.0,
                    alignment: AlignmentDirectional.center,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: PRIMARY),
                    child: Text(
                      count.toString(),
                      textAlign: TextAlign.center,
                      style: hintStyleLightOSB(),
                    ),
                  ),
                )
              : Expanded(
                  child: Container(height: 0, width: 0),
                ),
          Expanded(
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
      duration: Duration(milliseconds: 3000),
    );
    widget.scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
