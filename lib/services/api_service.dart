import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ScanPrediction {
  const ScanPrediction({
    required this.id,
    required this.scanType,
    required this.content,
    required this.classification,
    required this.riskScore,
    required this.confidence,
    required this.reasons,
    required this.recommendation,
    required this.urlIntelligence,
    required this.signalDetails,
  });

  final int id;
  final String scanType;
  final String content;
  final String classification;
  final int riskScore;
  final double confidence;
  final List<String> reasons;
  final String recommendation;
  final Map<String, dynamic>? urlIntelligence;
  final List<Map<String, dynamic>> signalDetails;

  factory ScanPrediction.fromJson(Map<String, dynamic> json) {
    return ScanPrediction(
      id: json['id'] as int,
      scanType: json['scan_type'] as String,
      content: json['content'] as String,
      classification: json['classification'] as String,
      riskScore: json['risk_score'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      reasons: List<String>.from(json['reasons'] as List),
      recommendation: json['recommendation'] as String,
      urlIntelligence: json['url_intelligence'] == null
          ? null
          : Map<String, dynamic>.from(
              json['url_intelligence'] as Map<String, dynamic>,
            ),
      signalDetails: (json['signal_details'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}

class ApiService {
  ApiService._();

  static String? authToken;
  static const _startupTimeout = Duration(seconds: 60);

  static Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  static String get baseUrl {
    // Allows physical-device builds to use USB port forwarding or a deployed
    // HTTPS API without changing source code. Example:
    // --dart-define=API_BASE_URL=http://127.0.0.1:8000
    const configuredUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredUrl.isNotEmpty) return configuredUrl;

    // Use the same explicit IPv4 loopback address as the local backend.
    // Some Windows/Chrome configurations resolve `localhost` to IPv6 (::1),
    // while Uvicorn is listening on IPv4, which produces ClientException:
    // Failed to fetch.
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static Exception _networkError(Object error) {
    if (error is TimeoutException) {
      return Exception(
        'The security service is taking longer than expected to start. '
        'Please wait a moment and try again.',
      );
    }
    return Exception(
      'Could not connect to the Nirapod AI security service. '
      'Check your internet connection and backend address, then try again.',
    );
  }

  static Future<ScanPrediction> scanUrl(String url) => _scan('/scan/url', url);

  static Future<ScanPrediction> scanMessage(String message) =>
      _scan('/scan/message', message);

  static Future<ScanPrediction> scanText(String text) =>
      _scan('/scan/text', text);

  static Future<ScanPrediction> scanSms(String message) =>
      _scan('/scan/sms', message);

  static Future<ScanPrediction> scanEmail(String emailContent) =>
      _scan('/scan/email', emailContent);

  static Future<ScanPrediction> scanOcr(String extractedText) =>
      _scan('/scan/ocr', extractedText);

  static Future<ScanPrediction> scanQr(String value) =>
      _scan('/scan/qr', value);

  static Future<ScanPrediction> roomSafetyCheck({
    required bool reflectionDetected,
    required bool suspiciousObject,
    required bool visualCheckCompleted,
    required bool networkCheckCompleted,
    required bool bluetoothCheckCompleted,
    required List<Map<String, dynamic>> networkFindings,
    required List<Map<String, dynamic>> bluetoothFindings,
    List<Map<String, dynamic>> advancedReadings = const [],
    Map<String, dynamic> stageAResult = const {},
    Map<String, dynamic> stageBResult = const {},
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/room-safety-check'),
          headers: _headers,
          body: jsonEncode({
            'reflection_detected': reflectionDetected,
            'suspicious_object': suspiciousObject,
            'visual_check_completed': visualCheckCompleted,
            'network_check_completed': networkCheckCompleted,
            'bluetooth_check_completed': bluetoothCheckCompleted,
            'network_findings': networkFindings,
            'bluetooth_findings': bluetoothFindings,
            'advanced_readings': advancedReadings,
            'stage_a_result': stageAResult,
            'stage_b_result': stageBResult,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Room safety check failed (${response.statusCode})');
    }
    return ScanPrediction.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ScanPrediction> wifiSafetyCheck({
    required Map<String, dynamic> wifi,
    required List<Map<String, dynamic>> networkFindings,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/wifi-safety-check'),
          headers: _headers,
          body: jsonEncode({
            'ssid': wifi['ssid'] ?? 'Unknown Wi-Fi',
            'security': wifi['security'] ?? 'Unknown',
            'rssi': wifi['rssi'],
            'frequency_mhz': wifi['frequencyMhz'],
            'network_findings': networkFindings,
          }),
        )
        .timeout(_startupTimeout);
    if (response.statusCode != 200) {
      throw Exception('Wi-Fi safety check failed (${response.statusCode})');
    }
    return ScanPrediction.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ScanPrediction> _scan(String path, String content) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode({'content': content}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Scan failed (${response.statusCode})');
    }
    return ScanPrediction.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<Map<String, dynamic>> history({
    int limit = 6,
    int offset = 0,
    String? scanType,
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/history').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
        if (scanType != null) 'scan_type': scanType,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('History request failed');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'items': List<Map<String, dynamic>>.from(body['items'] as List),
      'total': body['total'] as int,
    };
  }

  static Future<Map<String, dynamic>> analytics({int days = 30}) async {
    final uri = Uri.parse('$baseUrl/analytics').replace(
      queryParameters: {'days': '$days'},
    );
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 404 || response.statusCode == 405) {
      final savedHistory = await history(limit: 1000);
      return _analyticsFromHistory(savedHistory, days);
    }
    throw Exception('Analytics request failed (${response.statusCode})');
  }

  static Map<String, dynamic> _analyticsFromHistory(
    Map<String, dynamic> historyData,
    int days,
  ) {
    final safeDays = days.clamp(1, 365);
    final today = DateTime.now().toUtc();
    final start = DateTime.utc(today.year, today.month, today.day)
        .subtract(Duration(days: safeDays - 1));
    final allItems = List<Map<String, dynamic>>.from(
      historyData['items'] as List? ?? const [],
    );
    final periodItems = allItems.where((item) {
      final raw = (item['created_at'] as String? ?? '').replaceFirst(' ', 'T');
      final parsed = DateTime.tryParse('${raw}Z')?.toUtc();
      return parsed != null && !parsed.isBefore(start);
    }).toList();
    final summary = {
      'safe': 0,
      'suspicious': 0,
      'dangerous': 0,
      'inconclusive': 0,
    };
    final byType = <String, int>{};
    final daily = List.generate(safeDays, (index) {
      final date = start.add(Duration(days: index));
      return {
        'date': date.toIso8601String().substring(0, 10),
        'count': 0,
      };
    });
    for (final item in periodItems) {
      final classification = item['classification'] as String? ?? '';
      if (summary.containsKey(classification)) {
        summary[classification] = summary[classification]! + 1;
      }
      final type = item['scan_type'] as String? ?? 'unknown';
      byType[type] = (byType[type] ?? 0) + 1;
      final raw = (item['created_at'] as String? ?? '').replaceFirst(' ', 'T');
      final parsed = DateTime.tryParse('${raw}Z')?.toUtc();
      if (parsed != null) {
        final index = DateTime.utc(parsed.year, parsed.month, parsed.day)
            .difference(start)
            .inDays;
        if (index >= 0 && index < daily.length) {
          daily[index]['count'] = (daily[index]['count'] as int) + 1;
        }
      }
    }
    return {
      'period_days': safeDays,
      'from_date': daily.first['date'],
      'to_date': daily.last['date'],
      'summary': {...summary, 'total': periodItems.length},
      'by_type': byType,
      'daily': daily,
      'recent_threats': allItems
          .where(
            (item) =>
                item['classification'] == 'suspicious' ||
                item['classification'] == 'dangerous',
          )
          .take(5)
          .toList(),
      'source': 'authenticated_history_fallback',
    };
  }

  static Future<void> submitReport({
    required String type,
    required String content,
    String details = '',
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/reports'),
          headers: _headers,
          body: jsonEncode({
            'report_type': type,
            'content': content,
            'details': details,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Report submission failed');
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_startupTimeout);
      return _acceptAuthentication(response);
    } on TimeoutException catch (error) {
      throw _networkError(error);
    } on http.ClientException catch (error) {
      throw _networkError(error);
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_startupTimeout);
      return _acceptAuthentication(response);
    } on TimeoutException catch (error) {
      throw _networkError(error);
    } on http.ClientException catch (error) {
      throw _networkError(error);
    }
  }

  static Future<String> requestPasswordReset(String email) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/request'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email.trim()}),
        )
        .timeout(const Duration(seconds: 15));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Password reset request failed.');
    }
    return body['message'] as String;
  }

  static Future<String> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/password-reset/confirm'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'token': token.trim(),
            'new_password': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Password reset failed.');
    }
    return body['message'] as String;
  }

  static Map<String, dynamic> _acceptAuthentication(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['detail'] ?? 'Authentication failed.');
    }
    authToken = body['token'] as String;
    return body;
  }

  static Future<void> logout() async {
    final token = authToken;
    authToken = null;
    if (token == null) return;
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<Map<String, dynamic>> profile() async {
    final response = await http
        .get(Uri.parse('$baseUrl/profile'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Profile request failed');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/profile'),
          headers: _headers,
          body: jsonEncode({'name': name, 'email': email}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Profile update failed');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<String> exportData() async {
    final response = await http
        .get(Uri.parse('$baseUrl/export'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Export failed');
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonDecode(response.body));
  }

  static Future<Map<String, dynamic>> settings() async {
    final response = await http
        .get(Uri.parse('$baseUrl/settings'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Settings request failed');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/settings'),
          headers: _headers,
          body: jsonEncode(settings),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Settings update failed');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> helpArticles({
    String query = '',
    String category = 'all',
  }) async {
    final uri = Uri.parse('$baseUrl/help/articles').replace(
      queryParameters: {'q': query, 'category': category},
    );
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Help request failed');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['items'] as List);
  }

  static Future<int> submitSupportTicket({
    required String subject,
    required String message,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/help/tickets'),
          headers: _headers,
          body: jsonEncode({'subject': subject, 'message': message}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Support request failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['id'] as int;
  }

  static Future<List<Map<String, dynamic>>> notifications() async {
    final response = await http
        .get(Uri.parse('$baseUrl/notifications'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Notifications request failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['items'] as List);
  }

  static Future<void> markNotificationRead(int id) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/notifications/$id/read'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Notification update failed');
    }
  }

  static Future<void> markAllNotificationsRead() async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/notifications/read-all'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Notification update failed');
    }
  }

  static Future<List<Map<String, dynamic>>> chatHistory() async {
    final response = await http
        .get(Uri.parse('$baseUrl/chat/history'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Chat history request failed');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['items'] as List);
  }

  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: _headers,
          body: jsonEncode({'message': message}),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) throw Exception('Chat request failed');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> clearChatHistory() async {
    final response = await http
        .delete(Uri.parse('$baseUrl/chat/history'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Chat history could not be cleared');
    }
  }
}
