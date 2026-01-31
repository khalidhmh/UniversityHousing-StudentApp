import 'package:encrypt/encrypt.dart' as encrypt;

class SecurityService {
  // المفتاح السري (ثابت)
  final _key = encrypt.Key.fromUtf8('my_32_characters_long_key_123456');
  late final encrypt.Encrypter _encrypter;

  SecurityService() {
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  String generateSecureQRToken(String studentId) {
    // 1. حساب نافذة الوقت
    final int timeWindow = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    
    // 2. تجهيز البيانات
    final String rawData = '$studentId|$timeWindow';
    
    // 3. توليد IV عشوائي جديد كل مرة
    final iv = encrypt.IV.fromSecureRandom(16);
    
    // 4. التشفير
    final encrypted = _encrypter.encrypt(rawData, iv: iv);
    
    // 5. النتيجة: دمج الـ IV مع النص المشفر
    return '${iv.base64}:${encrypted.base64}';
  }

  double getRemainingTimePercentage() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return 1.0 - ((now % 30000) / 30000);
  }
  
  int getSecondsRemaining() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return 30 - (now % 30000 ~/ 1000);
  }
}