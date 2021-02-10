import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:travel_permit_reader/api/cnb_client.dart';
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/pages/travel_permit_page.dart';
import 'package:travel_permit_reader/tp_exception.dart';
import 'package:travel_permit_reader/util/qrcode_data.dart';
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

      TravelPermitModel travelPermitModel;
      try {
        travelPermitModel =
            await CnbClient('https://assinatura-hml.e-notariado.org.br/')
                .getTravelPermitInfo(data.documentKey);
      } on TPException catch (ex) {
        progress.dismiss();
        if (!await _handleError(context, ex)) {
          return;
        }
        progress.show();
      }

      travelPermitModel =
          travelPermitModel ?? TravelPermitModel.fromQRCode(data);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TravelPermitPage(travelPermitModel)));
      progress.dismiss();
    } catch (ex) {
      progress.dismiss();
      _handleError(context, ex);
    }
  }

  Future _launchEnterKey(BuildContext context) async {
    final progress = ProgressHUD.of(context);
    try {
      final documentKey = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterKeyPage(),
          ));

      if (StringExt.isNullOrEmpty(documentKey)) {
        return;
      }

      progress.show();
      final model =
          await CnbClient('https://assinatura-hml.e-notariado.org.br/')
              .getTravelPermitInfo(documentKey);

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TravelPermitPage(model)));
      progress.dismiss();
    } catch (ex) {
      progress.dismiss();
      _handleError(context, ex);
    }
  }

  Future<bool> _handleError(context, Exception ex) async {
    print('Error: $ex');

    final completer = Completer<bool>();
    var message = '$ex';
    var title = 'Erro Inesperado';
    var btText = 'Ok';
    var onPressed = () => completer.complete(true);

    if (ex is TPException) {
      title = 'Erro';
      switch (ex.code) {
        case TPErrorCodes.cnbClientDecodeResponseError:
          message = 'Erro ao ler resposta do servidor';
          break;
        case TPErrorCodes.cnbClientRequestError:
          title = 'Aviso';
          message =
              'Não foi possível se comunicar com o servidor. Por favor verifique sua conexão.';
          break;
        case TPErrorCodes.cnbClientResponseError:
          message = ex.message;
          break;
        case TPErrorCodes.documentNotFound:
          message = 'Autorização de viagem não encontrada';
          break;
        case TPErrorCodes.qrCodeDecodeError:
          message =
              'Houve um problema ao decodificar o QR Code. Por favor tente digitar o código de validação';
          break;
        case TPErrorCodes.qrCodeUnknownFormat:
          message = 'Este não é um QR Code de Autorização Eletrônica de Viagem';
          break;
        case TPErrorCodes.qrCodeUnknownVersion:
          title = 'Atualização Necessária';
          message = 'Por favor atualize o App para a última versão.';
          btText = 'Atualizar';
          onPressed = () {
            completer.complete(false);
            StoreRedirect.redirect();
          };
          break;
        default:
          break;
      }
    }

    PageUtil.showAppDialog(context, title, message,
        positiveButton: ButtonAction(btText, onPressed));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      color: Color(0xFFF5F5F5),
      imagePath: "assets/img/bg_global_grey.svg",
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 10,
            // Title Section ------------------------------
            child: Container(
              height: PageUtil.getScreenHeight(context, 0.3),
              width: PageUtil.getScreenWidth(context),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(80.0)),
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
            ),
          ),
          Positioned(
            bottom: PageUtil.getScreenHeight(context, 0.15),
            left: 0, right: 0,
            // Validation Buttons Section ------------------------------
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        "VALIDAR DOCUMENTO",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.7,
                          color: Color(0xFF007FBC),
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ValidationButton(
                        icon: Icons.qr_code_scanner,
                        text: 'Ler QR code',
                        action: () => _scanQRCode(context),
                      ),
                      ValidationButton(
                        icon: Icons.settings_ethernet,
                        text: 'Digitar Código',
                        action: () => _launchEnterKey(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
        height: 135,
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
