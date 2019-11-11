import 'package:RestaurantSaas/screens/other/CounterModel.dart';
import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';
import '../../styles/styles.dart';
import '../../widgets/location-card.dart';
import '../../services/main-service.dart';
import '../../widgets/no-data.dart';
import 'product-details.dart';
import 'cart.dart';
import 'home.dart';
import '../../services/sentry-services.dart';

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

  ProductListPage(
      {Key key,
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
      this.taxInfo})
      : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  bool isShopOpen = true;
  int cartCount;
  getProductList() async {
    // _checkLocationOpenClose();
    return await MainService.getProductsBylocationId(widget.locationId);
  }

  // void _checkLocationOpenClose() {
  //   List<String> weekday = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  //   // contactNumber = widget.locationInfo['workingHours'];
  //   if (widget.locationInfo['workingHours']!=null) {
  //   var workingHours = widget.locationInfo['workingHours'];
  //   String today = weekday[DateTime.now().weekday];
  //       int hour = DateTime.now().hour;
  //       int minute = new DateTime.now().minute;
  //       if (!workingHours['isAlwaysOpen']) {
  //         int indexOfDay;
  //         for(int i=0; i<workingHours['daySchedule'].toList().length;i++){
  //           print(workingHours['daySchedule'][i]['day']);
  //           if(workingHours['daySchedule'][i]['day']==today){
  //             indexOfDay = i;
  //           }
  //         }
  //         print(indexOfDay);
  //         if (indexOfDay != -1) {
  //           print(indexOfDay);
  //           List<dynamic> timeSchedule = workingHours['daySchedule'][indexOfDay]['timeSchedule'];
  //           if (timeSchedule != null) {
  //             print('object of if');
  //             print(timeSchedule);
  //             for (int i = 0; i < timeSchedule.length; i++) {
  //               List<String> shopOpenTime = timeSchedule[i]['openTime'].split(":");
  //               int shopOpenHour = int.parse(shopOpenTime[0]);
  //               print(shopOpenHour);
  //               List<String> shopCloseTime = timeSchedule[i]['closingTime'].split(":");
  //               int shopCloseHour = int.parse(shopCloseTime[0]);
  //               if (hour >= shopOpenHour && hour <= shopCloseHour) {
  //                 if (minute > 0 && hour <= shopCloseHour) {
  //                   isShopOpen = true;
  //                 } else {
  //                   isShopOpen = false;
  //                 }
  //                 break;
  //               } else {
  //                 isShopOpen = false;
  //             }
  //           }
  //         } else {
  //           isShopOpen = true;
  //         }
  //       } else {
  //         isShopOpen = true;
  //       }
  //     } else
  //       isShopOpen = true;
  //     }
  //     print(isShopOpen.toString());
  // }
  @override
  void initState() {
    print(widget.cuisine.length);
    print(widget.cuisine);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CounterModel().getCounter().then((res) {
      try {
        setState(() {
          cartCount = res;
        });
        print("responcencdc   $cartCount");
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
            message: 'Please check your internet connection!',
            icon: Icons.block);
      },
      renderSuccess: ({data}) {
        if (data['message'] != null) {
          return NoData(message: 'No products available yet!');
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
                        null,
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
                    builder: (BuildContext context) => CartPage(),
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
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CartPage(),
            ),
          );
        },
        child: Container(
          height: 50.0,
          color: PRIMARY,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "GO TO CART",
                style: subTitleWhiteBOldOSB(),
              ),
            ],
          ),
        ),
      ),
    );
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
      widget.aboutUs,
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
              'Location',
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
                      Text(
                        'Open',
                        style: hintStyleSmallGreenLightOSS(),
                      ),
                      Padding(padding: EdgeInsets.only(left: 10.0)),
                      Image.asset(
                        'lib/assets/icon/about.png',
                        width: 18.0,
                      ),
                      Padding(padding: EdgeInsets.only(left: 5.0)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Text(
              LocationCard.getCuisines(widget.cuisine),
              overflow: TextOverflow.ellipsis,
              style: hintStyleSmallWhiteLightOSS(),
            ),
          ])
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      margin: EdgeInsetsDirectional.only(top: 220.0),
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
              ? 'Free delivery above \$' +
                  widget.deliveryInfo['amountEligibility'].toString()
              : (widget.deliveryInfo != null &&
                      !widget.deliveryInfo['freeDelivery'])
                  ? 'Delivery charge: Only \$' +
                      widget.deliveryInfo['deliveryCharges'].toString()
                  : 'Free delivery available',
          style: hintStyleSmallWhiteLightOSL(),
        ),
        // trailing: Icon(
        //   Icons.chevron_right,
        //   color: Colors.white,
        // ),
      ),
    );
  }

  Widget _buildCategoryTitle(
      String categoryName, String imgUrl, List<dynamic> products) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Image(
          image: imgUrl != null
              ? NetworkImage(imgUrl)
              : AssetImage("lib/assets/headers/menu.png"),
          fit: BoxFit.fill,
          height: 42.0,
        ),
        Container(
          padding: EdgeInsetsDirectional.only(top: 8.0, start: 14.0),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "${categoryName[0].toUpperCase()}${categoryName.substring(1)}",
            style: titleWhiteBoldOSB(),
          ),
        ),
        ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProductDetailsPage(
                          product: products[index],
                          restaurantName: widget.restaurantName,
                          restaurantId: widget.restaurantId,
                          locationInfo: widget.locationInfo,
                          taxInfo: widget.taxInfo),
                    ),
                  );
                },
                child: _buildProductTile(
                    products[index]['imgUrl'],
                    products[index]['title'],
                    double.parse(
                        products[index]['variants'][0]['MRP'].toString()),
                    double.parse(
                        products[index]['variants'][0]['Discount'].toString()),
                    double.parse(
                        products[index]['variants'][0]['price'].toString()),
                    products[index]['description'],
                    index == 0 ? 42.0 : 0),
              );
            }),
      ],
    );
  }

  Widget _buildProductTile(String imgUrl, String productName, double mrp,
      double off, double price, String info, double topPadding) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.only(
              top: topPadding, left: 10.0, right: 10.0, bottom: 0.0),
          title: _buildProductTileTitle(
              imgUrl, productName, mrp, off, price, info),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 20.0,
                  child: Row(
                    children: <Widget>[
                      Text(
                        info,
                        style: hintStyleGreyLightOSR(),
                      ),
                    ],
                  )),
              off > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFFF0000)),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 15.0, top: 2.0, bottom: 2.0, right: 15.0),
                          child: Text(
                            off.toStringAsFixed(1) + '% off',
                            style: hintStyleRedOSS(),
                          ),
                        ),
                      ),
                    )
                  : Text(''),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '\$' + price.toStringAsFixed(2),
                style: subTitleDarkBoldOSS(),
              ),
              Container(
                padding: EdgeInsetsDirectional.only(top: 18.0),
                child: Image.asset(
                  'lib/assets/icon/addbtn.png',
                  width: 16.0,
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildProductTileTitle(String imgUrl, String productName, double mrp,
      double off, double price, String info) {
    return Row(
      children: <Widget>[
        Text(
          productName.length > 21
              ? "${productName[0].toUpperCase()}${productName.substring(1, 21) + '...'}"
              : "${productName[0].toUpperCase()}${productName.substring(1)}",
          style: subTitleDarkBoldOSS(),
        ),
        Padding(padding: EdgeInsets.all(5.0)),
        off > 0
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0), color: PRIMARY),
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    '\$ ' + mrp.toStringAsFixed(2),
                    style: hintStyleSmallWhiteLightOSSStrike(),
                  ),
                ),
              )
            : Text(''),
      ],
    );
  }
}
