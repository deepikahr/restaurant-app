import 'package:http/http.dart' show Client;
import 'constant.dart';
import 'dart:convert';

class MainService {
  static final Client client = Client();

  // default get all - users/list/restaurant
  static Future<dynamic> getTopRatedRestaurants() async {
    final response =
        await client.get(API_ENDPOINT + 'users/list/restaurant/rating/sorting');
    return json.decode(response.body);
  }

  static Future<dynamic> getNewlyArrivedRestaurants() async {
    final response = await client
        .get(API_ENDPOINT + 'users/list/restaurant/createdat/sorting');
    return json.decode(response.body);
  }

  static Future<dynamic> getNearByRestaurants(double lat, double long) async {
    final response =
        await client.get(API_ENDPOINT + 'locations/map/distance/$lat/$long');
    return json.decode(response.body);
  }

  static Future<dynamic> getAdvertisementList() async {
    final response =
        await client.get(API_ENDPOINT + 'locations/home/restaurant');
    return json.decode(response.body);
  }

  static Future<dynamic> getLocationsByRestaurantId(String id) async {
    final response =
        await client.get(API_ENDPOINT + 'locations/list/by/restaurant/$id');
    return json.decode(response.body);
  }

  static Future<dynamic> getProductsBylocationId(String id) async {
    final response =
        await client.get(API_ENDPOINT + 'locations/all/category/data/$id');
    return json.decode(response.body);
  }

  static Future<dynamic> getCouponsByLocationId(String id) async {
    final response = await client
        .get(API_ENDPOINT + 'coupons/validcoupon/bycurrenttimestamp/$id');
    return json.decode(response.body);
  }

  static Future<dynamic> getLoyaltyInfoByRestaurantId(String id) async {
    final response = await client.get(API_ENDPOINT + 'settings/$id');
    return json.decode(response.body);
  }
}
