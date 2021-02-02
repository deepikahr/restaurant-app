import 'package:RestaurantSaas/styles/styles.dart';
import 'package:flutter/material.dart';

Widget buildPrimaryHalfWidthButton(
    BuildContext context, title, isLoading, onPressed) {
  return Container(
    width: MediaQuery.of(context).size.width / 2,
    height: 41,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
        ]),
    child: RaisedButton(
      color: primary,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: textMuliSemiboldwhite(),
          ),
          Padding(padding: EdgeInsets.only(left: 5.0, right: 5.0)),
          isLoading
              ? Image.asset(
                  'lib/assets/icon/spinner.gif',
                  width: 19.0,
                  height: 19.0,
                )
              : Text(''),
        ],
      ),
    ),
  );
}
