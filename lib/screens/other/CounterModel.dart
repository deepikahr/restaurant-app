import 'package:RestaurantSass/services/common.dart';
import 'package:flutter/cupertino.dart';

class CounterModel with ChangeNotifier {
  int cartCounter = 0;

  getCounter() async {
    await Common.getCart().then((onValue) {
      if (onValue != null) {
        cartCounter = onValue['productDetails'].length;
        // print(cartCounter);
      } else {
        cartCounter = 0;
      }
    });
    return cartCounter;
  }

  void calculateCounter() {
    getCounter();
    notifyListeners();
  }
}
