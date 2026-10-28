import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Servico universal de comunicacao HTTP com a API Node.js do backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Define a URL base dependendo do ambiente (Web/Desktop vs Emulador Android)
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    // No Windows Desktop e Web utiliza localhost
    return 'http://localhost:3000/api';
  }

  // Executa requisicoes HTTP POST
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro na requisicao (${response.statusCode})');
    }
  }

  // Executa requisicoes HTTP GET
  Future<Map<String, dynamic>> get(String endpoint, {required String token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro na requisicao (${response.statusCode})');
    }
  }

  // Executa requisicoes HTTP PUT
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http
        .put(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro na requisicao (${response.statusCode})');
    }
  }

  // Executa requisicoes HTTP DELETE
  Future<Map<String, dynamic>> delete(String endpoint, {required String token}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .delete(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 8));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro na requisicao (${response.statusCode})');
    }
  }
}
