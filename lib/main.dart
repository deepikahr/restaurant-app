import 'package:RestaurantSaas/screens/other/CounterModel.dart';

import 'package:flutter/material.dart';
import './styles/styles.dart';
import './services/constant.dart';
import 'screens/mains/home.dart';
// import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:onesignal/onesignal.dart';
import 'package:provider/provider.dart';
import './services/sentry-services.dart';
import 'dart:async';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

SentryError sentryError = new SentryError();

main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    runApp(new EntryPage());
  }, onError: (error, stackTrace) async {
    await sentryError.reportError(error, stackTrace);
  });
}

void initOneSignal() {
  OneSignal.shared.init(ONE_SIGNAL_APP_ID, iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: true
  });
  OneSignal.shared.setInFocusDisplayType(
    OSNotificationDisplayType.notification,
  );
}

class EntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: APP_NAME,
        theme: ThemeData(
          fontFamily: FONT_FAMILY,
          primaryColor: PRIMARY,
          accentColor: PRIMARY,
        ),
        home: ChangeNotifierProvider<CounterModel>(
            builder: (_) => CounterModel(), child: HomePage()));
  }
}
