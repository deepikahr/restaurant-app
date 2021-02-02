import 'package:RestaurantSaas/screens/products/product-tile.dart';
import 'package:RestaurantSaas/services/common.dart';
import 'package:RestaurantSaas/services/profile-service.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../services/counter-service.dart';
import '../../services/localizations.dart';
import '../../services/main-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';
import '../mains/checkout/cart.dart';

SentryError sentryError = new SentryError();

class ProductListPage extends StatefulWidget {
  final int deliveryCharge, minimumOrderAmount;
  final String restaurantName,
      shippingType,
      locationName,
      aboutUs,
      imgUrl,
      address,
      locationId,
      restaurantId;
  final Map<String, dynamic> workingHours, locationInfo, taxInfo;
  final List<dynamic> cuisine;
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  ProductListPage({
    Key key,
    this.restaurantName,
    this.locationName,
    this.aboutUs,
    this.imgUrl,
    this.address,
    this.locationId,
    this.restaurantId,
    this.cuisine,
    this.workingHours,
    this.locationInfo,
    this.taxInfo,
    this.locale,
    this.localizedValues,
    this.deliveryCharge,
    this.minimumOrderAmount,
    this.shippingType,
  }) : super(key: key);

  @override
  ProductListPageState createState() => ProductListPageState();
}

class ProductListPageState extends State<ProductListPage> {
  bool isNewUser = true;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState2 =
      GlobalKey<AsyncLoaderState>();
  bool isopenAndCloseTimeLoading = false;
  int productQuantity = 1;
  int cartCount;
  String openAndCloseTime;
  bool isProductAdded = false;
  double price = 0;

  Map<String, dynamic> cartProduct;

  List<dynamic> tempProducts = [];

  int quantity = 1;

  var shippingType;

  var deliveryCharge;

  var minimumOrderAmount;

  Map<String, dynamic> workingHours;

  getProductList() async {
    return await MainService.getProductsBylocationId(widget.locationId);
  }

  @override
  void initState() {
    getWorkingHours();
    ProfileService.getUserInfo().then((value) {
      if (mounted) {
        setState(() {
          isNewUser = value['newUser'];
        });
      }
    });
    getRestaurantOpenAndCloseTime();
    super.initState();
    getGlobalSettingsData();
  }

  String currency = '';

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

  getRestaurantOpenAndCloseTime() async {
    if (mounted) {
      setState(() {
        isopenAndCloseTimeLoading = true;
      });
    }
    return await MainService.getRestaurantOpenAndCloseTime(
            widget.locationId,
            DateFormat('HH:mm').format(DateTime.now()),
            DateFormat('EEEE').format(DateTime.now()))
        .then((verifyOpenAndCloseTime) {
      if (mounted) {
        setState(() {
          if (verifyOpenAndCloseTime['res_code'] == 200) {
            openAndCloseTime = MyLocalizations.of(context).open;
          } else if (verifyOpenAndCloseTime['res_code'] == 400) {
            openAndCloseTime = MyLocalizations.of(context).closed;
          } else {
            openAndCloseTime = verifyOpenAndCloseTime['message'];
          }
          isopenAndCloseTimeLoading = false;
        });
      }
    }).catchError((onError) {});
  }

  Widget getCategoryList() {
    return AsyncLoader(
      key: _asyncLoaderState2,
      initState: () async => await getProductList(),
      renderLoad: () => Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      renderError: ([error]) {
        sentryError.reportError(error, null);
        return NoData(
            message: MyLocalizations.of(context).connectionError,
            icon: Icons.block);
      },
      renderSuccess: ({data}) {
        if (data['restaurant'] != null &&
            data['restaurant']['restaurantID'] != null) {
          Future.delayed(Duration(seconds: 0), () async {
            setState(() {
              isNewUser = isNewUser &&
                  data['restaurant']['restaurantID']['firstDeliveryFree'];
              shippingType = data['restaurant']['restaurantID']['shippingType'];
              deliveryCharge =
                  data['restaurant']['restaurantID']['deliveryCharge'];
              minimumOrderAmount =
                  data['restaurant']['restaurantID']['minimumOrderAmount'];
            });
          });
        }

        if (data['message'] != null) {
          return NoData(message: MyLocalizations.of(context).noProducts);
        } else {
          return Container(
            padding: EdgeInsetsDirectional.only(bottom: 16.0),
            child: ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: data['categorydata'] != null
                  ? data['categorydata'].length
                  : 0,
              itemBuilder: (BuildContext context, int index) {
                // print('pro ${data['categorydata'][index]}');
                return categoryBlock(
                    data['restaurant']['restaurantID']['firstDeliveryFree'],
                    data['categorydata'][index]['categoryTitle'],
                    data['categorydata'][index]['categoryImageUrl'],
                    data['categorydata'][index]['product']);
              },
            ),
          );
        }
      },
    );
  }

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
      appBar: appBarWithCart(
        context,
        cartCount,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CartPage(
                localizedValues: widget.localizedValues,
                locale: widget.locale,
                taxInfo: widget.taxInfo,
                locationInfo: widget.locationInfo,
              ),
            ),
          );
        },
      ),
      body: ListView(
        children: <Widget>[
          buildStore(),
          getCategoryList(),
        ],
      ),
    );
  }

  Widget buildStore() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 16),
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.imgUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        widget.imgUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'lib/assets/images/pizza.png',
                      width: 60,
                      height: 60,
                    ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        widget.restaurantName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textMuliSemiboldsm(),
                      ),
                      Container(
                        width: 30,
                        height: 15,
                        padding: EdgeInsets.only(left: 1, right: 1),
                        margin: EdgeInsets.only(left: 5),
                        color: Color(0xFF39B24A),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10,
                            ),
                            Text(
                              '4.5',
                              style: textMuliSemiboldwhitexs(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.locationName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: textMuliRegularxs(),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(color: secondary, width: 1))),
                        child: Text(
                          isNewUser
                              ? MyLocalizations.of(context)
                                  .freeDeliveryAvailable
                              : shippingType != null
                                  ? (shippingType.compareTo('free') == 0)
                                      ? MyLocalizations.of(context)
                                          .freeDeliveryAvailable
                                      : (shippingType.compareTo('flexible') ==
                                              0)
                                          ? "${MyLocalizations.of(context).freeDeliveryAbove}  \$${minimumOrderAmount.toString()}"
                                          : (shippingType.compareTo('fixed') ==
                                                  0)
                                              ? "${MyLocalizations.of(context).fixedDelivery} \$ ${deliveryCharge.toString()}"
                                              : ''
                                  : '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: textMuliRegularxs(),
                        ),
                      ),
                      SizedBox(width: 4),
                      !isopenAndCloseTimeLoading
                          ? Text(
                              'Now $openAndCloseTime ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: textMuliRegularxs(),
                            )
                          : Text(''),
                      InkWell(
                        onTap: () {
                          _showTimingAlert();
                        },
                        child: Icon(Icons.info_outlined),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
          // Image.asset(
          //   'lib/assets/icons/free.png',
          //   width: 44,
          //   height: 31,
          // ),
        ],
      ),
    );
  }

  Widget categoryBlock(bool isProductFirstDeliverFree, String categoryName,
      String imgUrl, List<dynamic> products) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              imgUrl != null
                  ? ClipRRect(
                      child: Image.network(
                        widget.imgUrl,
                        height: 45,
                        fit: BoxFit.cover,
                        width: 45,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : Image.asset(
                      'lib/assets/images/dominos.png',
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
              SizedBox(
                width: 12,
              ),
              Container(
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  categoryName,
                  style: textMuliBold(),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
                childAspectRatio: MediaQuery.of(context).size.width / 535,
              ),
              itemBuilder: (BuildContext context, int index) =>
                  BuildProductTile(
                locationId: widget.locationId,
                isProductFirstDeliverFree: isProductFirstDeliverFree,
                shippingType: shippingType,
                deliveryCharge: deliveryCharge,
                minimumOrderAmount: minimumOrderAmount,
                locationInfo: widget.locationInfo,
                taxInfo: widget.taxInfo,
                restaurantId: widget.restaurantId,
                restaurantName: widget.restaurantName,
                address: widget.address,
                localizedValues: widget.localizedValues,
                locale: widget.locale,
                imgUrl: products[index]['imageUrl'],
                mrp: double.parse(
                    products[index]['variants'][0]['MRP'].toString()),
                price: double.parse(
                    products[index]['variants'][0]['price'].toString()),
                product: products[index],
                currency: currency,
                topPadding: index == 0 ? 42.0 : 0,
                off: double.parse(
                    products[index]['variants'][0]['Discount'].toString()),
                productName: products[index]['title'],
                info: products[index]['description'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addProduct() async {
    await Common.getProducts().then((productsList) {
      if (productsList != null) {
        tempProducts = productsList;
        tempProducts.add(cartProduct);
        for (int i = 0; i < tempProducts.length; i++) {}
        Common.addProduct(tempProducts).then((value) {
          Toast.show(
              MyLocalizations.of(context).producthasbeenaddedtocart, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      } else {
        tempProducts.add(cartProduct);
        Common.addProduct(tempProducts).then((value) {
          Toast.show(
              MyLocalizations.of(context).producthasbeenaddedtocart, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
      }
      try {} catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  _showTimingAlert() {
    if (workingHours != null) {
      List timingArray = List();
      if (workingHours['isAlwaysOpen'] == false &&
          workingHours['daySchedule'].length > 0) {
        timingArray = workingHours['daySchedule'];
        showDialogBox(timingArray);
      } else if (workingHours['isAlwaysOpen'] == true) {
        showMessageOpenAlert();
      } else {
        showMessageCloseAlert();
      }
    } else if (workingHours == null) {
      showMessageCloseAlert();
    } else {
      showMessageCloseAlert();
    }
  }

  showDialogBox(timingArray) {
    List<Map> weekday = [
      {"day": 'Monday', "timeSchedule": null},
      {"day": 'Tuesday', "timeSchedule": null},
      {"day": 'Wednesday', "timeSchedule": null},
      {"day": 'Thursday', "timeSchedule": null},
      {"day": 'Friday', "timeSchedule": null},
      {"day": 'Saturday', "timeSchedule": null},
      {"day": 'Sunday', "timeSchedule": null},
    ];

    for (int i = 0; i < weekday.length; i++) {
      for (int j = 0; j < timingArray.length; j++) {
        if (timingArray[j]['day'] == weekday[i]['day']) {
          if (timingArray[j]['isClosed'] != null &&
              timingArray[j]['isClosed'] != true) {
            weekday[i]['timeSchedule'] = timingArray[j]['timeSchedule'];
          }
        }
      }
    }
    timingArray = weekday;
    List<Widget> timeTextList = [];
    timingArray.forEach((timing) {
      List<Widget> timeScheduleList = [];

      timing['timeSchedule'] != null
          ? timing['timeSchedule'].forEach((schedule) {
              timeScheduleList.add(Padding(
                  padding: EdgeInsets.only(
                      // left: 20.0,
                      ),
                  child: Text(
                      '${schedule['openTimeIn12Hr']} ${schedule['openTimeMeridian']} - ${schedule['closeTimeIn12Hr']} ${schedule['closeTimeMeridian']}')));
            })
          : timeScheduleList.add(Padding(
              padding: EdgeInsets.only(
                  // left: 20.0,
                  ),
              child: Text(MyLocalizations.of(context).storeisClosed.trim())));

      timeTextList.add(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Text(
              timing['day'],
              style: TextStyle(
                  fontSize: 18.0,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: timeScheduleList),
        ],
      ));
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).openingTime),
          content: SingleChildScrollView(
              child: Column(
            children: timeTextList,
          )),
          actions: <Widget>[
            FlatButton(
              child: Text(MyLocalizations.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showMessageOpenAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).openingTime),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("24 X 7 " + MyLocalizations.of(context).open)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MyLocalizations.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showMessageCloseAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).sorry + '....!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(MyLocalizations.of(context).storeisClosed)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(MyLocalizations.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getWorkingHours() async {
    await MainService.getWorkingHours(widget.locationId).then((value) {
      if (value['res_code'] == 200) {
        if (mounted) {
          setState(() {
            workingHours = value['data']['workingHours'];
          });
        }
      }
    }).catchError((error) {});
  }
}
