import 'package:http/http.dart' show Client;
import 'constant.dart';
import 'dart:convert';

class AuthService {
  static final Client client = Client();

  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final response = await client.post(BASE_URL + 'auth/local', body: body);
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> body) async {
    final response = await client.post(API_ENDPOINT + 'users', body: body);
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> sendOTP(Map<String, dynamic> body) async {
    final response =
        await client.post(API_ENDPOINT + 'users/password/otp', body: body);
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> verifyOTP(
      Map<String, dynamic> body, String token) async {
    final response = await client.post(
        API_ENDPOINT + 'users/password/verification',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + token
        },
        body: json.encode(body));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> createNewPassword(
      Map<String, dynamic> body, String token) async {
    final response = await client.post(API_ENDPOINT + 'users/password/reset',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + token
        },
        body: json.encode(body));
    return json.decode(response.body);
  }
}
