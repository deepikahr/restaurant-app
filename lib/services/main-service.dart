import 'dart:async';
import 'dart:convert';

import 'package:RestaurantSaas/services/common.dart';
import 'package:http/http.dart' show Client;

import 'constant.dart';

class MainService {
  static final Client client = Client();

  // default get all - users/list/restaurant
  static Future<dynamic> getTopRatedRestaurants(
      {String count, double lat, double long}) async {
    if (count == null) count = 'All';
    final response = await client
        .get(API_ENDPOINT + 'locations/toprated/all/list/$lat/$long');
    return json.decode(response.body);
  }

  static Future<dynamic> getNewlyArrivedRestaurants(
      {String count, double lat, double long}) async {
    if (count == null) count = 'All';
    final response = await client
        .get(API_ENDPOINT + 'locations/newlyadded/all/list/$lat/$long');
    return json.decode(response.body);
  }

  static Future<dynamic> getNearByRestaurants(double lat, double long,
      {String count}) async {
    if (count == null) count = 'All';
    final response = await client
        .get(API_ENDPOINT + 'locations/map/distance/$lat/$long/$count');
    return json.decode(response.body);
  }

  static Future<dynamic> getAdvertisementList() async {
    final response =
        await client.get(API_ENDPOINT + 'locations/home/restaurant');
    return json.decode(response.body);
  }

//  static Future<dynamic> getLocationsByRestaurantId(String id) async {
//    final response =
//        await client.get(API_ENDPOINT + 'locations/list/by/restaurant/$id');
//    return json.decode(response.body);
//  }

  static Future<dynamic> getProductsBylocationId(String id) async {
    final response =
        await client.get(API_ENDPOINT + 'locations/all/category/data/$id');
    return json.decode(response.body);
  }

  static Future<dynamic> getWorkingHours(String locationId) async {
    final response = await client
        .get(API_ENDPOINT + 'locations/get-working/hours/$locationId');
    return json.decode(response.body);
  }

  static Future<dynamic> getCouponsByLocationId(String id) async {
    final response = await client
        .get(API_ENDPOINT + 'coupons/validcoupon/bycurrenttimestamp/$id');
    return json.decode(response.body);
  }

//  static Future<dynamic> getLoyaltyInfoByRestaurantId(String id) async {
//    final response = await client.get(API_ENDPOINT + 'settings/$id');
//    return json.decode(response.body);
//  }

  static Future<dynamic> getRestaurantOpenAndCloseTime(
      String id, String time, String day) async {
    final response = await client
        .get(API_ENDPOINT + 'locations/timing/verify/$id/$time/$day');
    return json.decode(response.body);
  }

  static Future<dynamic> getTodayAndOtherDaysWorkingTimimgs(
      String id, String day, String time, String todayDay) async {
    final response = await client
        .get(API_ENDPOINT + 'locations/timing/slot/$id/$day/$time/$todayDay');

    return json.decode(response.body);
  }

  static Future<dynamic> getAdminSettings() async {
    final response = await client.get(API_ENDPOINT + 'adminSettings/');
    Common.setGlobalSettingData(json.decode(response.body));
    return json.decode(response.body);
  }

//  static Future<Map<String, dynamic>> getEcoDeliveryInfo(id) async {
//    String token;
//    await Common.getToken().then((onValue) {
//      token = 'bearer ' + onValue;
//    });
//    final response = await client.get(
//        API_ENDPOINT + 'users/res-ecoDelivery/setting/$id',
//        headers: {'Content-Type': 'application/json', 'Authorization': token});
//    return json.decode(response.body);
//  }
}
