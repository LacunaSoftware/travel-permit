import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class CryptoUtil {
  static ECDomainParameters _ecDomain = ECCurve_secp256r1();

  // PRODUCTION
  // static ECPublicKey _publicKeyV1 = ECPublicKey(
  //     _ecDomain.curve.createPoint(
  //         BigIntExt.fromBase64('Mq1pD1R4qu6xjpIvarG54zOnGrAqvMbsq9Fvo8kns4s='),
  //         BigIntExt.fromBase64('1c53A4cKVXCtFucnC7Z54uNPzEHrVxgu3tJVhQNv19U=')),
  //     _ecDomain);

  // HOMOLOGATION
  static ECPublicKey _publicKeyV1 = ECPublicKey(
      _ecDomain.curve.createPoint(
          BigIntExt.fromBase64('hebj9X2FaROdv/g8iFhdk5ecfg6+lyaSTU9Jw2JOp8Q='),
          BigIntExt.fromBase64('A+jzLgtvtjAUpbNgNmBe3RZDHt1Ip8D9fte+Of17tNQ=')),
      _ecDomain);

  static bool verifySignature(Uint8List signature, Uint8List tbsData) {
    final verifier = Signer("SHA-256/ECDSA");
    verifier.init(false, PublicKeyParameter(_publicKeyV1));
    final ecSig = ECSignatureExt.fromAsn1Bytes(signature);
    return verifier.verifySignature(tbsData, ecSig);
  }
}

//-------------------------------------------------------------------

extension ECSignatureExt on ECSignature {
  static ECSignature fromAsn1Bytes(Uint8List signature) {
    // ASN1 format
    // ECDSA-Sig-Value ::= SEQUENCE {
    //   r  INTEGER,
    //   s  INTEGER
    // }

    final ecdsaSigValue = ASN1Sequence.fromBytes(signature);
    final r = (ecdsaSigValue.elements?[0] as ASN1Integer).integer;
    final s = (ecdsaSigValue.elements?[1] as ASN1Integer).integer;

    return ECSignature(r!, s!);
  }
}

//-------------------------------------------------------------------

extension BigIntExt on BigInt {
  static BigInt fromBytes(List<int> bytes, {bool signed = false}) {
    var negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;
    BigInt result;
    if (bytes.length == 1) {
      result = BigInt.from(bytes[0]);
    } else {
      result = BigInt.zero;
      for (var i = 0; i < bytes.length; i++) {
        var item = bytes[bytes.length - i - 1];
        result |= (BigInt.from(item) << (8 * i));
      }
    }

    if (result == BigInt.zero) {
      return BigInt.zero;
    }

    if (!negative) {
      return result;
    }

    if (signed) {
      return result.toSigned(result.bitLength);
    }
    return result.toUnsigned(result.bitLength);
  }

  static BigInt fromBase64(String b64, {bool signed = false}) {
    return fromBytes(base64.decode(b64));
  }
}
