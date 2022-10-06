import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/tp_exception.dart';
import 'package:travel_permit_reader/util/file_util.dart';

class CnbClient {
  static final String _host = 'https://assinatura.e-notariado.org.br/';

  String _documentKey;

  CnbClient(String documentKey) {
    _documentKey = documentKey;
  }

  Future<http.Response> getFrom(String endpoint) async {
    try {
      final url = path.join(_host, endpoint);

      final response = await http.get(url);

      if (response.statusCode == 422) {
        final error = CnbErrorModel.fromJson(json.decode(response.body));
        error == null
            ? throw TPException('Error decoding 422 response',
                TPErrorCodes.cnbClientDecodeResponseError)
            : throw TPException(
                error.message, TPErrorCodes.cnbClientResponseError);
      } else if (response.statusCode != 200) {
        throw TPException(
            'CnbClient response for key $_documentKey: (${response.statusCode}) ${response.reasonPhrase}',
            TPErrorCodes.cnbClientRequestError);
      }

      return response;
    } catch (ex) {
      ex is TPException
          ? throw ex
          : throw TPException(
              'Error decoding client json response for key $_documentKey: $ex',
              TPErrorCodes.cnbClientRequestError);
    }
  }

  Future<TravelPermitModel> getTravelPermitInfo() async {
    final response =
        await getFrom('api/documents/keys/$_documentKey/travel-permit');
    return TravelPermitModel.fromJson(_documentKey, json.decode(response.body));
  }

  Future<Uint8List> getTravelPermitPdfBytes() async {
    final ticketResponse = await getFrom(
        'api/documents/keys/$_documentKey/ticket?type=Signatures');
    final downloadEndpoint =
        json.decode(ticketResponse.body)['location'].substring(1);
    final finalPdf = await getFrom(downloadEndpoint);
    return finalPdf.bodyBytes;
  }

  Future<String> getTravelPermitPdfShare() async {
    final file = await FileUtil.writeFile(
        getTravelPermitPdfBytes, 'Autorização de Viagem - $_documentKey.pdf');
    return file.path;
  }

  Future getTravelPermitPdfDownload() async {
    // TODO
  }
}
