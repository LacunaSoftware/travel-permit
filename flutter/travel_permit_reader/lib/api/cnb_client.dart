import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/tp_exception.dart';

class CnbClient {
  String _host;

  CnbClient(String host) {
    _host = host;
  }

  Future<TravelPermitModel> getTravelPermitInfo(String documentKey) async {
    try {
      final url = path.join(
          _host.toString(), 'api/documents/keys/$documentKey/travel-permit');

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
            'CnbClient response for key $documentKey: (${response.statusCode}) ${response.reasonPhrase}',
            TPErrorCodes.cnbClientRequestError);
      }

      return TravelPermitModel.fromJson(
          documentKey, json.decode(response.body));
    } catch (ex) {
      ex is TPException
          ? throw ex
          : throw TPException(
              'Error decoding client json response for key $documentKey: $ex',
              TPErrorCodes.cnbClientRequestError);
    }
  }
}
