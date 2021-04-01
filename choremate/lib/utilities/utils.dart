import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static Utils _utils;
  Utils._createInstance();

  factory Utils() {
    if (_utils == null) {
      _utils = Utils._createInstance();
    }
    return _utils;
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void showSnackBar(var scaffoldkey, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1, milliseconds: 500),
    );
    scaffoldkey.currentState.showSnackBar(snackBar);
  }
}
