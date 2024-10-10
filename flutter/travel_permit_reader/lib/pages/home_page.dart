import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_svg/svg.dart';
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
      final cameraGranted = await PermissionUtil.checkCameraPermission(context, 'Dê permissão de uso da câmera para ler QR code');
      if (!cameraGranted) {
        return;
      }

      final code = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancelar', false, ScanMode.QR);

      // '-1' is returned when cancelled. Check null or empty just in case
      if (StringExt.isNullOrEmpty(code) || code == '-1') {
        return;
      }

      progress?.show();
      final data = QRCodeData.parse(code);

      if (!data.verify()) {
        PageUtil.showAppDialog(context, 'QR Code Recusado', 'A assinatura do QR code está inválida.');
        progress?.dismiss();
        return;
      }

      TravelPermitValidationInfo? travelPermitModel;
      dynamic requestException;
      try {
        travelPermitModel = await CnbClient().getTravelPermitInfo(data.documentKey);
      } catch (ex) {
        requestException = ex;
      }

      travelPermitModel = travelPermitModel ?? TravelPermitValidationInfo.fromQRCode(data);

      await Navigator.push(context, MaterialPageRoute(builder: (context) => TravelPermitPage(travelPermitModel!.travelPermit, travelPermitModel.judiciaryTravelPermit, onlineRequestException: requestException)));

      progress?.dismiss();
    } catch (ex) {
      progress?.dismiss();
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

      progress?.show();
      final model = await CnbClient().getTravelPermitInfo(documentKey);

      await Navigator.push(context, MaterialPageRoute(builder: (context) => TravelPermitPage(model.travelPermit, model.judiciaryTravelPermit)));
      progress?.dismiss();
    } catch (ex) {
      progress?.dismiss();
      _handleError(context, ex);
    }
  }

  Future<bool> _handleError(context, dynamic ex) async {
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
          message = 'Não foi possível se comunicar com o servidor. Por favor verifique sua conexão.';
          break;
        case TPErrorCodes.cnbClientResponseError:
          message = ex.message;
          break;
        case TPErrorCodes.documentNotFound:
          message = 'Autorização de viagem não encontrada';
          break;
        case TPErrorCodes.qrCodeDecodeError:
          message = 'Houve um problema ao decodificar o QR Code. Por favor tente digitar o código de validação';
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

    PageUtil.showAppDialog(context, title, message, positiveButton: ButtonAction(btText, onPressed));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      color: AppTheme.primaryBgColor,
      body: Column(
        children: <Widget>[
          Container(
              height: PageUtil.getScreenHeight(context, 0.20),
              // CNB logo ------------------------------
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                Container(
                    height: PageUtil.getScreenHeight(context, 0.10),
                    width: PageUtil.getScreenWidth(context),
                    child: SvgPicture.asset(
                      "assets/img/CNBLogo.svg",
                    )),
                Container(
                  height: PageUtil.getScreenHeight(context, 0.03),
                ),
              ])),
          Container(
            height: PageUtil.getScreenHeight(context, 0.80),
            width: PageUtil.getScreenWidth(context),
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(80.0)),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  // AEV logo ------------------------------
                  child: Column(
                    children: [
                      Container(
                          height: PageUtil.getScreenHeight(context, 0.22),
                          width: PageUtil.getScreenWidth(context),
                          child: SvgPicture.asset(
                            "assets/img/AEVFooter.svg",
                          )),
                    ],
                  ),
                ),
                // Action buttons ------------------------------
                Column(
                  children: <Widget>[
                    Container(
                      height: PageUtil.getScreenHeight(context, 0.08),
                    ),
                    // Footer illustration ------------------------------
                    Container(
                        height: PageUtil.getScreenHeight(context, 0.13),
                        child: SvgPicture.asset(
                          "assets/img/AEVLogo.svg",
                        )),
                    Container(
                      height: PageUtil.getScreenHeight(context, 0.07),
                    ),
                    Container(
                      height: PageUtil.getScreenHeight(context, 0.22),
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ValidationButton(
                            icon: Icons.qr_code_scanner,
                            text: 'Ler QR code',
                            action: () => _scanQRCode(context),
                          ),
                          ValidationButton(
                            icon: Icons.keyboard,
                            text: 'Digitar Código',
                            action: () => _launchEnterKey(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: PageUtil.getScreenHeight(context, 0.07),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ValidationButton extends StatelessWidget {
  const ValidationButton({
    required this.icon,
    required this.text,
    this.action,
  });

  final IconData icon;
  final String text;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: this.action,
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        height: 112,
        width: PageUtil.getScreenWidth(context, 0.32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: Icon(
                  this.icon,
                  color: Color(0xFF6F7E84),
                  size: 40.0,
                ),
              ),
            ),
            Container(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  this.text,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: AppTheme.primaryBgColor,
                  ),
                  textAlign: TextAlign.left,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFFE3E3E3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}
