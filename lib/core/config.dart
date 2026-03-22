import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves token server URL: emulator → 10.0.2.2, physical phone → API_BASE_URL.
Future<String> resolveApiBaseUrl() async {
  final fromEnv = dotenv.env['API_BASE_URL']?.trim();
  if (fromEnv != null && fromEnv.isNotEmpty) {
    final normalized = fromEnv.replaceAll(RegExp(r'/$'), '');
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = await DeviceInfoPlugin().androidInfo;
      if (!android.isPhysicalDevice) {
        // Emulator must use host loopback, not LAN IP.
        return 'http://10.0.2.2:3000';
      }
    }
    return normalized;
  }
  if (kIsWeb) return 'http://127.0.0.1:3000';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://127.0.0.1:3000';
}

/// Sync fallback (prefer [resolveApiBaseUrl] in video flow).
String get apiBaseUrl {
  final fromEnv = dotenv.env['API_BASE_URL']?.trim();
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv.replaceAll(RegExp(r'/$'), '');
  }
  if (kIsWeb) return 'http://127.0.0.1:3000';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://127.0.0.1:3000';
}
