enum TPErrorCodes {
  unknown,
  qrCodeUnknownFormat,
  qrCodeUnknownVersion,
  qrCodeDecodeError,
  cnbClientRequestError,
  cnbClientDecodeResponseError,
  documentNotFound,
}

class TPException implements Exception {
  final TPErrorCodes code;
  final String message;

  TPException([this.message, this.code = TPErrorCodes.unknown]);

  @override
  String toString() => '[$code]: $message';
}
