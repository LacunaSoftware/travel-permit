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
    final url = path.join(
        _host.toString(), 'api/documents/keys/$documentKey/travel-permit');

    final response = await http.get(url);

    if (response.statusCode == 404) {
      throw TPException('No document found for key: $documentKey',
          TPErrorCodes.documentNotFound);
    } else if (response.statusCode != 200) {
      throw TPException(
          'CnbClient response for key $documentKey: (${response.statusCode}) ${response.reasonPhrase}',
          TPErrorCodes.cnbClientRequestError);
    }

    try {
      final jsonMap = json.decode(response.body);
      return TravelPermitModel.fromJson(documentKey, jsonMap);
    } catch (ex) {
      throw TPException(
          'Error decoding client json response for key $documentKey: $ex',
          TPErrorCodes.cnbClientDecodeResponseError);
    }
  }
}
