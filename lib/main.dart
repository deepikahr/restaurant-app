import 'package:flutter/material.dart';
import './styles/styles.dart';
import './services/constant.dart';
import 'screens/mains/home.dart';
// import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:onesignal/onesignal.dart';

void main() {
  // Stetho.initialize();
  runApp(EntryPage());
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
        home: HomePage());
  }
}
