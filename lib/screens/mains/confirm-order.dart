import 'dart:async';
import 'dart:core';

import 'package:RestaurantSaas/screens/other/thank-you.dart';
import 'package:RestaurantSaas/services/constant.dart';
import 'package:RestaurantSaas/widgets/appbar.dart';
import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_map_picker/flutter_map_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/localizations.dart';
import '../../services/main-service.dart';
import '../../services/profile-service.dart';
import '../../services/sentry-services.dart';
import '../../styles/styles.dart';
import '../../widgets/no-data.dart';
import 'add-address.dart';
import 'payment-method.dart';

SentryError sentryError = new SentryError();

class ConfrimOrderPage extends StatefulWidget {
  final Map<String, dynamic> cart, deliveryInfo, tableInfo;
  final Map<String, Map<String, String>> localizedValues;
  final String locale, currency;

  ConfrimOrderPage(
      {Key key,
      this.cart,
      this.tableInfo,
      this.deliveryInfo,
      this.localizedValues,
      this.locale,
      this.currency})
      : super(key: key);

  @override
  _ConfrimOrderPageState createState() => _ConfrimOrderPageState();
}

class _ConfrimOrderPageState extends State<ConfrimOrderPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  int selectedAddressIndex = 0;
  LocationData currentLocation;
  Location _location = new Location();
  double grandTotal = 0.0, tempGrandTotal = 0.0;
  int deliveryCharge = 0;
  int selectedRadio;

  bool isDeliveryAvailable = true,
      isFirstTime = true,
      isAlwaysOpenOrClose = false,
      isAlwaysOpenOrCloseLoading = false,
      showSlot = false,
      showSlotTimimg = false,
      isAddressget = false,
      placeOrderLoading = false;

  Map<String, dynamic> userInfo;
  List paymentMethods;
  String openAndCloseTime;
  List<dynamic> todayWorkingHoursList, addressList;
  var selectedSlot;
  DateTime pickupDate, pickupTime;
  String currency = '';

  int tempDeliveryCharge;

  int dc;

  double gt;

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
    await MainService.getAdminSettings().then((onValue) {
      try {
        paymentMethods = onValue['paymentMethod'];
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      sentryError.reportError(error, null);
    });

    await MainService.getRestaurantOpenAndCloseTime(
            widget.cart['locationId'],
            DateFormat('HH:mm').format(DateTime.now()),
            DateFormat('EEEE').format(DateTime.now()))
        .then((verifyOpenAndCloseTime) {
      try {
        setState(() {
          openAndCloseTime = verifyOpenAndCloseTime['res_code'] == 200
              ? 'OPEN'
              : verifyOpenAndCloseTime['res_code'] == 400
                  ? 'CLOSE'
                  : verifyOpenAndCloseTime['message'];
        });
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return userInfo;
  }

  _getAddressList() async {
    if (mounted) {
      setState(() {
        isAddressget = true;
      });
    }
    await ProfileService.getAddressList().then((value) {
      try {
        if (mounted) {
          setState(() {
            addressList = value;
            isAddressget = false;
          });
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  _deleteAddressList(index) async {
    if (mounted) {
      setState(() {
        isAddressget = true;
      });
    }
    await ProfileService.deleteAddress(index).then((value) {
      try {
        if (mounted) {
          setState(() {
            _getAddressList();
          });
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
  }

  void _calculateFinalAmount() {
    if ((widget.deliveryInfo != null) &&
        (widget.deliveryInfo['isDeliveryAvailable'] != null) &&
        (widget.deliveryInfo['isDeliveryAvailable'] == false)) {
      if (mounted) {
        setState(() {
          isDeliveryAvailable = false;
          widget.cart['orderType'] = 'Pickup';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isDeliveryAvailable = true;
        });
      }
    }
    if (widget.tableInfo != null) {
      widget.cart['isForDineIn'] = true;
      widget.cart['orderType'] = 'Dine In';
      widget.cart['tableNumber'] = widget.tableInfo['tableNumber'];
    }
    if (isFirstTime) {
      if (mounted) {
        setState(() {
          tempGrandTotal = widget.cart['grandTotal'];
          grandTotal = tempGrandTotal;
          deliveryCharge = widget.cart['deliveryCharge'];
          isFirstTime = false;
        });
      }
    }
    if (widget.cart['orderType'] == 'Delivery') {
      if (mounted) {
        setState(() {
          widget.cart['deliveryCharge'] = deliveryCharge;
          widget.cart['grandTotal'] = grandTotal;
          widget.cart['payableAmount'] = grandTotal;
        });
      }
    } else if (widget.cart['orderType'] == 'Pickup' ||
        widget.cart['orderType'] == 'Dine In') {
      if (mounted) {
        setState(() {
          if (grandTotal > 0) {
            widget.cart['grandTotal'] = grandTotal - deliveryCharge;
          }
          widget.cart['deliveryCharge'] = 0;
          widget.cart['payableAmount'] = widget.cart['grandTotal'];
        });
      }
    }
  }

  getSlotTime(dt, todayDay, time) async {
    await MainService.getTodayAndOtherDaysWorkingTimimgs(
            widget.cart['locationId'], dt, time, todayDay)
        .then((onValue) {
      if (mounted) {
        setState(() {
          isAlwaysOpenOrCloseLoading = true;
        });
      }
      if (mounted) {
        if (onValue['isAlwaysOpen'] == true) {
          if (mounted) {
            setState(() {
              isAlwaysOpenOrClose = true;
              todayWorkingHoursList = onValue['newDaySlot'];

              showSlotTimimg = !showSlotTimimg;
            });
          }
          if (mounted) {
            setState(() {
              isAlwaysOpenOrCloseLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              todayWorkingHoursList = onValue['newDaySlot'];
              showSlotTimimg = !showSlotTimimg;
            });
          }
          if (mounted) {
            setState(() {
              isAlwaysOpenOrCloseLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  void initState() {
    dc = widget.cart['deliveryCharge'];
    gt = widget.cart['grandTotal'];
    selectedRadio = widget.cart['orderType'] == 'Delivery' ? 1 : 0;
    getGlobalSettingsData();
    _getAddressList();
    super.initState();
  }

  getGlobalSettingsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString('currency');
  }

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

    return Scaffold(
      backgroundColor: bg,
      key: _scaffoldKey,
      appBar: appBarWithTitle(context, MyLocalizations.of(context).reviewOrder),
      // AppBar(
      //   leading: InkWell(
      //     onTap: () {
      //       widget.cart['deliveryCharge'] = dc;
      //       widget.cart['grandTotal'] = gt;
      //       Navigator.of(context).pop();
      //     },
      //     child: Icon(
      //       Icons.arrow_back,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: primary,
      //   elevation: 0.0,
      //   title: new Text(
      //     MyLocalizations.of(context).reviewOrder,
      //     style: textbarlowSemiBoldWhite(),
      //   ),
      //   centerTitle: true,
      // ),
      body: _asyncLoader,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget infoBlock(title, value) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: textMuliRegularsm(),
          ),
          Text(
            value,
            style: textMuliSemiboldmd(),
          ),
        ],
      ),
    );
  }

  Widget contactDetails(userInfo) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(MyLocalizations.of(context).contactInformation,
              style: textMuliSemiboldextra()),
          SizedBox(height: 10),
          infoBlock('Full Name', userInfo['name']),
          Divider(
            color: secondary.withOpacity(0.1),
            height: 22,
          ),
          infoBlock('Mobile Number', userInfo['contactNumber'].toString()),
        ],
      ),
    );
  }

  Widget orderType() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(MyLocalizations.of(context).selectOrderType,
              style: textMuliSemiboldextra()),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 6,
                child: RadioListTile(
                  value: 0,
                  groupValue: selectedRadio,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    if (mounted) {
                      setState(() {
                        selectedRadio = val;
                        widget.cart['orderType'] = 'Pickup';
                      });
                    }
                  },
                  title: Text(
                    'PickUp',
                    style: textMuliSemiboldm(),
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: RadioListTile(
                  value: 1,
                  groupValue: selectedRadio,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    if (mounted) {
                      setState(() {
                        selectedRadio = val;
                        widget.cart['orderType'] = 'Delivery';
                        widget.cart['pickupDate'] = null;
                        widget.cart['pickupTime'] = null;
                      });
                    }
                  },
                  title: Text(
                    'Delivery',
                    style: textMuliSemiboldm(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
    return ListView(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        contactDetails(userInfo),
        orderType(),
        widget.tableInfo == null
            ? _buildOrderTypeBlock()
            : _buildDineInTypeBlock(),
        isDineIn ? Container() : deliveryType(isPickup),
        // _buildBulletTitle(isDineIn ? 3 : 4, MyLocalizations.of(context).orderDetails),
        _buildProductListBlock(userInfo),
        billDetails()
      ],
    );
  }

  Widget deliveryType(bool isPickup) {
    if (isPickup) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MyLocalizations.of(context).restaurantAddress,
              style: textMuliSemiboldextra(),
            ),
            SizedBox(height: 6,),
            Text(widget.cart['productDetails'][0]['restaurantAddress']),
          ],
        ),
      );
    } else {
      return isAddressget
          ? CircularProgressIndicator()
          : Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Select Address',
                          style: textMuliSemiboldextra(),
                        ),
                        InkWell(
                          onTap: () async {
                            currentLocation = await _location.getLocation();
                            if (currentLocation != null) {
                              PlacePickerResult pickerResult =
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PlacePickerScreen(
                                                googlePlacesApiKey:
                                                    GOOGLE_API_KEY,
                                                initialPosition: LatLng(
                                                    currentLocation.latitude,
                                                    currentLocation.longitude),
                                                mainColor: primary,
                                                mapStrings:
                                                    MapPickerStrings.english(),
                                                placeAutoCompleteLanguage: 'en',
                                              )));
                              if (pickerResult != null) {
                                setState(() {
                                  var result = Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          AddAddressPage(
                                              localizedValues:
                                                  widget.localizedValues,
                                              locale: widget.locale,
                                              loactionAddress: {
                                            'address':
                                                pickerResult.address.toString(),
                                            'lat': pickerResult.latLng.latitude,
                                            'long':
                                                pickerResult.latLng.longitude
                                          }),
                                    ),
                                  );
                                  result.then((res) {
                                    _getAddressList();
                                    _getUserInfo();
                                  });
                                });
                              }
                            } else {
                              showError(
                                  MyLocalizations.of(context)
                                      .enableTogetlocation,
                                  MyLocalizations.of(context).gPSsettings);
                            }
                          },
                          child: Text(
                            '+Add Address',
                            style: textMuliSemiboldextraprimary(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  addressList.length > 0
                      ? ListView.builder(
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: addressList.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, int index) {
                            if (addressList[index]['isSelected'] == null) {
                              if (index == 0) {
                                addressList[index]['isSelected'] = true;
                              } else {
                                addressList[index]['isSelected'] = false;
                              }
                            }
                            return Column(
                              children: <Widget>[
                                RadioListTile(
                                  groupValue: selectedAddressIndex,
                                  value: index,
                                  selected: addressList[index]['isSelected'],
                                  onChanged: (int selected) {
                                    if (mounted) {
                                      setState(() {
                                        selectedAddressIndex = selected;
                                        addressList[index]['isSelected'] =
                                            !addressList[index]['isSelected'];
                                        widget.cart['shippingAddress'] =
                                            addressList[index];
                                      });
                                    }
                                  },
                                  activeColor: primary,
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(
                                        addressList[index]['addressType'],
                                        style: textMuliRegular(),
                                      ),
                                      new Text(
                                        addressList[index]['address'],
                                        style: textMuliRegular(),
                                      ),
                                      new Text(
                                        addressList[index]['contactNumber']
                                            .toString(),
                                        style: textMuliRegular(),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 112,
                                      height: 32,
                                      margin: EdgeInsets.all(8),
                                      child: RaisedButton(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              side: BorderSide(color: primary)),
                                          onPressed: () {
                                            _deleteAddressList(index);
                                          },
                                          child: Text(
                                            'Delete',
                                            style: textMuliSemiboldprimary(),
                                          )),
                                    ),
                                    Container(
                                      width: 112,
                                      height: 32,
                                      margin: EdgeInsets.all(8),
                                      child: RaisedButton(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                              side: BorderSide(color: primary)),
                                          onPressed: () {
                                            // _deleteAddressList(index);
                                          },
                                          child: Text(
                                            'Edit',
                                            style: textMuliSemiboldprimary(),
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          })
                      : Container(),
                ],
              ),
            );
    }
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
                    borderRadius: BorderRadius.circular(9.0), color: primary),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: screenWidth(context) * 0.7,
                          height: 34,
                          color: primary,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    MyLocalizations.of(context).dineIn,
                                    textAlign: TextAlign.center,
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
    return widget.cart['orderType'] == 'Delivery'
        ? Container()
        : Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        MyLocalizations.of(context).clickToSlot +
                            " " +
                            MyLocalizations.of(context).pickUp +
                            " " +
                            MyLocalizations.of(context).dateandTime,
                        style: textMuliSemiboldextra(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      widget.cart['pickupDate'] != null
                          ? Text(
                              MyLocalizations.of(context).pickUp +
                                  " " +
                                  MyLocalizations.of(context).date +
                                  " : " +
                                  widget.cart['pickupDate'],
                              style: titleBlackLightOSB(),
                            )
                          : Container(),
                      widget.cart['pickupTime'] != null
                          ? Text(
                              MyLocalizations.of(context).pickUp +
                                  " " +
                                  MyLocalizations.of(context).time +
                                  " : " +
                                  widget.cart['pickupTime'],
                              style: titleBlackLightOSB(),
                            )
                          : Container(),
                      RaisedButton(
                        onPressed: () async {
                          if (mounted) {
                            setState(() {
                              showSlotTimimg = false;
                              widget.cart['pickupDate'] = null;
                              widget.cart['pickupTime'] = null;
                            });
                          }
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            onChanged: (dt) {
                              if (mounted) {
                                setState(() {
                                  pickupDate = dt;
                                  widget.cart['pickupDate'] =
                                      DateFormat('dd-MMM-yy')
                                          .format(pickupDate);
                                });
                              }
                            },
                            onConfirm: (date) {
                              if (widget.cart['pickupDate'] == null) {
                                widget.cart['pickupDate'] =
                                    DateFormat('dd-MMM-yy')
                                        .format(DateTime.now());
                                getSlotTime(
                                    DateFormat('EEEE').format(DateTime.now()),
                                    DateFormat('EEEE').format(DateTime.now()),
                                    DateFormat('HH:mm').format(DateTime.now()));
                              } else {
                                getSlotTime(
                                    DateFormat('EEEE').format(pickupDate),
                                    DateFormat('EEEE').format(DateTime.now()),
                                    DateFormat('HH:mm').format(DateTime.now()));
                              }
                            },
                            minTime:
                                new DateTime.now().add(new Duration(days: 0)),
                            maxTime:
                                new DateTime.now().add(new Duration(days: 6)),
                          );
                        },
                        color: primary,
                        child: new Text(
                          MyLocalizations.of(context).selectDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: Colors.white,
                            fontFamily: 'OpenSansRegular',
                          ),
                        ),
                      ),
                      showSlotTimimg
                          ? isAlwaysOpenOrClose == false
                              ? todayWorkingHoursList.length > 0
                                  ? ListView.builder(
                                      physics: ScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: todayWorkingHoursList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            ExpansionTile(
                                              trailing: widget
                                                          .cart['pickupTime'] !=
                                                      null
                                                  ? InkWell(
                                                      onTap: () {
                                                        if (mounted) {
                                                          setState(() {
                                                            widget.cart[
                                                                    'pickupTime'] =
                                                                null;
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 24.0,
                                                      ))
                                                  : Icon(
                                                      Icons.arrow_right,
                                                      size: 24.0,
                                                      color: primary,
                                                    ),
                                              children: [
                                                widget.cart['pickupTime'] ==
                                                        null
                                                    ? GridView.builder(
                                                        physics:
                                                            ScrollPhysics(),
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 0.0),
                                                        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                                            mainAxisSpacing: 4,
                                                            crossAxisSpacing: 4,
                                                            childAspectRatio:
                                                                MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    155,
                                                            crossAxisCount: 4),
                                                        itemCount: todayWorkingHoursList[index]
                                                                    [
                                                                    'slotList'] ==
                                                                null
                                                            ? 0
                                                            : todayWorkingHoursList[index]
                                                                    ['slotList']
                                                                .length,
                                                        itemBuilder:
                                                            (BuildContext context,
                                                                int indexx) {
                                                          return todayWorkingHoursList[
                                                                              index]
                                                                          [
                                                                          'slotList']
                                                                      .length >
                                                                  0
                                                              ? Container(
                                                                  child:
                                                                      RaisedButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (mounted) {
                                                                      setState(
                                                                          () {
                                                                        if (mounted) {
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
                                                                        }
                                                                      });
                                                                    }
                                                                  },
                                                                  color:
                                                                      primary,
                                                                  child:
                                                                      new Text(
                                                                    "${todayWorkingHoursList[index]['slotList'][indexx]}",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12.0,
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          'OpenSansRegular',
                                                                    ),
                                                                  ),
                                                                ))
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
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                  fontFamily: 'OpenSansRegular',
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
                                      MyLocalizations.of(context).clickToSlot +
                                          MyLocalizations.of(context).pickUp +
                                          MyLocalizations.of(context).time,
                                      style: titleBlackLightOSB(),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        DatePicker.showTimePicker(context,
                                            showTitleActions: true,
                                            onChanged: (dt) => setState(
                                                  () {
                                                    widget.cart['pickupTime'] =
                                                        DateFormat('hh:mm a')
                                                            .format(dt);
                                                  },
                                                ),
                                            onConfirm: (date) {},
                                            currentTime: new DateTime.now()
                                                .add(new Duration(days: 0)));
                                      },
                                      color: primary,
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
              ],
            ),
          );
  }

  showError(error, message) async {
    showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(
            top: 10.0,
          ),
          title: new Text(
            "$error",
            textAlign: TextAlign.center,
          ),
          content: Container(
            height: 120.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: new Text(
                    "$message",
                    textAlign: TextAlign.center,
                  ),
                ),
                Column(
                  children: <Widget>[
                    Divider(),
                    IntrinsicHeight(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(bottom: 12.0),
                                height: 30.0,
                                decoration: BoxDecoration(),
                                child: Text(
                                  MyLocalizations.of(context).ok,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget priceTagLine(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: textMuliRegulars(),
        ),
        Text(
          '$currency' + value.toStringAsFixed(2),
          style: textMuliRegulars(),
        ),
      ],
    );
  }

  Widget billDetails() {
    print('cart ${widget.cart}');
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Bill Details : ',
            style: textMuliSemiboldextra(),
          ),
          SizedBox(height: 12),
          priceTagLine(MyLocalizations.of(context).subTotal, widget.cart['subTotal']),
          SizedBox(height: 9),
          priceTagLine(MyLocalizations.of(context).deliveryCharges, widget.cart['deliveryCharge'] == 'Free'
              ? '0'
              : double.parse(widget.cart['deliveryCharge'].toString())),
          // selectedCoupon != null ? priceTagLine(MyLocalizations.of(context).coupon, couponDeduction) : Container(),
          Divider(color: secondary.withOpacity(0.1), thickness: 1, height: 22),
          priceTagLine(MyLocalizations.of(context).grandTotal, widget.cart['grandTotal']),
        ],
      ),
    );
  }

  Widget _buildProductListBlock(Map<String, dynamic> userInfo) {
    List<dynamic> products = widget.cart['productDetails'];
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
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
                          style: hintStyleprimaryOSR(),
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
                  products[index]['flavour'] != null
                      ? buildFlavourList(products[index]['flavour'])
                      : Container(),
                  products[index]['note'] != null
                      ? Text(MyLocalizations.of(context).note +
                          ': ${products[index]['note']}')
                      : Container(),
                  Divider(),
                ],
              );
            },
          ),
          // Row(
          //   children: <Widget>[
          //     Icon(
          //       Icons.info,
          //       color: primary,
          //       size: 18.0,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(left: 8.0),
          //       child: Text(
          //         MyLocalizations.of(context).orderSummary,
          //         style: textprimaryOSR(),
          //       ),
          //     )
          //   ],
          // ),

          // Divider(),
          // _buildTotalPriceLine(
          //     MyLocalizations.of(context).subTotal, widget.cart['subTotal']),
          // _buildTotalPriceLine(
          //     MyLocalizations.of(context).deliveryCharges,
          //     widget.cart['deliveryCharge'] == 'Free'
          //         ? '0'
          //         : double.parse(widget.cart['deliveryCharge'].toString())),
          // _buildTotalPriceLine(MyLocalizations.of(context).grandTotal,
          //     double.parse(widget.cart['grandTotal'].toString())),
        ],
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

  Widget _buildBottomBar() {
    return placeOrderLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        width: 335,
        height: 41,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.29), blurRadius: 5)
            ]),
        child: RaisedButton(
            color: primary,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            onPressed:  () {
              if (widget.cart['orderType'] == 'Dine In') {
                _buildBottomBarButton();
              } else if (widget.cart['orderType'] == 'Pickup') {
                if (widget.cart['pickupDate'] != null &&
                    widget.cart['pickupTime'] != null) {
                  _buildBottomBarButton();
                } else if (widget.cart['pickupDate'] == null) {
                  showSnackbar(MyLocalizations.of(context)
                      .pleaseSelectDatefirstforpickup);
                } else if (widget.cart['pickupTime'] == null) {
                  showSnackbar(MyLocalizations.of(context)
                      .pleaseSelectTimefirstforpickup);
                } else {
                  showSnackbar(MyLocalizations.of(context).selectDateTime);
                }
              } else if (widget.cart['orderType'] == 'Delivery') {
                if (widget.cart['shippingAddress'] == null) {
                  if (addressList.length == 0) {
                    showSnackbar(MyLocalizations.of(context).addAddress);
                  }
                  widget.cart['shippingAddress'] = addressList[0];
                }
                if (widget.deliveryInfo == null ||
                    widget.deliveryInfo['areaAthority']) {
                  openAndCloseTime == "OPEN"
                      ? _buildBottomBarButton()
                      : showSnackbar(MyLocalizations.of(context)
                      .storeisClosedPleaseTryAgainduringouropeninghours);
                } else {
                  if (widget.deliveryInfo['areaCode'] == null ||
                      widget.deliveryInfo['areaCode'][0] == null) {
                    openAndCloseTime == "OPEN"
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
                          widget.cart['shippingAddress']['postalCode']
                              .toString()) {
                        isPinFound = true;
                      }
                    }
                    if (isPinFound) {
                      openAndCloseTime == "OPEN"
                          ? _buildBottomBarButton()
                          : showSnackbar(MyLocalizations.of(context)
                          .storeisClosedPleaseTryAgainduringouropeninghours);
                    } else {
                      _showAvailablePincodeAlert(
                          widget.cart['restaurant'],
                          widget.cart['shippingAddress']['postalCode']
                              .toString(),
                          widget.deliveryInfo['areaCode']);
                    }
                  }
                }
              } else {
                showSnackbar(MyLocalizations.of(context)
                    .somethingwentwrongpleaserestarttheapp +
                    '.');
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: 'To Pay : ',
                    style: textMuliSemiboldwhiteexs(),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                  '${widget.currency ?? currency} ${widget.cart['grandTotal'].toStringAsFixed(2)}',
                          // ' $currency ${grandTotal.toStringAsFixed(2)}',
                          style: textMuliSemiboldwhite()),
                    ],
                  ),
                ),
                Text(
                    MyLocalizations.of(context).placeOrderNow,
                  style: textMuliSemiboldwhite(),
                ),
              ],
            )),
      ),
    );
    // RawMaterialButton(
    //         onPressed: () {
    //           if (widget.cart['orderType'] == 'Dine In') {
    //             _buildBottomBarButton();
    //           } else if (widget.cart['orderType'] == 'Pickup') {
    //             if (widget.cart['pickupDate'] != null &&
    //                 widget.cart['pickupTime'] != null) {
    //               _buildBottomBarButton();
    //             } else if (widget.cart['pickupDate'] == null) {
    //               showSnackbar(MyLocalizations.of(context)
    //                   .pleaseSelectDatefirstforpickup);
    //             } else if (widget.cart['pickupTime'] == null) {
    //               showSnackbar(MyLocalizations.of(context)
    //                   .pleaseSelectTimefirstforpickup);
    //             } else {
    //               showSnackbar(MyLocalizations.of(context).selectDateTime);
    //             }
    //           } else if (widget.cart['orderType'] == 'Delivery') {
    //             if (widget.cart['shippingAddress'] == null) {
    //               if (addressList.length == 0) {
    //                 showSnackbar(MyLocalizations.of(context).addAddress);
    //               }
    //               widget.cart['shippingAddress'] = addressList[0];
    //             }
    //             if (widget.deliveryInfo == null ||
    //                 widget.deliveryInfo['areaAthority']) {
    //               openAndCloseTime == "OPEN"
    //                   ? _buildBottomBarButton()
    //                   : showSnackbar(MyLocalizations.of(context)
    //                       .storeisClosedPleaseTryAgainduringouropeninghours);
    //             } else {
    //               if (widget.deliveryInfo['areaCode'] == null ||
    //                   widget.deliveryInfo['areaCode'][0] == null) {
    //                 openAndCloseTime == "OPEN"
    //                     ? _buildBottomBarButton()
    //                     : showSnackbar(MyLocalizations.of(context)
    //                         .storeisClosedPleaseTryAgainduringouropeninghours);
    //               } else {
    //                 bool isPinFound = false;
    //                 for (int i = 0;
    //                     i < widget.deliveryInfo['areaCode'].length;
    //                     i++) {
    //                   if (widget.deliveryInfo['areaCode'][i]['pinCode']
    //                           .toString() ==
    //                       widget.cart['shippingAddress']['postalCode']
    //                           .toString()) {
    //                     isPinFound = true;
    //                   }
    //                 }
    //                 if (isPinFound) {
    //                   openAndCloseTime == "OPEN"
    //                       ? _buildBottomBarButton()
    //                       : showSnackbar(MyLocalizations.of(context)
    //                           .storeisClosedPleaseTryAgainduringouropeninghours);
    //                 } else {
    //                   _showAvailablePincodeAlert(
    //                       widget.cart['restaurant'],
    //                       widget.cart['shippingAddress']['postalCode']
    //                           .toString(),
    //                       widget.deliveryInfo['areaCode']);
    //                 }
    //               }
    //             }
    //           } else {
    //             showSnackbar(MyLocalizations.of(context)
    //                     .somethingwentwrongpleaserestarttheapp +
    //                 '.');
    //           }
    //         },
    //         child: new Row(
    //           children: <Widget>[
    //             Expanded(
    //               child: new Container(
    //                 height: 78.0,
    //                 color: primary,
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: <Widget>[
    //                     new Padding(padding: EdgeInsets.only(top: 10.0)),
    //                     new Text(
    //                       MyLocalizations.of(context).placeOrderNow,
    //                       style: subTitleWhiteLightOSR(),
    //                     ),
    //                     new Padding(padding: EdgeInsets.only(top: 5.0)),
    //                     new Text(
    //                       MyLocalizations.of(context).total +
    //                           ': ${widget.currency ?? currency} ${widget.cart['grandTotal'].toStringAsFixed(2)}',
    //                       style: titleWhiteBoldOSB(),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
  }

  void _buildBottomBarButton() {
//    widget.cart['shippingAddress'] = {
//      'location': {'lat': 12.9546723, 'long': 77.5736175},
//      'address':
//          'MDR26, Mandapam, Rapakaputtuga, Sompeta, Andhra Pradesh 532284, India',
//      'landmark': 'jffnnfn',
//      'contactNumber': .808848,
//      'addressType': 'Hogar',
//      'isSelected': true
//    };
    if (widget.cart['pickupDate'] != null ||
        widget.cart['pickupStamp'] != null ||
        widget.cart['pickupTime'] != null) {
      widget.cart['pickupTime'] = widget.cart['pickupTime'];
      widget.cart['pickupDate'] = widget.cart['pickupDate'];
      widget.cart['shippingAddress'] = null;

      if (widget.cart['grandTotal'] != 0) {
        if (mounted) {
          setState(() {
            placeOrderLoading = false;
          });
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => PaymentMethod(
                cart: widget.cart,
                locale: widget.locale,
                localizedValues: widget.localizedValues,
                paymentMethods: paymentMethods,
              ),
            ));
      } else {
        orderInfo();
      }
    } else {
      widget.cart['shippingAddress'] = widget.cart['shippingAddress'];
      if (widget.cart['grandTotal'] != 0) {
        if (mounted) {
          setState(() {
            placeOrderLoading = false;
          });
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => PaymentMethod(
                cart: widget.cart,
                locale: widget.locale,
                localizedValues: widget.localizedValues,
                paymentMethods: paymentMethods,
              ),
            ));
      } else {
        orderInfo();
      }
    }
  }

  void orderInfo() {
    widget.cart['createdAtTime'] = DateTime.now().millisecondsSinceEpoch;
    widget.cart['restaurant'] = widget.cart['productDetails'][0]['restaurant'];
    widget.cart['restaurant'] = widget.cart['productDetails'][0]['restaurant'];
    widget.cart['restaurantID'] =
        widget.cart['productDetails'][0]['restaurantID'];
    widget.cart['paymentOption'] = "COD";
    ProfileService.placeOrder(widget.cart).then((onValue) {
      if (mounted) {
        setState(() {
          placeOrderLoading = false;
        });
      }
      if (onValue != null &&
          onValue['message'] != null &&
          onValue['statusCode'] == 200) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ThankYou(
                      localizedValues: widget.localizedValues,
                      locale: widget.locale,
                    )),
            (Route<dynamic> route) => route.isFirst);
      }
    });
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

  buildFlavourList(List<dynamic> flavoursList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        flavoursList.length > 0
            ? Text(MyLocalizations.of(context).flavours)
            : Text(''),
        ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: flavoursList.length ?? 0,
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    flavoursList[index]['flavourName'],
                    style: titleBlackLightOSB(),
                  ),
                  Text(
                    '  X ',
                    style: titleBlackLightOSB(),
                  ),
                  Text(
                    flavoursList[index]['quantity'].toString(),
                    style: titleBlackLightOSB(),
                  ),
                ],
              );
            }),
      ],
    );
  }
}
