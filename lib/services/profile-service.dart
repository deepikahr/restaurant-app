import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'common.dart';
import 'constant.dart';
import 'sentry-services.dart';

SentryError sentryError = new SentryError();

class ProfileService {
  static final Client client = Client();

  static Future<bool> validateToken() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'users/verify/token',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(API_ENDPOINT + 'users/me',
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteUserProfilePic() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.delete(API_ENDPOINT + 'users/profile/delete',
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

  static Future<Map<String, dynamic>> setUserProfileInfo(
      String id, Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.put(API_ENDPOINT + 'users/userProfile/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> uploadProfileImage(
      image, stream, id) async {
    var length = await image.length();
    String uri = API_ENDPOINT + 'users/upload/to/cloud';
    var request = new http.MultipartRequest("POST", Uri.parse(uri));
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(image.path));
    request.files.add(multipartFile);
    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      var profileImageRes;
      if (value.substring(value.length - 1, value.length) == "}") {
        profileImageRes = value;
      } else {
        profileImageRes = value + "}";
      }

      if (value.length > 3) {
        var profileValue = json.decode(profileImageRes);
        // prefs.setString("logo", profileValue['url']);
        ProfileService.setUserProfileInfo(id, {
          'publicId': profileValue['public_id'],
          'logo': profileValue['url']
        }).then((dmdkc) {});
      }
    });
    return null;
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

  static Future<Map<String, dynamic>> deleteAddress(index) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.delete(
      API_ENDPOINT + 'users/address/$index',
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

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

  static Future<List<dynamic>> getCardList() async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.get(
      API_ENDPOINT + 'carddetails/list/byuser',
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> placeOrderForCreditCard(
      Map<String, dynamic> body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.post(API_ENDPOINT + 'carddetails/payment/',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> addCard(body) async {
    String token;
    await Common.getToken().then((onValue) {
      token = 'bearer ' + onValue;
    });
    final response = await client.post(API_ENDPOINT + 'carddetails',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: json.encode(body));
    return json.decode(response.body);
  }
}
