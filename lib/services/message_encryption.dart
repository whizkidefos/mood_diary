import 'dart:io';

import 'package:encrypt/encrypt.dart';

class MessageEncryption {
  static final _key = Key.fromSecureRandom(32);
  static final _iv = IV.fromSecureRandom(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  static String decrypt(String encryptedText) {
    return _encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: _iv);
  }

  static Future<void> encryptFile(String sourcePath, String destPath) async {
    final file = File(sourcePath);
    final bytes = await file.readAsBytes();
    final encrypted = _encrypter.encryptBytes(bytes, iv: _iv);
    await File(destPath).writeAsBytes(encrypted.bytes);
  }

  static Future<void> decryptFile(String sourcePath, String destPath) async {
    final file = File(sourcePath);
    final bytes = await file.readAsBytes();
    final decrypted = _encrypter.decryptBytes(Encrypted(bytes), iv: _iv);
    await File(destPath).writeAsBytes(decrypted);
  }
}
