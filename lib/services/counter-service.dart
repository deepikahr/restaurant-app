import 'package:RestaurantSaas/services/common.dart';
import 'package:flutter/cupertino.dart';
import 'sentry-services.dart';

SentryError sentryError = new SentryError();

class CounterService with ChangeNotifier {
  int cartCounter = 0;

  getCounter() async {
    await Common.getCart().then((onValue) {
      try {
        if (onValue != null) {
          cartCounter = onValue['productDetails'].length;
        } else {
          cartCounter = 0;
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return cartCounter;
  }

  void calculateCounter() {
    getCounter();
  }
}
