import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:travel_permit_reader/api/models.dart';
import 'package:travel_permit_reader/tp_exception.dart';

class CnbClient {
  // static final String _host = 'https://assinatura.e-notariado.org.br/'; // PRODUCTION
  static final String _host = 'https://assinatura-hml.e-notariado.org.br'; // HOMOLOGATION

  Future<dynamic> tryCatchMethod(String documentKey, dynamic Function() toWrap) async {
    try {
      return await toWrap();
    } catch (ex) {
      ex is TPException ? throw ex : throw TPException('Error decoding client json response for key $documentKey: $ex', TPErrorCodes.cnbClientRequestError);
    }
  }

  Future<http.Response> getFrom(String endpoint, String documentKey) async {
    final getResponse = () async {
      final url = Uri.parse(path.join(_host, endpoint));

      final response = await http.get(url);

      if (response.statusCode == 422) {
        final bodyJson = json.decode(response.body);

        if (bodyJson == null) {
          throw TPException('Error decoding 422 response',
              TPErrorCodes.cnbClientDecodeResponseError);
        }

        final error = CnbErrorModel.fromJson(bodyJson);
        throw TPException(error.message, TPErrorCodes.cnbClientResponseError);
      } else if (response.statusCode != 200) {
        throw TPException('CnbClient response for key $documentKey: (${response.statusCode}) ${response.reasonPhrase}', TPErrorCodes.cnbClientRequestError);
      }

      return response;
    };
    return await tryCatchMethod(documentKey, getResponse);
  }

  Future<TravelPermitModel> getTravelPermitInfo(String documentKey) async {
    final response = await getFrom('api/documents/keys/$documentKey/travel-permit', documentKey);
    final getJson = () => TravelPermitModel.fromJson(documentKey, json.decode(response.body));
    return await tryCatchMethod(documentKey, getJson);
  }

  Future<http.Response> getTravelPermitPdfRequest(String documentKey) async {
    final ticketResponse = await getFrom('api/documents/keys/$documentKey/ticket?type=Signatures', documentKey);
    final downloadEndpoint = json.decode(ticketResponse.body)['location'].substring(1);
    return await getFrom(downloadEndpoint, documentKey);
  }
}
