import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PageUtil {
  static double getScreenWidth(BuildContext context,
      [double percentage = 1.0]) {
    return MediaQuery.of(context).size.width * percentage;
  }

  static double getScreenHeight(BuildContext context,
      [double percentage = 1.0]) {
    return MediaQuery.of(context).size.height * percentage;
  }

  static void showAppDialog(BuildContext context, String title, String message,
      {ButtonAction positiveButton, ButtonAction negativeButton}) {
    final actions = List<Widget>();
    actions.add(_buildButton(context, positiveButton, 'OK'));

    if (negativeButton != null) {
      actions.add(_buildButton(context, negativeButton, 'Cancel'));
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: actions,
        );
      },
    );
  }

  static FlatButton _buildButton(
      BuildContext context, ButtonAction bt, String defaultText) {
    return FlatButton(
        child: Text(bt?.text ?? defaultText),
        onPressed: () {
          Navigator.of(context).pop();
          if (bt?.onPressed != null) {
            bt.onPressed();
          }
        });
  }
}

//-------------------------------------------------------------------

class ButtonAction {
  final String text;
  final Function onPressed;
  const ButtonAction(this.text, [this.onPressed]);
}

//-------------------------------------------------------------------

extension StringExt on String {
  static bool isNullOrEmpty(String str) {
    return str == null || str == "";
  }
}

//-------------------------------------------------------------------

extension DateTimeExt on DateTime {
  String toDateString() => DateFormat('dd/MM/yyy').format(this);
}

//-------------------------------------------------------------------
