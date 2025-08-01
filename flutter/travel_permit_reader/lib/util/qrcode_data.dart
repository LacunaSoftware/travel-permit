import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:travel_permit_reader/tp_exception.dart';
import 'package:travel_permit_reader/util/crypto_util.dart';

class QRCodeData {
  final int version;
  final String documentKey;
  final String? startDate;
  final String expirationDate;
  final String? travelPermitType;
  final String? requiredGuardianName;
  final String? requiredGuardianDocumentNumber;
  final String? requiredGuardianDocumentIssuer;
  final String? requiredGuardianDocumentType;
  final String? requiredGuardianGuardianship;
  final String? optionalGuardianName;
  final String? optionalGuardianDocumentNumber;
  final String? optionalGuardianDocumentIssuer;
  final String? optionalGuardianDocumentType;
  final String? optionalGuardianGuardianship;
  final String? escortName;
  final String? escortDocumentNumber;
  final String? escortDocumentIssuer;
  final String? escortDocumentType;
  final String? escortGuardianship;
  final String? underageName;
  final String? underageDocumentNumber;
  final String? underageDocumentIssuer;
  final String? underageDocumentType;
  final String? underageBirthDate;
  final String? underageBioGender;
  final String? judgeName;
  final String? organizationName;
  final String? destinationType;
  final String? destinationCountry;
  final String? destinationState;
  final String? destinationCity;
  final Uint8List signature;

  List<String>? _segments;

  QRCodeData._(
      {required this.version,
      required this.documentKey,
      this.startDate,
      required this.expirationDate,
      this.travelPermitType,
      this.requiredGuardianName,
      this.requiredGuardianDocumentNumber,
      this.requiredGuardianDocumentIssuer,
      this.requiredGuardianDocumentType,
      this.requiredGuardianGuardianship,
      this.optionalGuardianName,
      this.optionalGuardianDocumentNumber,
      this.optionalGuardianDocumentIssuer,
      this.optionalGuardianDocumentType,
      this.optionalGuardianGuardianship,
      this.escortName,
      this.escortDocumentNumber,
      this.escortDocumentIssuer,
      this.escortDocumentType,
      this.escortGuardianship,
      this.underageName,
      this.underageDocumentNumber,
      this.underageDocumentIssuer,
      this.underageDocumentType,
      this.underageBirthDate,
      this.underageBioGender,
      this.judgeName,
      this.organizationName,
      this.destinationType,
      this.destinationCountry,
      this.destinationState,
      this.destinationCity,
      required this.signature});

  static const _magicPrefix = 'LTP';
  static const _latestKnownVersion = 4;
  static const _segmentSeparator = '%';
  static const _spaceMarker = '+';

  static const _version_2_segments = 26;
  static const _version_3_segments = 27;
  static const _version_4_segments = 34;

  factory QRCodeData.parse(String code) {
    try {
      final segments = code.split(_segmentSeparator);
      if (segments.isEmpty || segments.first != _magicPrefix) {
        throw TPException(
            'Unknown QR code format', TPErrorCodes.qrCodeUnknownFormat);
      }

      final version = int.parse(segments[1]);
      if (version > _latestKnownVersion || version < 1) {
        throw TPException('Unknown QR code version: $version',
            TPErrorCodes.qrCodeUnknownVersion);
      }

      if ((version <= 2 && segments.length != _version_2_segments) ||
          (version == 3 && segments.length != _version_3_segments) ||
          (version == 4 && segments.length != _version_4_segments)) {
        throw TPException(
            'QR code is inconsistent: $code', TPErrorCodes.qrCodeDecodeError);
      }

      var index = 2;

      final data = QRCodeData._(
        version: version,
        documentKey: segments[index++],
        startDate: version >= 3 ? segments[index++] : null,
        expirationDate: segments[index++],
        travelPermitType: _decodeField(segments[index++]),
        requiredGuardianName: _decodeField(segments[index++]),
        requiredGuardianDocumentNumber: _decodeField(segments[index++]),
        requiredGuardianDocumentIssuer: _decodeField(segments[index++]),
        requiredGuardianDocumentType: _decodeField(segments[index++]),
        requiredGuardianGuardianship: _decodeField(segments[index++]),
        optionalGuardianName: _decodeField(segments[index++]),
        optionalGuardianDocumentNumber: _decodeField(segments[index++]),
        optionalGuardianDocumentIssuer: _decodeField(segments[index++]),
        optionalGuardianDocumentType: _decodeField(segments[index++]),
        optionalGuardianGuardianship: _decodeField(segments[index++]),
        underageName: _decodeField(segments[index++]),
        underageDocumentNumber: _decodeField(segments[index++]),
        underageDocumentIssuer: _decodeField(segments[index++]),
        underageDocumentType: _decodeField(segments[index++]),
        underageBirthDate: _decodeField(segments[index++]),
        underageBioGender: _decodeField(segments[index++]),
        escortName: _decodeField(segments[index++]),
        escortDocumentNumber: _decodeField(segments[index++]),
        escortDocumentIssuer: _decodeField(segments[index++]),
        escortDocumentType: _decodeField(segments[index++]),
        escortGuardianship:
            version >= 4 ? _decodeField(segments[index++]) : null,
        judgeName: version >= 4 ? _decodeField(segments[index++]) : null,
        organizationName: version >= 4 ? _decodeField(segments[index++]) : null,
        destinationType: version >= 4 ? _decodeField(segments[index++]) : null,
        destinationCountry:
            version >= 4 ? _decodeField(segments[index++]) : null,
        destinationState: version >= 4 ? _decodeField(segments[index++]) : null,
        destinationCity: version >= 4 ? _decodeField(segments[index++]) : null,
        signature: Uint8List.fromList(hex.decode(segments[index++])),
      );
      data._segments = segments;
      return data;
    } on TPException {
      rethrow;
    } catch (ex) {
      throw TPException(
          'Error decoding QR code: $ex', TPErrorCodes.qrCodeDecodeError);
    }
  }

  bool verify() {
    final tbsData = _getTbsData();
    return CryptoUtil.verifySignature(signature, tbsData);
  }

  Uint8List _getTbsData() {
    return Uint8List.fromList(utf8.encode(
        _segments!.getRange(0, _segments!.length - 1).join(_segmentSeparator)));
  }

  String getQRCodeData() {
    return _segments!.join(_segmentSeparator);
  }

  static String? _decodeField(String value) {
    return value == "" ? null : value.replaceAll(_spaceMarker, " ");
  }

  static bool _decodeBoolean(String value) {
    return _decodeField(value) == "1";
  }
}
