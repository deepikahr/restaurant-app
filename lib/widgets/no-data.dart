import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:RestaurantSaas/initialize_i18n.dart' show initializeI18n;
import 'package:RestaurantSaas/constant.dart' show languages;
import 'package:RestaurantSaas/localizations.dart'
    show MyLocalizations, MyLocalizationsDelegate;

class NoData extends StatelessWidget {
  final String message;
  final IconData icon;

  NoData({Key key, this.message, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildIcon(icon),
          _buildText(message, context),
        ],
      ),
    );
  }

  Widget _buildIcon(icon) {
    return Icon(
      icon ?? Icons.assignment_late,
      size: 180.0,
      color: Colors.grey[300],
    );
  }

  Widget _buildText(message, context) {
    return Text(
      message ?? MyLocalizations.of(context).noResource,
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.grey[500],
      ),
    );
  }
}
