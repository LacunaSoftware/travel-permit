import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class CryptoUtil {
  static ECDomainParameters _ecDomain = ECCurve_secp256r1();

  static ECPublicKey _publicKeyV1 = ECPublicKey(
      _ecDomain.curve.createPoint(
          BigIntExt.fromBase64('e7yZX1L9JolR7zIaA2I/QIEdnj2C8jy3DKpSILqoD4o='),
          BigIntExt.fromBase64('IbGzOdj4ikD81oQHgmT7ohHxj8KfZ7M5y45cHryuBzg=')),
      _ecDomain);

  static bool verifySignature(Uint8List signature, Uint8List tbsData) {
    final verifier = Signer("SHA-256/ECDSA");
    verifier.init(false, PublicKeyParameter(_publicKeyV1));
    final ecSig = ECSignatureExt.fromBytes(signature);
    return verifier.verifySignature(tbsData, ecSig);
  }
}

//-------------------------------------------------------------------

extension ECSignatureExt on ECSignature {
  static ECSignature fromBytes(Uint8List signature) {
    // ASN1 format
    // ECDSA-Sig-Value ::= SEQUENCE {
    //   r  INTEGER,
    //   s  INTEGER
    // }

    final ecdsaSigValue = ASN1Sequence.fromBytes(signature);
    final r = (ecdsaSigValue.elements[0] as ASN1Integer).integer;
    final s = (ecdsaSigValue.elements[1] as ASN1Integer).integer;

    return ECSignature(r, s);
  }
}

//-------------------------------------------------------------------

extension BigIntExt on BigInt {
  static BigInt fromBytes(List<int> bytes) {
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
    return result != BigInt.zero
        ? negative
            ? result.toSigned(result.bitLength)
            : result
        : BigInt.zero;
  }

  static BigInt fromBase64(String b64) {
    return fromBytes(base64.decode(b64));
  }
}
