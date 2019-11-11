import 'dart:async' show Future;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'constant.dart' show languages;

class MyLocalizations {
  final Map<String, Map<String, String>> localizedValues;
  MyLocalizations(this.locale, this.localizedValues);

  final Locale locale;

  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  String get hello {
    return localizedValues[locale.languageCode]['hello'];
  }

  String get home {
    return localizedValues[locale.languageCode]['home'];
  }

  String get cart {
    return localizedValues[locale.languageCode]['cart'];
  }

  String get myOrders {
    return localizedValues[locale.languageCode]['myOrders'];
  }

  String get favourites {
    return localizedValues[locale.languageCode]['favourites'];
  }

  String get profile {
    return localizedValues[locale.languageCode]['profile'];
  }

  String get aboutUs {
    return localizedValues[locale.languageCode]['aboutUs'];
  }

  String get login {
    return localizedValues[locale.languageCode]['login'];
  }

  String get logout {
    return localizedValues[locale.languageCode]['logout'];
  }

  String get restaurantsNearYou {
    return localizedValues[locale.languageCode]['restaurantsNearYou'];
  }

  String get topRatedRestaurants {
    return localizedValues[locale.languageCode]['topRatedRestaurants'];
  }

  String get newlyArrivedRestaurants {
    return localizedValues[locale.languageCode]['newlyArrivedRestaurants'];
  }

  String get viewAll {
    return localizedValues[locale.languageCode]['viewAll'];
  }

  String get reviews {
    return localizedValues[locale.languageCode]['reviews'];
  }

  String get branches {
    return localizedValues[locale.languageCode]['branches'];
  }

  String get selectLanguages {
    return localizedValues[locale.languageCode]['selectLanguages'];
  }

  String get shortDescription {
    return localizedValues[locale.languageCode]['shortDescription'];
  }

  String get emailId {
    return localizedValues[locale.languageCode]['emailId'];
  }

  String get fullName {
    return localizedValues[locale.languageCode]['fullName'];
  }
  String get mobileNumber {
    return localizedValues[locale.languageCode]['mobileNumber'];
  }
  String get subUrban {
    return localizedValues[locale.languageCode]['subUrban'];
  }
  String get state {
    return localizedValues[locale.languageCode]['state'];
  }
  String get country {
    return localizedValues[locale.languageCode]['country'];
  }
  String get postalCode {
    return localizedValues[locale.languageCode]['postalCode'];
  }
  String get address {
    return localizedValues[locale.languageCode]['address'];
  }
  String get cancel {
    return localizedValues[locale.languageCode]['cancel'];
  }
  String get save {
    return localizedValues[locale.languageCode]['save'];
  }

  String get yourEmail {
    return localizedValues[locale.languageCode]['yourEmail'];
  }
  String get yourPassword {
    return localizedValues[locale.languageCode]['yourPassword'];
  }
  String get loginToYourAccount {
    return localizedValues[locale.languageCode]['loginToYourAccount'];
  }
  String get forgotPassword {
    return localizedValues[locale.languageCode]['forgotPassword'];
  }
  String get dontHaveAccountYet {
    return localizedValues[locale.languageCode]['dontHaveAccountYet'];
  }
  String get signInNow {
    return localizedValues[locale.languageCode]['signInNow'];
  }
  String get pleaseEnterValidEmail {
    return localizedValues[locale.languageCode]['pleaseEnterValidEmail'];
  }
  String get pleaseEnterValidPassword {
    return localizedValues[locale.languageCode]['pleaseEnterValidPassword'];
  }
  String get pleaseEnterValidName {
    return localizedValues[locale.languageCode]['pleaseEnterValidName'];
  }
  String get pleaseEnterValidMobileNumber {
    return localizedValues[locale.languageCode]['pleaseEnterValidMobileNumber'];
  }
  String get loginSuccessful {
    return localizedValues[locale.languageCode]['loginSuccessful'];
  }
  String get password {
    return localizedValues[locale.languageCode]['password'];
  }
  String get acceptTerms {
    return localizedValues[locale.languageCode]['acceptTerms'];
  }
  String get registerNow {
    return localizedValues[locale.languageCode]['registerNow'];
  }
  String get register {
    return localizedValues[locale.languageCode]['register'];
  }
  String get resetPassword {
    return localizedValues[locale.languageCode]['resetPassword'];
  }
  String get resetPasswordOtp {
    return localizedValues[locale.languageCode]['resetPasswordOtp'];
  }
  String get resetMessage {
    return localizedValues[locale.languageCode]['resetMessage'];
  }
  String get verifyOtp {
    return localizedValues[locale.languageCode]['verifyOtp'];
  }
  String get otpErrorMessage {
    return localizedValues[locale.languageCode]['otpErrorMessage'];
  }
  String get otpMessage {
    return localizedValues[locale.languageCode]['otpMessage'];
  }
  String get createPassword {
    return localizedValues[locale.languageCode]['createPassword'];
  }
  String get createPasswordMessage {
    return localizedValues[locale.languageCode]['createPasswordMessage'];
  }


  greetTo(name) {
    return localizedValues[locale.languageCode]['greetTo']
        .replaceAll('{{name}}', name);
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  Map<String, Map<String, String>> localizedValues;

  MyLocalizationsDelegate(this.localizedValues);

  @override
  bool isSupported(Locale locale) => languages.contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(
        MyLocalizations(locale, localizedValues));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
