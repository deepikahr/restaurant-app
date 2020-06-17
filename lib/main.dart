import 'package:RestaurantSaas/services/auth-service.dart';
import 'package:RestaurantSaas/services/common.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'services/initialize_i18n.dart';
import 'services/localizations.dart';

import './styles/styles.dart';
import './services/constant.dart';
import 'screens/mains/home.dart';

import './services/sentry-services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/constant.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

SentryError sentryError = new SentryError();

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> localizedValues = await initializeI18n();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String locale = prefs.getString('selectedLanguage') ?? 'en';
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  tokenCheck();
  initOneSignal();

  runZoned<Future<Null>>(() async {
    runApp(new EntryPage(locale, localizedValues));
  }, onError: (error, stackTrace) async {
    await sentryError.reportError(error, stackTrace);
  });
}

void tokenCheck() {
  Common.getToken().then((tokenVerification) async {
    if (tokenVerification != null) {
      AuthService.verifyTokenOTP(tokenVerification).then((verifyInfo) async {
        if (verifyInfo['success'] == true) {} else {
          Common.removeToken().then((removeVerification) async {});
        }
      });
    }
  });
}

Future<void> initOneSignal() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  OneSignal.shared
      .setNotificationReceivedHandler((OSNotification notification) {});
  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});
  OneSignal.shared.init(ONE_SIGNAL_APP_ID, iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: true,
  });
  OneSignal.shared.setInFocusDisplayType(
    OSNotificationDisplayType.notification,
  );

  OneSignal.shared
      .promptUserForPushNotificationPermission(fallbackToSettings: true);
  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);
  var status = await OneSignal.shared.getPermissionSubscriptionState();
  String playerId = status.subscriptionStatus.userId;
  if (playerId == null) {
    initOneSignal();
  } else {
    prefs.setString("playerId", playerId);
  }
}

class EntryPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  final String locale;

  EntryPage(this.locale, this.localizedValues);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale(widget.locale),
      localizationsDelegates: [
        MyLocalizationsDelegate(widget.localizedValues),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: LANGUAGES.map((language) => Locale(language, '')),
      debugShowCheckedModeBanner: false,
      title: APP_NAME,
      theme: ThemeData(
        fontFamily: FONT_FAMILY,
        primaryColor: PRIMARY,
        accentColor: PRIMARY,
      ),
      home: HomePage(
        locale: widget.locale,
        localizedValues: widget.localizedValues,
      ),
    );
  }
}
