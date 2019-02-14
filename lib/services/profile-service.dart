import 'package:http/http.dart' show Client;
import 'constant.dart';
import 'dart:convert';
import 'common.dart';

class ProfileService {
  static final Client client = Client();

  static Future<Map<String, dynamic>> getUserInfo() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'users/me',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> setUserInfo(
      String id, Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.put(API_ENDPOINT + 'users/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> uploadProfileImage(
      Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.post(
      API_ENDPOINT + 'users/upload/to/cloud',
      body: json.encode(body),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getAddressList() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'users/newaddress/address',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addAddress(
      Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.post(API_ENDPOINT + 'users/add/address',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> placeOrder(
      Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.post(API_ENDPOINT + 'orders',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getOrderById(String id) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'orders/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getNonDeliveredOrdersList() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'orders/userorder/pending',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token
        }).catchError((onError) {});
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getDeliveredOrdersList() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'orders/userorder/history',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getFavouritList() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'favourites',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<bool> removeFavouritById(String id) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    await client.delete(API_ENDPOINT + 'favourites/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return Future(() => true);
  }

  static Future<Map<String, dynamic>> checkFavourite(String productId) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    Map<String, dynamic> body = {'product': productId};
    final response = await client.post(
        API_ENDPOINT + 'favourites/check/product',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addToFavourite(
      String productId, String restaurantId, String locationId) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    Map<String, dynamic> body = {
      'product': productId,
      'restaurantID': restaurantId,
      'location': locationId
    };
    var response;
    await client
        .post(API_ENDPOINT + 'favourites',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': token
            },
            body: json.encode(body))
        .then((onValue) {
      response = onValue;
    }).catchError((onError) {
      response = onError;
    });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> postProductRating(
      Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.post(API_ENDPOINT + 'productRatings',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }
}
