import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiService {
  const ApiService();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:3000',
  );

  // P09: 오류가 발생하면 화면에서 이유와 다시 시도 동작을 제공한다.
  Future<List<SmokingRecord>> fetchRecords({
    DemoState demoState = DemoState.normal,
  }) async {
    if (demoState == DemoState.slow) {
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    if (demoState == DemoState.error) {
      throw Exception('데모 오류: 기록을 불러오지 못했습니다.');
    }

    if (demoState == DemoState.empty) {
      return const [];
    }

    final uri = Uri.parse('$baseUrl/records');
    final response = await http.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('서버 응답 오류 (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => SmokingRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
