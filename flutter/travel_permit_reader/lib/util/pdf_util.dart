import 'dart:io';

import 'package:travel_permit_reader/util/file_util.dart';
import 'package:travel_permit_reader/api/cnb_client.dart';
import 'package:travel_permit_reader/api/models.dart';

class PdfUtil {
  TravelPermitModel model;
  File _pdf;

  CnbClient _cnbClient;
  CnbClient get cnbClient {
    return _cnbClient ??= CnbClient(model.key);
  }

  PdfUtil(this.model);

  Future<String> getTravelPermitPdfPrivate() async {
    if (_pdf == null || !await _pdf.exists())
      _pdf = await getTravelPermitPdf(true);

    return _pdf?.path;
  }

  Future<String> getTravelPermitPdfPublic() async {
    _pdf = await (_pdf == null || !await _pdf.exists()
        ? getTravelPermitPdf(false)
        : FileUtil.moveToPublic(_pdf));

    return _pdf?.path;
  }

  Future<File> getTravelPermitPdf(bool isTemp) async => model.isOffline
      ? generateTravelPermitOffline(isTemp)
      : FileUtil.downloadFile(await cnbClient.getTravelPermitPdfRequest(),
          "Autorização de Viagem - ${model.key}.pdf", isTemp);

  generateTravelPermitOffline(bool isTemp) {}
}
