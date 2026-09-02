import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeAndroidService {
  NativeAndroidService._();

  static const MethodChannel _channel = MethodChannel('com.nirapod/native');
  static final ValueNotifier<String?> sharedText = ValueNotifier(null);

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> initialize() async {
    if (!isSupported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedTextReceived') {
        sharedText.value = call.arguments?.toString();
      }
    });
    sharedText.value = await getSharedText();
  }

  static Future<T?> _invoke<T>(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    if (!isSupported) return null;
    return _channel.invokeMethod<T>(method, arguments);
  }

  static Future<bool> authenticate() async =>
      await _invoke<bool>('authenticate') ?? false;

  static Future<void> startProtection() => _invoke('startProtection');

  static Future<void> stopProtection() => _invoke('stopProtection');

  static Future<void> showNotification({
    required String title,
    required String body,
  }) =>
      _invoke('showNotification', {'title': title, 'body': body});

  static Future<String?> getClipboardText() =>
      _invoke<String>('getClipboardText');

  static Future<String?> getSharedText() => _invoke<String>('getSharedText');

  static Future<List<Map<String, dynamic>>> scanLocalNetwork() async {
    final raw = await _invoke<List<dynamic>>('scanLocalNetwork') ?? const [];
    return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<Map<String, dynamic>> currentWifiInfo() async {
    final raw = await _invoke<Map<dynamic, dynamic>>('currentWifiInfo');
    return raw == null ? {} : Map<String, dynamic>.from(raw);
  }

  static Future<List<Map<String, dynamic>>> scanNearbyBluetooth() async {
    final raw = await _invoke<List<dynamic>>('scanNearbyBluetooth') ?? const [];
    return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<Map<String, dynamic>> capabilities() async {
    final raw = await _invoke<Map<dynamic, dynamic>>('platformCapabilities');
    return raw == null ? {} : Map<String, dynamic>.from(raw);
  }

  static Future<Map<String, dynamic>> advancedRoomCapabilities() async {
    final raw =
        await _invoke<Map<dynamic, dynamic>>('advancedRoomCapabilities');
    return raw == null ? {} : Map<String, dynamic>.from(raw);
  }

  static Future<List<Map<String, dynamic>>> connectedUsbAccessories() async {
    final raw =
        await _invoke<List<dynamic>>('connectedUsbAccessories') ?? const [];
    return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<Map<String, dynamic>> classifyRoomImage(String path) async {
    final raw = await _invoke<Map<dynamic, dynamic>>(
      'classifyRoomImage',
      {'path': path},
    );
    return raw == null ? {} : Map<String, dynamic>.from(raw);
  }
}
