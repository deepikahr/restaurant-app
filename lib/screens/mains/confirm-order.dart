import 'package:RestaurantSaas/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../styles/styles.dart';
import 'add-address.dart';
import 'payment-method.dart';
import 'package:async_loader/async_loader.dart';
import '../../widgets/no-data.dart';
import '../../services/profile-service.dart';
import 'dart:core';
import '../../services/main-service.dart';
import 'package:intl/intl.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import '../../services/sentry-services.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;
import 'package:shared_preferences/shared_preferences.dart';

SentryError sentryError = new SentryError();

class ConfrimOrderPage extends StatefulWidget {
  final Map<String, dynamic> cart, deliveryInfo, tableInfo;
  final Map<String, Map<String, String>> localizedValues;
  var locale;

  ConfrimOrderPage(
      {Key key,
      this.cart,
      this.tableInfo,
      this.deliveryInfo,
      this.localizedValues,
      this.locale})
      : super(key: key);

  @override
  _ConfrimOrderPageState createState() => _ConfrimOrderPageState();
}

class _ConfrimOrderPageState extends State<ConfrimOrderPage> {
  int selectedAddressIndex = 0;
  double remainingLoyaltyPoint = 0.0;
  double usedLoyaltyPoint = 0.0;
  bool isLoyaltyApplied = false;
  bool isDeliveryAvailable = true;
  double grandTotal = 0.0;
  double tempGrandTotal = 0.0;
  bool isFirstTime = true;
  double deliveryCharge = 0.0;
  bool isShopOpen = true;
  bool isAlwaysOpenOrClose = false;
  bool isAlwaysOpenOrCloseLoading = false;
  bool showSlot = false;
  bool showSlotTimimg = false;
  Map<String, dynamic> userInfo;
  String openAndCloseTime;
  List<dynamic> paymentMethodList;
  var selectedSlot, selectedLocale;
  DateTime pickupDate, pickupTime;
  // List<String> todayWorkingHoursSlotList;
  List<String> todayWorkingHoursSlotList;
  // Map<String, dynamic> todayWorkingHoursList;
  List<dynamic> todayWorkingHoursList;
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderStateAddress =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> languages = ['English', 'French', 'Chinese'];
  // final formats = {
  //   InputType.both: DateFormat("hh:mma dd/MM/yyyy"),
  //   InputType.date: DateFormat('yyyy-MM-dd'),
  //   InputType.time: DateFormat("HH:mma"),
  // };
  // InputType inputType = InputType.both;

  Future<Map<String, dynamic>> _getUserInfo() async {
    await ProfileService.getUserInfo().then((onValue) {
      try {
        userInfo = onValue;
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    await MainService.getLoyaltyInfoByRestaurantId(widget.cart['restaurantID'])
        .then((onValue) {
      try {
        userInfo['loyaltyInfo'] = onValue;
        remainingLoyaltyPoint =
            double.parse(userInfo['totalLoyaltyPoints'].toString());
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    await MainService.getRestaurantOpenAndCloseTime(
            widget.cart['location'],
            DateFormat('HH:mm').format(DateTime.now()),
            DateFormat('EEEE').format(DateTime.now()))
        .then((verifyOpenAndCloseTime) {
      print(verifyOpenAndCloseTime);
      try {
        openAndCloseTime = verifyOpenAndCloseTime['message'];
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return userInfo;
  }

  Future<List<dynamic>> _getAddressList() async {
    return await ProfileService.getAddressList();
  }

  void _calculateFinalAmount() {
    if ((widget.deliveryInfo != null) &&
        (widget.deliveryInfo['isDeliveryAvailable'] != null) &&
        (widget.deliveryInfo['isDeliveryAvailable'] == false)) {
      setState(() {
        isDeliveryAvailable = false;
        widget.cart['orderType'] = 'Pickup';
      });
    } else {
      setState(() {
        isDeliveryAvailable = true;
      });
    }

    if (isFirstTime) {
      setState(() {
        tempGrandTotal = widget.cart['grandTotal'];
        grandTotal = tempGrandTotal;
        deliveryCharge = double.parse(widget.cart['deliveryCharge'].toString());
        isFirstTime = false;
      });
    }
    if (widget.cart['orderType'] == 'Delivery') {
      setState(() {
        widget.cart['deliveryCharge'] = deliveryCharge;
        widget.cart['grandTotal'] = grandTotal;
        widget.cart['payableAmount'] = grandTotal;
      });
    } else if (widget.cart['orderType'] == 'Pickup' ||
        widget.cart['orderType'] == 'Dine In') {
      setState(() {
        if (grandTotal > 0) {
          widget.cart['grandTotal'] = grandTotal - deliveryCharge;
        }
        widget.cart['deliveryCharge'] = 0;
        widget.cart['payableAmount'] = widget.cart['grandTotal'];
      });
    }
  }

  void _calculateLoyaltyInfo() {
    grandTotal = tempGrandTotal;
    double points = 0.0;
    if (isLoyaltyApplied) {
      if (userInfo['totalLoyaltyPoints'] >= grandTotal) {
        points = userInfo['totalLoyaltyPoints'] - grandTotal;
        grandTotal = 0.0;
      } else {
        grandTotal = grandTotal - userInfo['totalLoyaltyPoints'];
        points = 0.0;
      }
      setState(() {
        usedLoyaltyPoint =
            double.parse(userInfo['totalLoyaltyPoints'].toString()) - points;
        remainingLoyaltyPoint = points;
        grandTotal = grandTotal;
      });
    } else {
      setState(() {
        usedLoyaltyPoint = 0.0;
        remainingLoyaltyPoint =
            double.parse(userInfo['totalLoyaltyPoints'].toString());
        grandTotal = grandTotal;
      });
    }
    _calculateFinalAmount();
  }

  getSlotTime(dt, todayDay, time) async {
    print("m k ");
    await MainService.getTodayAndOtherDaysWorkingTimimgs(
            widget.cart['location'], dt, time, todayDay)
        .then((onValue) {
      setState(() {
        isAlwaysOpenOrCloseLoading = true;
      });
      print(onValue);
      if (mounted) {
        if (onValue['isAlwaysOpen'] == true) {
          setState(() {
            isAlwaysOpenOrClose = true;
            todayWorkingHoursList = onValue['newDaySlot'];
            showSlotTimimg = !showSlotTimimg;
            print(todayWorkingHoursList);
          });
          setState(() {
            isAlwaysOpenOrCloseLoading = false;
          });
        } else {
          setState(() {
            todayWorkingHoursList = onValue['newDaySlot'];
            showSlotTimimg = !showSlotTimimg;
            print(todayWorkingHoursList);
          });
          setState(() {
            isAlwaysOpenOrCloseLoading = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
//    selectedLanguages();
  getGlobalSettingsData();
  }

  String currency;

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
    print('currency............. $currency');
  }

//  var selectedLanguage;
//
//  selectedLanguages() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    setState(() {
//      selectedLanguage = prefs.getString('selectedLanguage');
//    });
//  }

  @override
  Widget build(BuildContext context) {
    _calculateFinalAmount();
    AsyncLoader _asyncLoader = AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await _getUserInfo(),
        renderLoad: () => Center(child: CircularProgressIndicator()),
        renderError: ([error]) {
          sentryError.reportError(error, null);
          return NoData(
              message: MyLocalizations.of(context).connectionError,
              icon: Icons.block);
        },
        renderSuccess: ({data}) {
          return _buildConfirmOrderView(data);
        });

    return  Scaffold(
          backgroundColor: whiteTextb,
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: PRIMARY,
            elevation: 0.0,
            title: new Text(
              MyLocalizations.of(context).reviewOrder,
              style: titleBoldWhiteOSS(),
            ),
            centerTitle: true,
          ),
          body: _asyncLoader,
          bottomNavigationBar: _buildBottomBar(),
        );
  }

  Widget _buildConfirmOrderView(Map<String, dynamic> userInfo) {
    bool isPickup = false;
    bool isDineIn = false;
    if (widget.cart['orderType'] == 'Pickup') {
      isPickup = true;
    }
    if (widget.cart['orderType'] == 'Dine In') {
      isDineIn = true;
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        alignment: AlignmentDirectional.topStart,
        color: greyc,
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            _buildHeader(),
            new Column(
              children: <Widget>[
                // _buildBulletTitle(
                //     1, MyLocalizations.of(context).contactInformation),
                // _buildContactBlock(userInfo['name'],
                //     userInfo['contactNumber'].toString(), userInfo),
                // _buildBulletTitle(2, MyLocalizations.of(context).selectAddress),
                // _buildOrderTypeBlock(),
                // _buildAddressList(),
                // _buildBulletTitle(3, MyLocalizations.of(context).orderDetails),
                // _buildProductListBlock(userInfo),
                _buildBulletTitle(
                    1, MyLocalizations.of(context).contactInformation),
                _buildContactBlock(userInfo['name'],
                    userInfo['contactNumber'].toString(), userInfo),
                _buildBulletTitle(
                    2, MyLocalizations.of(context).selectOrderType),
                widget.tableInfo == null
                    ? _buildOrderTypeBlock()
                    : _buildDineInTypeBlock(),
                isDineIn
                    ? Container()
                    : _buildBulletTitle(
                        3,
                        isPickup
                            ? MyLocalizations.of(context).restaurantAddress
                            : MyLocalizations.of(context).selectAddress),
                isDineIn ? Container() : _buildAddressList(isPickup),
                _buildBulletTitle(
                    isDineIn ? 3 : 4, MyLocalizations.of(context).orderDetails),
                _buildProductListBlock(userInfo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.black38,
      padding: EdgeInsets.all(10.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                MyLocalizations.of(context).date,
                style: hintStyleSmallWhiteLightOSL(),
              ),
              new Text(
                DateTime.now().toString().substring(0, 10),
                style: hintStyleSmallWhiteLightOSL(),
              ),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                MyLocalizations.of(context).totalOrder,
                style: hintStyleSmallWhiteLightOSL(),
              ),
              new Text(
                '$currency' + widget.cart['grandTotal'].toStringAsFixed(2),
                style: hintStyleSmallWhiteLightOSL(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletTitle(int number, String title) {
    return Container(
      color: greyc,
      child: new Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: new Row(
          children: <Widget>[
            new Container(
              width: 22.0,
              height: 22.0,
              alignment: AlignmentDirectional.center,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: primaryLight,
              ),
              child: new Text(
                number.toString(),
                textAlign: TextAlign.center,
                style: hintStyleLightOSB(),
              ),
            ),
            new Padding(padding: EdgeInsets.all(5.0)),
            new Text(title, style: hintStyleSmallDarkOSB())
          ],
        ),
      ),
    );
  }

  Widget _buildDineInTypeBlock() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 0.0),
              child: Container(
                padding:
                    EdgeInsets.only(top: 10, left: 10, bottom: 0, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.0), color: PRIMARY),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: screenWidth(context) * 0.7,
                          height: 34,
                          color: PRIMARY,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    MyLocalizations.of(context).dineIn,
                                    textAlign: TextAlign.center,
                                    // style: hintStyleOSBType(),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15.0,
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeBlock() {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 0.0),
              child: Container(
                padding:
                    EdgeInsets.only(top: 10, left: 10, bottom: 0, right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9.0), color: PRIMARY),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              widget.cart['orderType'] = 'Pickup';
                            });
                          },
                          child: Container(
                            width: screenWidth(context) * 0.3,
                            height: 34,
                            color: PRIMARY,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      MyLocalizations.of(context).pickUp,
                                      textAlign: TextAlign.center,
                                      // style: hintStyleOSBType(),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                    ),
                                    widget.cart['orderType'] == 'Pickup'
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 15.0,
                                          )
                                        : Container(),
                                  ],
                                ),
                                widget.cart['orderType'] == 'Pickup'
                                    ? Divider(color: Colors.white)
                                    : Divider(color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                        isDeliveryAvailable
                            ? Container(
                                color: Colors.white,
                                height: 25,
                                width: 3,
                              )
                            : Container(),
                        isDeliveryAvailable
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    widget.cart['orderType'] = 'Delivery';
                                    widget.cart['pickupDate'] = null;
                                    widget.cart['pickupTime'] = null;
                                  });
                                },
                                child: Container(
                                  width: screenWidth(context) * 0.3,
                                  height: 34,
                                  color: PRIMARY,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            MyLocalizations.of(context)
                                                .dELIVERY,
                                            textAlign: TextAlign.center,
                                            // style: hintStyleOSBType(),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                          ),
                                          widget.cart['orderType'] == 'Delivery'
                                              ? Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 15.0,
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      widget.cart['orderType'] == 'Delivery'
                                          ? Divider(color: Colors.white)
                                          : Divider(color: Colors.black),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            widget.cart['orderType'] != 'Delivery'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Center(
                            child: Column(
                          children: <Widget>[
                            Text(
                              MyLocalizations.of(context).clickToSlot +
                                  widget.cart['orderType'] +
                                  MyLocalizations.of(context).dateandTime,
                              style: titleBlackLightOSB(),
                            ),
                            widget.cart['pickupDate'] != null
                                ? Text(
                                    MyLocalizations.of(context).date +
                                        ": " +
                                        widget.cart['pickupDate'],
                                    style: titleBlackLightOSB(),
                                  )
                                : Container(),
                            widget.cart['pickupTime'] != null
                                ? Text(
                                    MyLocalizations.of(context).time +
                                        ": " +
                                        widget.cart['pickupTime'],
                                    style: titleBlackLightOSB(),
                                  )
                                : Container(),
                            RaisedButton(
                              onPressed: () async {
                                setState(() {
                                  showSlotTimimg = false;
                                  widget.cart['pickupDate'] = null;
                                  widget.cart['pickupTime'] = null;
                                });
                                DatePicker.showDatePicker(
                                  context,
                                  showTitleActions: true,
                                  onChanged: (dt) => setState(
                                    () {
                                      pickupDate = dt;
                                      widget.cart['pickupDate'] =
                                          DateFormat('dd-MMM-yy')
                                              .format(pickupDate);
                                    },
                                  ),
                                  onConfirm: (date) {
                                    if (widget.cart['pickupDate'] == null) {
                                      widget.cart['pickupDate'] =
                                          DateFormat('dd-MMM-yy')
                                              .format(DateTime.now());
                                      getSlotTime(
                                          DateFormat('EEEE')
                                              .format(DateTime.now()),
                                          DateFormat('EEEE')
                                              .format(DateTime.now()),
                                          DateFormat('HH:mm')
                                              .format(DateTime.now()));
                                    } else {
                                      print(DateFormat('HH:mm')
                                          .format(DateTime.now()));
                                      getSlotTime(
                                          DateFormat('EEEE').format(pickupDate),
                                          DateFormat('EEEE')
                                              .format(DateTime.now()),
                                          DateFormat('HH:mm')
                                              .format(DateTime.now()));
                                    }
                                  },
                                  minTime: new DateTime.now()
                                      .add(new Duration(days: 0)),
                                  maxTime: new DateTime.now()
                                      .add(new Duration(days: 6)),
                                );
                              },
                              color: PRIMARY,
                              child: new Text(
                                MyLocalizations.of(context).selectDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0,
                                  color: Colors.white,
                                  fontFamily: 'OpenSansRegular',
                                ),
                              ),
                            ),
                          ],
                        )),
                        showSlotTimimg
                            ? isAlwaysOpenOrClose == false
                                ? todayWorkingHoursList.length > 0
                                    ? ListView.builder(
                                        physics: ScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(right: 0.0),
                                        itemCount: todayWorkingHoursList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: [
                                              ExpansionTile(
                                                trailing:
                                                    widget.cart['pickupTime'] !=
                                                            null
                                                        ? InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                widget.cart[
                                                                        'pickupTime'] =
                                                                    null;
                                                              });
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              size: 24.0,
                                                            ))
                                                        : Icon(
                                                            Icons.arrow_right,
                                                            size: 24.0,
                                                            color: PRIMARY,
                                                          ),
                                                // backgroundColor: PRIMARY,
                                                children: [
                                                  widget.cart['pickupTime'] ==
                                                          null
                                                      ? ListView.builder(
                                                          physics:
                                                              ScrollPhysics(),
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 0.0),
                                                          itemCount: todayWorkingHoursList[
                                                                          index]
                                                                      [
                                                                      'slotList'] ==
                                                                  null
                                                              ? 0
                                                              : todayWorkingHoursList[
                                                                          index]
                                                                      [
                                                                      'slotList']
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int indexx) {
                                                            return todayWorkingHoursList[index]
                                                                            [
                                                                            'slotList']
                                                                        .length >
                                                                    0
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20.0,
                                                                        right:
                                                                            20.0),
                                                                    child: Container(
                                                                        child: RaisedButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            showSlot =
                                                                                !showSlot;
                                                                          });
                                                                          if (todayWorkingHoursList[index]['slotList'][indexx] !=
                                                                              "No slot available") {
                                                                            selectedSlot =
                                                                                todayWorkingHoursList[index]['slotList'][indexx];

                                                                            widget.cart['pickupTime'] =
                                                                                selectedSlot;
                                                                          }
                                                                        });
                                                                      },
                                                                      color:
                                                                          PRIMARY,
                                                                      child:
                                                                          new Text(
                                                                        "${todayWorkingHoursList[index]['slotList'][indexx]}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              12.0,
                                                                          color:
                                                                              Colors.white,
                                                                          fontFamily:
                                                                              'OpenSansRegular',
                                                                        ),
                                                                      ),
                                                                    )),
                                                                  )
                                                                : Container();
                                                          })
                                                      : Container()
                                                ],
                                                title: new Text(
                                                  "${todayWorkingHoursList[index]['openTimeIn12Hr']} ${todayWorkingHoursList[index]['openTimeMeridian']}" +
                                                      " - " +
                                                      "${todayWorkingHoursList[index]['closeTimeIn12Hr']} ${todayWorkingHoursList[index]['closeTimeMeridian']}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12.0,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        'OpenSansRegular',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        })
                                    : Container(
                                        child: Center(
                                          child: Text(
                                            MyLocalizations.of(context).closed,
                                            style: titleBlackLightOSB(),
                                          ),
                                        ),
                                      )
                                : Center(
                                    child: Column(
                                    children: <Widget>[
                                      Text(
                                        MyLocalizations.of(context)
                                                .clickToSlot +
                                            widget.cart['orderType'] +
                                            MyLocalizations.of(context).time,
                                        style: titleBlackLightOSB(),
                                      ),
                                      RaisedButton(
                                        onPressed: () {
                                          DatePicker.showTimePicker(context,
                                              showTitleActions: true,
                                              onChanged: (dt) => setState(
                                                    () {
                                                      widget.cart[
                                                              'pickupTime'] =
                                                          DateFormat('hh:mm')
                                                              .format(dt);
                                                    },
                                                  ),
                                              onConfirm: (date) {},
                                              currentTime: new DateTime.now()
                                                  .add(new Duration(days: 0)));
                                        },
                                        color: PRIMARY,
                                        child: new Text(
                                          "24/7 " +
                                              MyLocalizations.of(context).open,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.0,
                                            color: Colors.white,
                                            fontFamily: 'OpenSansRegular',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                            : Container(
                                child: new Text(
                                  '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    color: Colors.black,
                                    fontFamily: 'OpenSansRegular',
                                  ),
                                ),
                              )
                      ])
                : Container(),
//                         Column(
//                                     children: <Widget>[
//                                       Text(
//                                         "Click To Slot " +
//                                             widget.cart['orderType'] +
//                                             ' Date and Time',
//                                         style: titleBlackLightOSB(),
//                                       ),
//                                       RaisedButton(
//                                         onPressed: () {
//                                           DatePicker.showDatePicker(context,
//                                               showTitleActions: true,
//                                               onChanged: (dt) => setState(
//                                                     () async {
//                                                       widget.cart[
//                                                               'pickupDate'] =
//                                                           DateFormat(
//                                                                   'dd-MMM-yy')
//                                                               .format(dt);
//                                                       getSlotTime( DateFormat(
//                                                           'dd-MMM-yy')
//                                                           .format(dt));

//                                                     },
//                                                   ),
//                                               onConfirm: (date) {

//                                               },
//                                               minTime: new DateTime.now()
//                                                   .add(new Duration(days: 0)),
//                                               maxTime: new DateTime.now()
//                                                   .add(new Duration(days: 7)),
//                                               currentTime: new DateTime.now()
//                                                   .add(new Duration(days: 0)));
//                                         },
//                                         color: PRIMARY,
//                                         child: new Text(
//                                           'Select Date',
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.w400,
//                                             fontSize: 12.0,
//                                             color: Colors.white,
//                                             fontFamily: 'OpenSansRegular',
//                                           ),
//                                         ),
//                                       ),
//                                       widget.cart['pickupDate'] != null
//                                           ? Text(
//                                               "Date " +
//                                                   widget.cart['pickupDate'],
//                                               style: titleBlackLightOSB(),
//                                             )
//                                           : Container(),
//                                       widget.cart['pickupTime'] != null
//                                           ? Text(
//                                               "Time " +
//                                                   widget.cart['pickupTime'],
//                                               style: titleBlackLightOSB(),
//                                             )
//                                           : Container()
//                                     ],
//                                   ),
//                       showSlot?
//                       isAlwaysOpenOrClose == true?

//                       Center(
//                                 child: Column(
//                                 children: <Widget>[
//                                   Text(
//                                     "Click To Slot " +
//                                         widget.cart['orderType'] +
//                                         'Time',
//                                     style: titleBlackLightOSB(),
//                                   ),
//                                   widget.cart['pickupDate'] != null
//                                       ? Text(
//                                           widget.cart['pickupDate'] +
//                                               ", " +
//                                               widget.cart['pickupTime'],
//                                           style: titleBlackLightOSB(),
//                                         )
//                                       : Container(),
//                                   RaisedButton(
//                                     onPressed: () {
//                                       DatePicker.showTimePicker(context,
//                                           showTitleActions: true,
//                                           onChanged: (dt) => setState(
//                                                 () {
//                                                   widget.cart['pickupDate'] =
//                                                       DateFormat('dd-MMM-yy')
//                                                           .format(dt);
//                                                   widget.cart['pickupTime'] =
//                                                       DateFormat('hh:mm')
//                                                           .format(dt);
//                                                 },
//                                               ),
//                                           onConfirm: (date) {},
// //                                          minTime: new DateTime.now()
// //                                              .add(new Duration(days: 0)),
// //                                          maxTime: new DateTime.now()
// //                                              .add(new Duration(days: 7)),
//                                           currentTime: new DateTime.now()
//                                               .add(new Duration(days: 0)));
//                                     },
//                                     color: PRIMARY,
//                                     child: new Text(
//                                       '24/7 open',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12.0,
//                                         color: Colors.white,
//                                         fontFamily: 'OpenSansRegular',
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )):ListView.builder(
//                                     physics: ScrollPhysics(),
//                                     shrinkWrap: true,
//                                     padding: EdgeInsets.only(right: 0.0),
//                                     itemCount: todayWorkingHoursList.length,
//                                     itemBuilder:
//                                         (BuildContext context, int index) {
//                                       return Column(
//                                         children: [
//                                           ExpansionTile(
//                                             children: [
//                                               ListView.builder(
//                                                   physics: ScrollPhysics(),
//                                                   shrinkWrap: true,
//                                                   scrollDirection:
//                                                       Axis.vertical,
//                                                   padding: EdgeInsets.only(
//                                                       right: 0.0),
//                                                   itemCount:
//                                                       todayWorkingHoursList[
//                                                               index]['slotList']
//                                                           .length,
//                                                   itemBuilder:
//                                                       (BuildContext context,
//                                                           int indexx) {
//                                                     return Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               left: 20.0,
//                                                               right: 20.0),
//                                                       child: Container(
//                                                           child: RaisedButton(
//                                                         onPressed: () {
//                                                           setState(() {
//                                                             selectedSlot =
//                                                                 todayWorkingHoursList[
//                                                                             index]
//                                                                         [
//                                                                         'slotList']
//                                                                     [indexx];

//                                                             widget.cart[
//                                                                     'pickupDate'] =
//                                                                 widget.cart[
//                                                                     'pickupDate'];
//                                                             widget.cart[
//                                                                     'pickupTime'] =
//                                                                 selectedSlot;
//                                                           });
//                                                         },
//                                                         color: PRIMARY,
//                                                         child: new Text(
//                                                           "${todayWorkingHoursList[index]['slotList'][indexx]}",
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w400,
//                                                             fontSize: 12.0,
//                                                             color: Colors.white,
//                                                             fontFamily:
//                                                                 'OpenSansRegular',
//                                                           ),
//                                                         ),
//                                                       )),
//                                                     );
//                                                   })
//                                             ],
//                                             title: new Text(
//                                               "${todayWorkingHoursList[index]['openTime']} ${todayWorkingHoursList[index]['openTimeMeridian']}" +
//                                                   " -" +
//                                                   "${todayWorkingHoursList[index]['closingTime']} ${todayWorkingHoursList[index]['closeTimeMeridian']}",
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w400,
//                                                 fontSize: 12.0,
//                                                 color: Colors.black,
//                                                 fontFamily: 'OpenSansRegular',
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     })
// //
//                               : Container(),
//                       ])
//                 : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBlock(
      String title, String value, Map<String, dynamic> userInfo) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              MyLocalizations.of(context).fullName,
              style: hintStyleOSB(),
            ),
            new Text(
              title,
              style: hintLightOSR(),
            ),
            new Divider(),
            new Text(
              MyLocalizations.of(context).mobileNumber,
              style: hintStyleOSB(),
            ),
            new Text(
              value,
              style: hintLightOSR(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(bool isPickup) {
    if (isPickup) {
      return Padding(
        padding: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: 10.0,
        ),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10.0),
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Text(widget.cart['productDetails'][0]['restaurantAddress']),
          ),
        ),
      );
    } else {
      return AsyncLoader(
          key: _asyncLoaderStateAddress,
          initState: () async => await _getAddressList(),
          renderLoad: () => Center(child: CircularProgressIndicator()),
          renderError: ([error]) {
            sentryError.reportError(error, null);
            return NoData(
                message: MyLocalizations.of(context).connectionError,
                icon: Icons.block);
          },
          renderSuccess: ({data}) {
            if (widget.cart['shippingAddress'] == null) {
              widget.cart['shippingAddress'] = data.length > 0 ? data[0] : null;
            }
            return Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                bottom: 10.0,
              ),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(right: 0.0),
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (data[index]['isSelected'] == null)
                          data[index]['isSelected'] = false;
                        return RadioListTile(
                          groupValue: selectedAddressIndex,
                          value: index,
                          selected: data[index]['isSelected'],
                          onChanged: (int selected) {
                            setState(() {
                              selectedAddressIndex = selected;
                              data[index]['isSelected'] =
                                  !data[index]['isSelected'];
                              widget.cart['shippingAddress'] = data[index];
                            });
                          },
                          activeColor: PRIMARY,
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                data[index]['name'],
                                style: hintStyleSmallTextDarkOSR(),
                              ),
                              new Text(
                                data[index]['address'],
                                style: hintStyleSmallTextDarkOSR(),
                              ),
                              new Text(
                                data[index]['contactNumber'].toString(),
                                style: hintStyleSmallTextDarkOSR(),
                              ),
                              new Text(
                                data[index]['zip'].toString(),
                                style: hintStyleSmallTextDarkOSR(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    InkWell(
                      onTap: () async {
                        Map<String, dynamic> address = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => AddAddressPage(
                                localizedValues: widget.localizedValues,
                                locale: widget.locale),
                          ),
                        );
                        if (address != null &&
                            address['name'] != null &&
                            address['address'] != null &&
                            address['zip'] != null) {
                          data.add(address);
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.add_circle,
                            color: PRIMARY,
                            size: 18.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              MyLocalizations.of(context).addAddress,
                              style: textPrimaryOSR(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  Widget _buildProductListBlock(Map<String, dynamic> userInfo) {
    List<dynamic> products = widget.cart['productDetails'];
    return Padding(
      padding: EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0, bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          flex: 6,
                          fit: FlexFit.tight,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                products[index]['title'],
                                style: subTitleDarkLightOSS(),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          fit: FlexFit.tight,
                          child: new Text(
                            'x' + products[index]['Quantity'].toString(),
                            textAlign: TextAlign.start,
                            style: hintStylePrimaryOSR(),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: new Text(
                            '$currency' +
                                products[index]['totalPrice']
                                    .toStringAsFixed(2),
                            style: hintStyleOSB(),
                          ),
                        ),
                      ],
                    ),
                    products[index]['note'] != null
                        ? Text(MyLocalizations.of(context).note +
                            ': ${products[index]['note']}')
                        : Container(),
                    Divider(),
                  ],
                );
              },
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.info,
                  color: PRIMARY,
                  size: 18.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    MyLocalizations.of(context).orderSummary,
                    style: textPrimaryOSR(),
                  ),
                )
              ],
            ),
            Divider(),
            _buildTotalPriceLine(
                MyLocalizations.of(context).subTotal, widget.cart['subTotal']),
            // widget.cart['taxInfo'] != null
            //     ? _buildTotalPriceLine(
            //         'Tax ' + widget.cart['taxInfo']['taxName'],
            //         (double.parse(
            //                 widget.cart['taxInfo']['taxRate'].toString()) *
            //             widget.cart['subTotal'] /
            //             100))
            //     : Container(height: 0, width: 0),
            _buildTotalPriceLine(
                MyLocalizations.of(context).deliveryCharges,
                widget.cart['deliveryCharge'] == 'Free'
                    ? '0.0'
                    : double.parse(widget.cart['deliveryCharge'].toString())),
            _buildTotalPriceLine(
                MyLocalizations.of(context).totalIncluding + ' GST',
                double.parse(widget.cart['grandTotal'].toString())),
            // _buildTotalPriceLine('Used Loyalty Point', usedLoyaltyPoint),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPriceLine(String title, double value) {
    return Container(
      height: 40.0,
      color: greyc,
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(
            title,
            style: titleBlackLightOSB(),
          ),
          new Text(
            '$currency' + value.toStringAsFixed(2),
            style: textLightOSR(),
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomBar() {
  //   return RawMaterialButton(
  //     onPressed: () {
  //       if (widget.cart['orderType'] == 'Pickup') {
  //         if (widget.cart['pickupDate'] != null) {
  //           _buildBottomBarButton();
  //         } else {
  //           showSnackbar(MyLocalizations.of(context).selectDateTime);
  //         }
  //       } else if (widget.cart['orderType'] == 'Delivery') {
  //         if (widget.cart['shippingAddress'] == null) {
  //           showSnackbar(MyLocalizations.of(context).selectAddressFirst);
  //         } else {
  //           if (widget.deliveryInfo == null ||
  //               widget.deliveryInfo['areaAthority']) {
  //             _buildBottomBarButton();
  //           } else {
  //             if (widget.deliveryInfo['areaCode'] == null ||
  //                 widget.deliveryInfo['areaCode'][0] == null) {
  //               _buildBottomBarButton();
  //             } else {
  //               bool isPinFound = false;
  //               for (int i = 0;
  //                   i < widget.deliveryInfo['areaCode'].length;
  //                   i++) {
  //                 if (widget.deliveryInfo['areaCode'][i]['pinCode']
  //                         .toString() ==
  //                     widget.cart['shippingAddress']['zip'].toString()) {
  //                   isPinFound = true;
  //                 }
  //               }
  //               if (isPinFound) {
  //                 _buildBottomBarButton();
  //               } else {
  //                 _showAvailablePincodeAlert(
  //                     widget.cart['restaurant'],
  //                     widget.cart['shippingAddress']['zip'].toString(),
  //                     widget.deliveryInfo['areaCode']);
  //               }
  //             }
  //           }
  //         }
  //       } else {
  //         showSnackbar(MyLocalizations.of(context).errorMessage);
  //       }
  //     },
  Widget _buildBottomBar() {
    return RawMaterialButton(
      onPressed: () {
        if (widget.cart['orderType'] == 'Dine In') {
          // if (widget.tableInfo == null) {
          //   showSnackbar('Wrong Table Info please scan barcode again!');
          // } else {
          _buildBottomBarButton();
          // }
        } else if (widget.cart['orderType'] == 'Pickup') {
          if (widget.cart['pickupDate'] != null &&
              widget.cart['pickupTime'] != null) {
            _buildBottomBarButton();
          } else if (widget.cart['pickupDate'] == null) {
            showSnackbar(
                MyLocalizations.of(context).pleaseSelectDatefirstforpickup);
          } else if (widget.cart['pickupTime'] == null) {
            showSnackbar(
                MyLocalizations.of(context).pleaseSelectTimefirstforpickup);
          } else {
            showSnackbar('Please Select Date and Time first for pickup');
          }
        } else if (widget.cart['orderType'] == 'Delivery') {
          if (widget.cart['shippingAddress'] == null) {
            showSnackbar(MyLocalizations.of(context)
                .pleaseSelectAddshippingaddressfirst);
          } else {
            if (widget.deliveryInfo == null ||
                widget.deliveryInfo['areaAthority']) {
              openAndCloseTime == "Open"
                  ? _buildBottomBarButton()
                  : showSnackbar(MyLocalizations.of(context)
                      .storeisClosedPleaseTryAgainduringouropeninghours);
            } else {
              if (widget.deliveryInfo['areaCode'] == null ||
                  widget.deliveryInfo['areaCode'][0] == null) {
                openAndCloseTime == "Open"
                    ? _buildBottomBarButton()
                    : showSnackbar(MyLocalizations.of(context)
                        .storeisClosedPleaseTryAgainduringouropeninghours);
              } else {
                bool isPinFound = false;
                for (int i = 0;
                    i < widget.deliveryInfo['areaCode'].length;
                    i++) {
                  if (widget.deliveryInfo['areaCode'][i]['pinCode']
                          .toString() ==
                      widget.cart['shippingAddress']['zip'].toString()) {
                    isPinFound = true;
                  }
                }
                if (isPinFound) {
                  openAndCloseTime == "Open"
                      ? _buildBottomBarButton()
                      : showSnackbar(MyLocalizations.of(context)
                          .storeisClosedPleaseTryAgainduringouropeninghours);
                } else {
                  _showAvailablePincodeAlert(
                      widget.cart['restaurant'],
                      widget.cart['shippingAddress']['zip'].toString(),
                      widget.deliveryInfo['areaCode']);
                }
              }
            }
          }
        } else {
          showSnackbar(MyLocalizations.of(context)
                  .somethingwentwrongpleaserestarttheapp +
              '.');
        }
      },
      child: new Row(
        children: <Widget>[
          Expanded(
            child: new Container(
              height: 70.0,
              color: PRIMARY,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(top: 10.0)),
                  new Text(
                    MyLocalizations.of(context).placeOrderNow,
                    style: subTitleWhiteLightOSR(),
                  ),
                  new Padding(padding: EdgeInsets.only(top: 5.0)),
                  new Text(
                    MyLocalizations.of(context).total + ': $currency ${widget.cart['grandTotal'].toStringAsFixed(2)}',
                    style: titleWhiteBoldOSB(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _buildBottomBarButton() {
    if (widget.cart['pickupDate'] != null ||
        widget.cart['pickupStamp'] != null ||
        widget.cart['pickupTime'] != null) {
      widget.cart['loyalty'] =
          double.parse(usedLoyaltyPoint.toStringAsFixed(2));
      widget.cart['pickupTime'] = widget.cart['pickupTime'];
      widget.cart['pickupDate'] = widget.cart['pickupDate'];
      widget.cart['shippingAddress'] = null;
      print(widget.cart['pickupDate']);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => PaymentMethod(
              cart: widget.cart,
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
          ));
    } else {
      widget.cart['loyalty'] =
          double.parse(usedLoyaltyPoint.toStringAsFixed(2));
      widget.cart['shippingAddress'] = widget.cart['shippingAddress'];

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => PaymentMethod(
              cart: widget.cart,
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
          ));
    }
  }

  Future<void> _showAvailablePincodeAlert(
      String restaurant, String zip, List<dynamic> pins) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyLocalizations.of(context).deliveryNotAvailable),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(restaurant +
                    MyLocalizations.of(context).notDeliverToThisPostcode +
                    zip +
                    MyLocalizations.of(context).deliverToThisPostcode +
                    ' :'),
                Divider(),
                SingleChildScrollView(
                  child: ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pins.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Text(pins[index]['pinCode'].toString()),
                        );
                      }),
                ),
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

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
