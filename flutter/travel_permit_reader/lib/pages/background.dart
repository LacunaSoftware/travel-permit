import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold({
    this.body,
    this.color,
    this.imageLocation,
    this.imageFit,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final Color color;
  final String imageLocation;
  final BoxFit imageFit;
  final Widget appBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: this.resizeToAvoidBottomInset,
      backgroundColor: this.color,
      appBar: this.appBar,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: <Widget>[
            Container(
              child: SvgPicture.asset(
                this.imageLocation,
                fit: this.imageFit,
              ),
            ),
            this.body
          ],
        ),
      ),
    );
  }
}
