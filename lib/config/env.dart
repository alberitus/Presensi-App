import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  /// Inisialisasi dotenv
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  /// Ambil value dari .env
  static String get(String key, {String fallback = ''}) {
    return dotenv.env[key] ?? fallback;
  }
}
