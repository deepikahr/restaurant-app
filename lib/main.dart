import 'package:RestaurantSaas/screens/other/CounterModel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'initialize_i18n.dart' show initializeI18n;
import 'constant.dart' show languages;
import 'localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

import './styles/styles.dart';
import './services/constant.dart';
import 'screens/mains/home.dart';
// import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:onesignal/onesignal.dart';
import 'package:provider/provider.dart';
import './services/sentry-services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

SentryError sentryError = new SentryError();

main() async {
  Map<String, Map<String, String>> localizedValues = await initializeI18n();
  String _locale = 'en';
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    runApp(new EntryPage(_locale, localizedValues,));
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


class EntryPage extends StatefulWidget {
  final Map<String, Map<String, String>> localizedValues;
  var locale;
  EntryPage(this.locale, this.localizedValues);
  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {

  @override
  void initState() {
    super.initState();
    getData();
  }

  var selectedLanguage;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage');
    });
    print('selectedLanguage............$selectedLanguage ${widget.localizedValues}');
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        locale: Locale(selectedLanguage == null ? widget.locale : selectedLanguage),
        localizationsDelegates: [
          MyLocalizationsDelegate(widget.localizedValues),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: languages.map((language) => Locale(language, '')),
        debugShowCheckedModeBanner: false,
        title: APP_NAME,
        theme: ThemeData(
          fontFamily: FONT_FAMILY,
          primaryColor: PRIMARY,
          accentColor: PRIMARY,
        ),
        home: ChangeNotifierProvider<CounterModel>(
            builder: (_) => CounterModel(),
            child: HomePage(
                locale:selectedLanguage == null ? widget.locale : selectedLanguage,
                localizedValues: widget.localizedValues
            )
        )
    );
  }
}
