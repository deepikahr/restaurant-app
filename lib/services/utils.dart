import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  // ignore: deprecated_member_use
  return double.parse(s, (e) => null) != null;
}

launchURL(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
