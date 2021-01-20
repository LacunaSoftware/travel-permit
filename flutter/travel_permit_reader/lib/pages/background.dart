import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold(
      {this.body, this.color, this.imagePath, this.appBar});

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
