import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._http, {this.baseUrl = 'https://dummyjson.com'});
  final http.Client _http;
  final String baseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _http.get(Uri.parse('$baseUrl$path'));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _http.post(
      Uri.parse('$baseUrl$path'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic value = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = value is Map<String, dynamic>
          ? value['message']?.toString() ??
                'Request failed (${response.statusCode})'
          : 'Request failed (${response.statusCode})';
      throw ApiException(message);
    }
    if (value is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response from server.');
    }
    return value;
  }
}
