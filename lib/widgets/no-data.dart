import 'package:flutter/material.dart';
import '../services/localizations.dart';

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
