import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Common {
  List<dynamic> products = List();

  static Future<bool> addProduct(List<dynamic> products) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('product', json.encode(products));
  }

  static Future<bool> addFlavours(List<dynamic> flavours) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('flavour', json.encode(flavours));
  }

  static Future<List<dynamic>> getFlavours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String products = prefs.getString("flavour");
    try {
      return json.decode(products) as List<dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  static Future<bool> setDeliveryCharge(Map<String, dynamic> products) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('deliveryCharge', json.encode(products));
  }

  static Future<List<dynamic>> getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String products = prefs.getString("product");
    try {
      return json.decode(products) as List<dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  static Future<Map<String, dynamic>> getDeliveryCharge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String products = prefs.getString("deliveryCharge");
    try {
      return json.decode(products) as Map<String, dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  // save token on storage
  static Future<bool> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('token', token);
  }

  // get token from storage
  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future(() => prefs.getString('token'));
  }

  // remove token from storage
  static Future<bool> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('token');
  }

  static Future<bool> setCurrentLocation(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('setCurrentLocationData', json.encode(data));
  }

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String info = prefs.getString('setCurrentLocationData');
    try {
      return json.decode(info) as Map<String, dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  // save cart item on storage
  static Future<bool> setCart(Map<String, dynamic> cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('cart', json.encode(cart));
  }

  static Future<bool> setGlobalSettingData(Map<String, dynamic> cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('globalSetting', json.encode(cart));
  }

  // get cart items from storage
  static Future<Map<String, dynamic>> getCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartStorage = prefs.getString('cart');
    try {
      return json.decode(cartStorage) as Map<String, dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  static Future<Map<String, dynamic>> getCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString('cart')) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getGlobalSettingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartStorage = prefs.getString('globalSetting');
    try {
      return json.decode(cartStorage) as Map<String, dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  // remove cart items from storage
  static Future<bool> removeCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('product');
    return prefs.remove('cart');
  }

  // upadate cart info on storage
  static Future<bool> setCartInfo(Map<String, dynamic> cartInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('cartInfo', json.encode(cartInfo));
  }

  // get cart info from storage
  static Future<Map<String, dynamic>> getCartInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartStorage = prefs.getString('cartInfo');
    try {
      return json.decode(cartStorage) as Map<String, dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }

  // save position info on storage
  static Future<bool> savePositionInfo(Map<String, dynamic> position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('position', json.encode(position));
  }

  // get position info on storage
  static Future<Map<String, dynamic>> getPositionInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String position = prefs.getString('position');
    try {
      return json.decode(position) as Map<String, dynamic>;
    } catch (err) {
      return Future(() => null);
    }
  }
}
