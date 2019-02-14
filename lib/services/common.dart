import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Common {
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

  // save cart item on storage
  static Future<bool> setCart(Map<String, dynamic> cart) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('cart', json.encode(cart));
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

  // remove cart items from storage
  static Future<bool> removeCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
