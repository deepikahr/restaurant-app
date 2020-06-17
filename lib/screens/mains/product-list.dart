import 'package:RestaurantSaas/screens/other/product-tile.dart';
import 'package:RestaurantSaas/services/common.dart';
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
import '../../widgets/location-card.dart';
import '../../widgets/no-data.dart';
import 'cart.dart';

SentryError sentryError = new SentryError();

class ProductListPage extends StatefulWidget {
  final String restaurantName,
      locationName,
      aboutUs,
      imgUrl,
      address,
      locationId,
      restaurantId;
  final Map<String, dynamic> deliveryInfo, workingHours, locationInfo, taxInfo;
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
    this.deliveryInfo,
    this.workingHours,
    this.locationInfo,
    this.taxInfo,
    this.locale,
    this.localizedValues,
  }) : super(key: key);

  @override
  ProductListPageState createState() => ProductListPageState();
}

class ProductListPageState extends State<ProductListPage> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
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

  getProductList() async {
    return await MainService.getProductsBylocationId(widget.locationId);
  }

  @override
  void initState() {
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
          openAndCloseTime = verifyOpenAndCloseTime['message'];
          isopenAndCloseTimeLoading = false;
        });
      }
    }).catchError((onError) {});
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
    AsyncLoader asyncLoader = AsyncLoader(
      key: _asyncLoaderState,
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
                return Column(
                  children: <Widget>[
                    _buildCategoryTitle(
                        data['categorydata'][index]['categoryTitle'],
                        data['categorydata'][index]['categoryImageUrl'],
                        data['categorydata'][index]['product']),
                  ],
                );
              },
            ),
          );
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: PRIMARY,
        elevation: 0.0,
        title: Text(
          widget.restaurantName,
          style: titleBoldWhiteOSS(),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
              onTap: () {
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  _buildBgImg(),
                  _buildDescription(),
                  _buildInfoBar(),
                ],
              ),
              asyncLoader
            ],
          ),
        ),
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

  Widget _buildBgImg() {
    return Image(
      image: widget.imgUrl != null
          ? NetworkImage(widget.imgUrl)
          : AssetImage("lib/assets/bgImgs/coverbg.png"),
      height: 220.0,
      width: screenWidth(context),
      color: Colors.black45,
      colorBlendMode: BlendMode.hardLight,
      fit: BoxFit.fill,
    );
  }

  Widget _buildDescription() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildLocatioNameView(),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        _buildAboutUsView(),
        _buildAddressBox(),
        _buildInfoBottom(),
      ],
    );
  }

  Widget _buildLocatioNameView() {
    return Padding(
      padding: EdgeInsets.only(top: 60.0),
      child: Text(
        widget.locationName,
        style: titleLightWhiteOSS(),
      ),
    );
  }

  Widget _buildAboutUsView() {
    return Text(
      widget.aboutUs.length > 100
          ? widget.aboutUs.substring(0, 100)
          : widget.aboutUs,
      style: hintStyleSmallTextWhiteOSL(),
    );
  }

  Widget _buildAddressBox() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0, right: 2.0, left: 10.0),
      child: Container(
        height: 37.0,
        width: 260.0,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black.withOpacity(0.25),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
            color: Colors.black.withOpacity(0.25)),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 2.0),
            child: Text(
              widget.address,
              style: hintStyleSmallWhiteOSR(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBottom() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              MyLocalizations.of(context).location,
              style: hintStyleSmallWhiteLightOSR(),
              textAlign: TextAlign.left,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  flex: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.locationName,
                        style: hintStyleSmallWhiteOSR(),
                      ),
                    ],
                  )),
              Flexible(
                flex: 12,
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: 5.0)),
                      !isopenAndCloseTimeLoading
                          ? Text(
                        openAndCloseTime,
                        style: hintStyleSmallGreenLightOSS(),
                      )
                          : Text(
                        "",
                        style: hintStyleSmallGreenLightOSS(),
                      ),
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      InkWell(
                        onTap: () {
                          _showTimingAlert();
                        },
                        child: Image.asset(
                          'lib/assets/icon/about.png',
                          width: 18.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Text(
              LocationCard.getCuisines(widget.cuisine, context),
              overflow: TextOverflow.ellipsis,
              style: hintStyleSmallWhiteLightOSS(),
            ),
          ])
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    if (widget.deliveryInfo != null &&
        widget.deliveryInfo['isDeliveryAvailable'] != null &&
        widget.deliveryInfo['isDeliveryAvailable'] == false) {
      return Container(
        margin: EdgeInsetsDirectional.only(top: 200.0),
        color: PRIMARY,
        child: ListTile(
          leading: Image(
            image: AssetImage('lib/assets/icon/qmark.png'),
            height: 18.0,
          ),
          title: Text(
            MyLocalizations.of(context).nodeliveryavailable,
            style: hintStyleSmallWhiteLightOSL(),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsetsDirectional.only(top: 200.0),
        color: PRIMARY,
        child: ListTile(
          leading: Image(
            image: AssetImage('lib/assets/icon/qmark.png'),
            height: 18.0,
          ),
          title: Text(
            (widget.deliveryInfo != null &&
                widget.deliveryInfo['freeDelivery'] &&
                widget.deliveryInfo['amountEligibility'] != null)
                ? MyLocalizations.of(context).freedeliveryabove +
                ' $currency' +
                widget.deliveryInfo['amountEligibility'].toString()
                : (widget.deliveryInfo != null &&
                !widget.deliveryInfo['freeDelivery'])
                ? MyLocalizations.of(context).deliveryCharges +
                ': Only $currency' +
                widget.deliveryInfo['deliveryCharges'].toString()
                : MyLocalizations.of(context).freedeliveryavailable,
            style: hintStyleSmallWhiteLightOSL(),
          ),
        ),
      );
    }
  }

  Widget _buildCategoryTitle(
      String categoryName, String imgUrl, List<dynamic> products) {
    return Column(
      children: [
        ExpansionTile(
          trailing: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                decoration:
                BoxDecoration(border: Border.all(color: primaryLight)),
                height: 70.0,
                width: 70.0,
                child: imgUrl != null
                    ? Image.network(
                  imgUrl,
                  fit: BoxFit.fill,
                )
                    : Icon(
                  Icons.collections_bookmark,
                  color: Colors.black87,
                )),
          ),
          children: [
            ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  return BuildProductTile(
                    locationInfo: widget.locationInfo,
                    taxInfo: widget.taxInfo,
                    restaurantId: widget.restaurantId,
                    restaurantName: widget.restaurantName,
                    address: widget.address,
                    localizedValues: widget.localizedValues,
                    locale: widget.locale,
                    imgUrl: products[index]['imgUrl'],
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
                  );
                }),
          ],
          title: categoryName.length > 25
              ? Text(
            categoryName.substring(0, 25) + " ...",
            style: subTitleDarkBoldOSS(),
          )
              : Text(
            categoryName,
            style: subTitleDarkBoldOSS(),
          ),
        ),
      ],
    );
  }

  _showTimingAlert() {
    if (widget.locationInfo['workingHours'] != null) {
      List timingArray = List();

      if (widget.workingHours['isAlwaysOpen'] == false &&
          widget.workingHours['daySchedule'].length > 0) {
        timingArray = widget.workingHours['daySchedule'];
        showDialogBox(timingArray);
      } else if (widget.workingHours['isAlwaysOpen'] == true) {
        showMessageOpenAlert();
      } else {
        showMessageCloseAlert();
      }
    } else if (widget.locationInfo['workingHours'] == null) {
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
      // : timeTextList.add(Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: <Widget>[
      //       Padding(
      //         padding: EdgeInsets.only(bottom: 5.0),
      //         child: Text(
      //           timing['day'],
      //           style: TextStyle(
      //               fontSize: 18.0,
      //               decoration: TextDecoration.underline,
      //               decorationColor: Colors.black,
      //               fontWeight: FontWeight.w600),
      //         ),
      //       ),
      //       Column(children: timeScheduleList),
      //     ],
      //   ));
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
}
