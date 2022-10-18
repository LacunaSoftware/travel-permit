import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
    if (_pdf == null || !await _pdf.exists()) {
      _pdf = await FileUtil.askForPermissions()
          ? await getTravelPermitPdf(false)
          : null;
    } else {
      _pdf = await FileUtil.moveToPublic(_pdf);
    }

    return _pdf?.path;
  }

  Future<File> getTravelPermitPdf(bool isTemp) async => model.isOffline
      ? generateTravelPermitOffline(isTemp)
      : FileUtil.createFromResponse(await cnbClient.getTravelPermitPdfRequest(),
          "Autorização de Viagem - ${model.key}.pdf", isTemp);

  Future<File> generateTravelPermitOffline(bool isTemp) async {
    final pdf = pw.Document();

    // TODO: Create PDF itself

    // TODO: Generate file name
    String pdfName;

    // Save to file and return
    return FileUtil.createFromBytes(pdf.save(), pdfName, isTemp);
  }
}
