import 'package:RestaurantSaas/services/common.dart';
import 'package:flutter/cupertino.dart';
import '../../services/sentry-services.dart';

SentryError sentryError = new SentryError();

class CounterModel with ChangeNotifier {
  int cartCounter = 0;

  getCounter() async {
    await Common.getCart().then((onValue) {
      try{
        if (onValue != null) {
          cartCounter = onValue['productDetails'].length;
          // print(cartCounter);
        } else {
          cartCounter = 0;
        }
      }
      catch (error, stackTrace) {
      sentryError.reportError(error, stackTrace);
      }
    }).catchError((onError) {
      sentryError.reportError(onError, null);
    });
    return cartCounter;
  }

  void calculateCounter() {
    getCounter();
    notifyListeners();
  }
}
