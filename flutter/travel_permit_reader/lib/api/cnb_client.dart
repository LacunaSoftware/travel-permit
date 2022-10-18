import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/tp_exception.dart';
import 'package:travel_permit_reader/util/file_util.dart';

class CnbClient {
  static final String _host = 'https://assinatura.e-notariado.org.br/';

  String _documentKey;
  File _pdf;

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

  Future<http.Response> getTravelPermitPdfRequest() async {
    final ticketResponse = await getFrom(
        'api/documents/keys/$_documentKey/ticket?type=Signatures');
    final downloadEndpoint =
        json.decode(ticketResponse.body)['location'].substring(1);
    return await getFrom(downloadEndpoint);
  }

  Future<String> getTravelPermitPdfPrivate() async {
    if (_pdf == null || !await _pdf.exists())
      _pdf = await FileUtil.downloadFile(await getTravelPermitPdfRequest(),
          "Autorização de Viagem - $_documentKey.pdf");

    return _pdf?.path;
  }

  Future<String> getTravelPermitPdfPublic() async {
    _pdf = await (_pdf == null || !await _pdf.exists()
        ? FileUtil.downloadFile(await getTravelPermitPdfRequest(),
            "Autorização de Viagem - $_documentKey.pdf",
            public: true)
        : FileUtil.moveToPublic(_pdf));

    return _pdf?.path;
  }
}
