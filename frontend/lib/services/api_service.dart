import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() : _client = http.Client();
  @visibleForTesting
  ApiService.forTesting(this._client);
  http.Client _client;
  @visibleForTesting
  void setClient(http.Client client) {
    _client = client;
  }

  Future<void> Function(String token)? onUnauthorized;
  static const _baseUrlOverride = String.fromEnvironment('API_BASE_URL');
  String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);
    final http.Response response;
    try {
      response = await (() async {
        final stream = await _client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw ApiException(
        408,
        'Tempo de conexao esgotado. Verifique o servidor.',
      );
    }
    if (response.statusCode == 401 && token != null) {
      await onUnauthorized?.call(token);
    }
    Map<String, dynamic> data;
    try {
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      data = decoded;
    } on FormatException {
      throw ApiException(response.statusCode, 'Resposta invalida do servidor.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        data['message'] is String
            ? data['message'] as String
            : 'Erro na requisicao.',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) => _request('POST', endpoint, body: body, token: token);
  Future<Map<String, dynamic>> get(String endpoint, {required String token}) =>
      _request('GET', endpoint, token: token);
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    required String token,
  }) => _request('PUT', endpoint, body: body, token: token);
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    required String token,
  }) => _request('DELETE', endpoint, token: token);
}
