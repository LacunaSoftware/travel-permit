import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/export.dart';

class CryptoUtil {
  static ECDomainParameters _ecDomain = ECCurve_brainpoolp256r1();

  static ECPublicKey publicKey = ECPublicKey(
      _ecDomain.curve.createPoint(
          BigIntExt.fromBase64('BPHg64gQD2OxY5CO2LQhap/HXetTzGIgcqYp7NuCrio='),
          BigIntExt.fromBase64('aSznx7RGG0mJQlnI6mRW3ItrU5587wYBVnKHkhx7+20=')),
      _ecDomain);

  static bool verifyEcdsaSignature(
      Uint8List signature, Uint8List tbsData, ECPublicKey publicKey) {
    final verifier = Signer("SHA-256/ECDSA");
    verifier.init(false, PublicKeyParameter(publicKey));
    final ecSig = ECSignatureExt.fromBytes(signature);
    return verifier.verifySignature(tbsData, ecSig);
  }
}

//-------------------------------------------------------------------

extension BigIntExt on BigInt {
  static BigInt fromBytes(List<int> bytes) {
    BigInt result = new BigInt.from(0);
    for (int i = 0; i < bytes.length; i++) {
      result += new BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }

  static BigInt fromBase64(String b64) {
    return fromBytes(base64.decode(b64));
  }
}

//-------------------------------------------------------------------

extension ECSignatureExt on ECSignature {
  static ECSignature fromBytes(Uint8List signature) {
    final r = BigIntExt.fromBytes(
        signature.getRange(0, signature.length ~/ 2).toList());
    final s = BigIntExt.fromBytes(
        signature.getRange(signature.length ~/ 2, signature.length).toList());

    return ECSignature(r, s);
  }
}
