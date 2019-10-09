import 'package:RestaurantSass/screens/mains/cart.dart';
import 'package:RestaurantSass/screens/other/CounterModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../styles/styles.dart';
import 'home.dart';
import '../../services/main-service.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import 'location-list-sheet.dart';
import '../../services/common.dart';

class RestaurantListPage extends StatefulWidget {
  final String title;

  RestaurantListPage({Key key, this.title}) : super(key: key);

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  Map<String, dynamic> restaurantInfo;
  VoidCallback _showBottomSheetCallback;
  int cartCount;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  getRestaurantsList() async {
    if (widget.title == 'Top Rated') {
      return await MainService.getTopRatedRestaurants();
    } else if (widget.title == 'Newly Arrived') {
      return await MainService.getNewlyArrivedRestaurants();
    } else {
      List<dynamic> restaurants;
      await Common.getPositionInfo().then((position) async {
        await MainService.getNearByRestaurants(
                position['lat'], position['long'])
            .then((onValue) {
          restaurants = onValue;
        });
      });
      return restaurants;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CounterModel().getCounter().then((res) {
      setState(() {
        cartCount = res;
      });
      print("responcencdc   $cartCount");
    });
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(
          widget.title + ' Restaurants',
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[
          // HomePageState.buildCartIcon(context)
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CartPage(),
                  ),
                );
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: (cartCount == null || cartCount == 0)
                        ? Text(
                            '',
                            style: TextStyle(fontSize: 14.0),
                          )
                        : Text(
                            '${cartCount.toString()}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.shopping_cart)),
                ],
              )),
          Padding(padding: EdgeInsets.only(left: 7.0)),
          // buildLocationIcon(),
          // Padding(padding: EdgeInsets.only(left: 7.0)),
        ],
      ),
      body: _buildGetRestaurantLoader(),
    );
  }

  Widget _buildGetRestaurantLoader() {
    return AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getRestaurantsList(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) => NoData(
            message: 'Please check your internet connection!',
            icon: Icons.block),
        renderSuccess: ({data}) {
          return GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: data.length,
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    child: HomePageState.buildRestaurantCard(data[index]),
                    onTap: () {
                      setState(() {
                        restaurantInfo = data[index];
                      });
                      _showBottomSheet();
                    });
              });
        });
  }

  void _showBottomSheet() {
    setState(() {
      _showBottomSheetCallback = null;
    });
    scaffoldKey.currentState
        .showBottomSheet<void>((BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: PRIMARY, width: 6.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: LocationListSheet(restaurantInfo: restaurantInfo),
            ),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _showBottomSheetCallback = _showBottomSheet;
            });
          }
        });
  }
}
