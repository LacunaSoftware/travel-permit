import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:travel_permit_reader/api/cnb_client.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/pages/travel_permit_page.dart';
import 'package:travel_permit_reader/util/qrcode_data.dart';
import 'package:travel_permit_reader/pages/background.dart';
import 'package:travel_permit_reader/pages/enter_key_page.dart';
import 'package:travel_permit_reader/util/page_util.dart';
import 'package:travel_permit_reader/util/permission_util.dart';

class HomePage extends StatelessWidget {
  Future _scanQRCode(BuildContext context) async {
    final progress = ProgressHUD.of(context);

    try {
      final cameraGranted = await PermissionUtil.checkCameraPermission(
          context, 'Dê permissão de uso da câmera para ler QR code');
      if (!cameraGranted) {
        return;
      }

      final code = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', false, ScanMode.QR);

      progress.show();
      final data = QRCodeData.parse(code);

      if (!data.verify()) {
        PageUtil.showAppDialog(context, 'QR Code Recusado',
            'A assinatura do QR code está inválida.');
        return;
      }

      TravelPermitModel model;
      try {
        model = await CnbClient('https://assinatura-hml.e-notariado.org.br/')
            .getTravelPermitInfo(data.documentKey);
      } catch (ex) {
        print('Error requesting document details: $ex');
      }

      model = model ?? TravelPermitModel.fromQRCode(data);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TravelPermitPage(model)));
    } catch (ex) {
      print('Error :$ex');
    } finally {
      progress.dismiss();
    }
  }

  Future _launchEnterKey(BuildContext context) async {
    final documentKey = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterKeyPage(),
        ));
    if (StringExt.isNullOrEmpty(documentKey)) {
      return;
    }
    final progress = ProgressHUD.of(context);
    try {
      progress.show();
      final model =
          await CnbClient('https://assinatura-hml.e-notariado.org.br/')
              .getTravelPermitInfo(documentKey);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TravelPermitPage(model)));
    } catch (ex) {
      print('Error requesting document details: $ex');
      PageUtil.showAppDialog(context, 'Erro',
          'Não foi possível retornar detalhes do documento: $ex');
    } finally {
      progress.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Title Section
    Widget titleSection = Container(
      height: PageUtil.getScreenHeight(context, 0.3),
      width: PageUtil.getScreenWidth(context),
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(80.0)),
      ),
      child: Center(
          child: Text(
        "AUTORIZAÇÃO DE VIAGEM",
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: Color(0xFF007FBC),
        ),
      )),
    );

    // Validation Section
    Widget validationSection = Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                bottom: PageUtil.getScreenHeight(context, 0.01)),
            child: Center(
              child: Text(
                "VALIDAR DOCUMENTO",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  color: Color(0xFF007FBC),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(12.5),
                alignment: Alignment.centerLeft,
                child: ValidationButton(
                  icon: Icons.qr_code_scanner,
                  text: 'Ler QR code',
                  action: () => _scanQRCode(context),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12.5),
                alignment: Alignment.centerRight,
                child: ValidationButton(
                  icon: Icons.settings_ethernet,
                  text: 'Digitar Código',
                  action: () => _launchEnterKey(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return BackgroundScaffold(
      color: Color(0xFFF5F5F5),
      imageLocation: "assets/img/bg_global_grey.svg",
      imageFit: BoxFit.none,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 10,
            child: titleSection,
          ),
          Positioned(
            bottom: PageUtil.getScreenHeight(context, 0.05),
            child: validationSection,
          ),
        ],
      ),
    );
  }
}

class ValidationButton extends StatelessWidget {
  const ValidationButton({
    this.icon,
    this.text,
    this.action,
  });

  final IconData icon;
  final String text;
  final Function action;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.white,
      onPressed: this.action,
      child: Container(
        height: 135, // Considering padding value.
        width: 105,
        padding: EdgeInsets.only(top: 15, bottom: 15),
        child: Stack(
          children: <Widget>[
            Positioned(
              child: Align(
                alignment: Alignment.topCenter,
                child: Icon(
                  this.icon,
                  color: Color(0xFF007FBC),
                  size: 45.0,
                ),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  this.text,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: Color(0xFF9E9E9E),
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 5.0,
    );
  }
}

class AppBarScaffold extends StatelessWidget {
  const AppBarScaffold({
    this.body,
    this.color,
    this.imageLocation,
    this.imageFit,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final Color color;
  final String imageLocation;
  final BoxFit imageFit;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      resizeToAvoidBottomInset: this.resizeToAvoidBottomInset,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(
          '',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF007FBC),
          ),
        ),
        leading: IconButton(
          iconSize: 18.0,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF007FBC),
          ),
          tooltip: 'Voltar',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: this.body,
      color: this.color,
      imageLocation: this.imageLocation,
      imageFit: this.imageFit,
    );
  }
}
