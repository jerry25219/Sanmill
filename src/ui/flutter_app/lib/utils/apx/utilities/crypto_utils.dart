import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class CryptoUtils {
  final _random = Random.secure();
  static final CryptoUtils _instance = CryptoUtils._internal();
  static const String _publicKey =
      'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDQVt8VF3KLgILMfkxc9hCAGy1mE7SKD60HWmK5eacD3uBQW/R1XKRiUlnDp+GB11jNVz54GskCTg4lKr0cPSC3sl1/LhG0wlq7KtDjjfqInBzrM0hJQ++GHKGK8+UnBMPEx4okB+Md9IFQ11wrNEBF2+/Ct2efFBiKD9uvvQ8yQIDAQAB';

  factory CryptoUtils() {
    return _instance;
  }
  CryptoUtils._internal();

  /// 随机生成32位的字符串
  String generateRandomString() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(32, (index) => characters[_random.nextInt(characters.length)]).join();
  }

  /// 随机生成AES密钥
  Key generateAesKey() {
    return Key.fromUtf8(generateRandomString());
  }

  /// 加密Base64
  String encryptBase64(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  /// 解密Base64
  String decryptBase64(String input) {
    final bytes = base64.decode(input);
    return utf8.decode(bytes);
  }

  /// 使用AES密钥对数据进行加密
  String encryptWithAes(String message, Key aesKey) {
    final encrypter = Encrypter(AES(aesKey, mode: AESMode.ecb));
    final encrypted = encrypter.encrypt(message);
    return encrypted.base64;
  }

  /// 使用AES密钥对数据进行解密
  String decryptWithAes(String encryptedMessage, Key aesKey) {
    final encrypter = Encrypter(AES(aesKey, mode: AESMode.ecb));
    final decrypted = encrypter.decrypt64(encryptedMessage);
    return decrypted;
  }

  /// 使用RSA公钥加密
  String encryptWithRsa(String message, RSAPublicKey publicKey) {
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    final encrypted = encrypter.encrypt(message);
    return encrypted.base64;
  }

  /// 使用RSA私钥解密
  String decryptWithRsa(String encryptedMessage, RSAPrivateKey privateKey) {
    final encrypter = Encrypter(RSA(privateKey: privateKey));
    final decrypted = encrypter.decrypt64(encryptedMessage);
    return decrypted;
  }

  /// 使用RSA公钥加密
  String encrypt(String txt) {
    final parser = RSAKeyParser();
    final publicKey = parser.parse(splitStr(_publicKey)) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    final encrypted = encrypter.encrypt(txt);
    return encrypted.base64;
  }

  /// 使用RSA私钥解密
  String decrypt(String txt, RSAPrivateKey privateKey) {
    final encrypter = Encrypter(RSA(privateKey: privateKey));
    final decrypted = encrypter.decrypt64(txt);
    return decrypted;
  }

  String splitStr(String str) {
    const begin = '-----BEGIN PUBLIC KEY-----\n';
    const end = '\n-----END PUBLIC KEY-----';
    final int splitCount = str.length ~/ 64;
    final List<String> strList = [];

    for (int i = 0; i < splitCount; i++) {
      strList.add(str.substring(64 * i, 64 * (i + 1)));
    }
    if (str.length % 64 != 0) {
      strList.add(str.substring(64 * splitCount));
    }

    return begin + strList.join('\n') + end;
  }
}
