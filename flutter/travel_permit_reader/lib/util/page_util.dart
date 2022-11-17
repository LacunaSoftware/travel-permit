import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class AppTheme {
  static const Color primaryBgColor = Color(0xFF009BB4);
  static const Color accentBgColor = Color(0xFFE3E000);
  static const Color accentFgColor = Color(0xFFE3E3E3);
  static const Color primaryFgColor = Color(0xFF009BB4);
  static const Color defaultFgColor = Color(0xFF6F7E84);
  static const Color alertColor = Color(0xFFFF4444);
  static const Color successColor = Color(0xFF2DAB66);

  static const TextStyle headlineStyle = TextStyle(
      fontSize: 15,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w400,
      fontFamily: 'Rubik',
      color: defaultFgColor);
  static const TextStyle headline2Style =
      TextStyle(fontSize: 14, fontFamily: 'Rubik');

  static const TextStyle bodyStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: primaryBgColor,
      fontFamily: 'Rubik');
  static const TextStyle body2Sytle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: defaultFgColor,
      fontFamily: 'Rubik');

  static const TextStyle barTiteStyle = TextStyle(
    fontSize: 20,
    color: defaultFgColor,
    fontFamily: 'Rubik',
    fontWeight: FontWeight.w500,
    letterSpacing: 0.7,
  );

  static ThemeData getTheme() {
    return ThemeData(
        primaryColor: primaryBgColor,
        accentColor: accentBgColor,
        textTheme: TextTheme(
          headline1: headlineStyle,
        ));
  }
}

//-------------------------------------------------------------------

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
      barrierDismissible: false,
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

class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold(
      {this.body,
      this.color = AppTheme.primaryBgColor,
      this.imagePath,
      this.appBar});

  final Widget body;
  final Color color;
  final String imagePath;
  final AppBar appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: color,
      appBar: appBar,
      body: imagePath == null
          ? body
          : Stack(
              children: <Widget>[
                Container(
                  child: SvgPicture.asset(
                    imagePath,
                    fit: BoxFit.none,
                  ),
                ),
                this.body
              ],
            ),
    );
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

  static String formatCpf(String cpf) {
    return cpf?.length == 11
        ? '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}'
        : cpf;
  }
}

//-------------------------------------------------------------------

extension DateTimeExt on DateTime {
  String toDateString() => DateFormat('dd/MM/yyy').format(this);

  bool isAfterDateOnly(DateTime d) {
    if (this.year > d.year) {
      return true;
    } else if (this.year < d.year) {
      return false;
    }

    // same year
    if (this.month > d.month) {
      return true;
    } else if (this.month < d.month) {
      return false;
    }

    // same month
    if (this.day > d.day) {
      return true;
    } else {
      return false;
    }
  }

  bool isBeforeDateOnly(DateTime d) {
    if (this.year < d.year) {
      return true;
    } else if (this.year > d.year) {
      return false;
    }

    // same year
    if (this.month < d.month) {
      return true;
    } else if (this.month > d.month) {
      return false;
    }

    // same month
    if (this.day < d.day) {
      return true;
    } else {
      return false;
    }
  }
}

//-------------------------------------------------------------------
