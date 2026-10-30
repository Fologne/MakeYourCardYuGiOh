import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';
import 'api_service.dart';

// Servico responsavel pelo gerenciamento de sessao e integracao com a API
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal()
    : _api = ApiService(),
      _storage = const FlutterSecureStorage() {
    _bindSession();
  }
  @visibleForTesting
  AuthService.forTesting(this._api, this._storage) {
    _bindSession();
  }
  void _bindSession() {
    _api.onUnauthorized = (token) async {
      if (_token == token) await logout();
    };
  }

  static const String _tokenKey = 'myc_access_token';
  static const String _userKey = 'myc_current_user';

  final ApiService _api;
  final FlutterSecureStorage _storage;

  SharedPreferences? _prefs;
  Future<void>? _storageQueue;
  Future<void> _queueStorage(Future<void> Function() action) async {
    final previous = _storageQueue;
    final done = Completer<void>();
    _storageQueue = done.future;
    try {
      if (previous != null) await previous;
      await action();
    } finally {
      if (identical(_storageQueue, done.future)) _storageQueue = null;
      done.complete();
    }
  }

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null && _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Restaura a sessao salva localmente e valida o token em segundo plano
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    String? savedToken;
    String? savedUser;
    try {
      savedToken = await _storage.read(key: _tokenKey);
      savedUser = await _storage.read(key: _userKey);
      final legacyToken = _prefs!.getString(_tokenKey);
      final legacyUser = _prefs!.getString(_userKey);
      if (savedToken == null && legacyToken != null && legacyUser != null) {
        await _storage.write(key: _tokenKey, value: legacyToken);
        await _storage.write(key: _userKey, value: legacyUser);
        savedToken = legacyToken;
        savedUser = legacyUser;
      }
      await _prefs!.remove(_tokenKey);
      await _prefs!.remove(_userKey);
    } catch (e) {
      _errorMessage = 'Nao foi possivel abrir o armazenamento seguro. Faca login novamente.';
      return;
    }

    if (savedToken == null || savedUser == null) {
      return;
    }

    try {
      final decoded = UserModel.fromMap(
        Map<String, dynamic>.from(
          (const JsonDecoder().convert(savedUser) as Map<String, dynamic>),
        ),
      );

      _token = savedToken;
      _currentUser = decoded;
    } catch (e) {
      if (kDebugMode) print('Sessao salva invalida, descartando: $e');
      await _clearStoredSession();
      return;
    }

    unawaited(_validateSession());
  }

  // Confere se o token salvo ainda e valido no backend
  Future<void> _validateSession() async {
    final validatingToken = _token;
    if (validatingToken == null) return;

    try {
      final response = await _api.get('/auth/me', token: validatingToken);
      if (_token != validatingToken) return;
      if (response['user'] != null) {
        _currentUser = UserModel.fromMap(response['user']);
        await _persistSession();
        notifyListeners();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 && _token == validatingToken) {
        await logout();
      }
    } catch (e) {
      if (kDebugMode) print('Nao foi possivel validar a sessao agora: $e');
    }
  }

  Future<void> _persistSession() {
    final token = _token;
    final user = _currentUser;
    return _queueStorage(() async {
      if (token == null || user == null || _token != token) return;
      _prefs ??= await SharedPreferences.getInstance();
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user.toMap()));
      await _prefs!.remove(_tokenKey);
      await _prefs!.remove(_userKey);
    });
  }

  Future<void> _clearStoredSession() => _queueStorage(() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_userKey);
  });

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    final errorStr = error.toString().replaceFirst('Exception: ', '');
    if (errorStr.contains('Connection refused') ||
        errorStr.contains('Failed to connect') ||
        errorStr.contains('ClientException') ||
        errorStr.contains('SocketException')) {
      return 'Nao foi possivel conectar ao servidor. Verifique se o backend esta ativo.';
    }

    return errorStr;
  }

  // Realiza o login conectando-se a API do backend e validando no MongoDB
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/login', {
        'identifier': identifier.trim(),
        'password': password,
      });

      if (response['success'] == true && response['user'] != null) {
        _token = response['token'];
        _currentUser = UserModel.fromMap(response['user']);
        await _persistSession();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response['message'] ?? 'Credenciais invalidas.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _token = null;
      _currentUser = null;
      if (kDebugMode) print('Erro na comunicacao com a API de login: $e');
      _errorMessage = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registra um novo usuario sincronizando com a rota POST /api/auth/register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String gameOrigin,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'birthDate': birthDate.toIso8601String().substring(0, 10),
        'gender': gender,
        'gameOrigin': gameOrigin,
        'password': password,
      };

      final response = await _api.post('/auth/register', payload);

      if (response['success'] == true && response['user'] != null) {
        _token = response['token'];
        _currentUser = UserModel.fromMap(response['user']);
        await _persistSession();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response['message'] ?? 'Falha ao registrar usuario.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _token = null;
      _currentUser = null;
      if (kDebugMode) print('Erro na comunicacao com a API de registro: $e');
      _errorMessage = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Atualiza os dados cadastrais do usuario no backend
  Future<bool> updateUserData(UserModel updatedUser) async {
    if (_token == null) {
      _errorMessage = 'Sessao expirada. Faca login novamente.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;

    try {
      final response = await _api.put('/auth/profile', {
        'firstName': updatedUser.firstName,
        'lastName': updatedUser.lastName,
        'email': updatedUser.email,
        'birthDate': updatedUser.birthDate.toIso8601String().substring(0, 10),
        'gender': updatedUser.gender,
        'gameOrigin': updatedUser.gameOrigin,
        'preferredPronoun': updatedUser.preferredPronoun,
      }, token: _token!);

      if (response['success'] == true && response['user'] != null) {
        _currentUser = UserModel.fromMap(response['user']);
        await _persistSession();
        notifyListeners();
        return true;
      }

      _errorMessage = response['message'] ?? 'Falha ao atualizar os dados.';
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) print('Erro ao sincronizar atualizacao no backend: $e');
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  // Encerra a sessao e remove os dados salvos localmente
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();

    try {
      await _clearStoredSession();
    } catch (e) {
      if (kDebugMode) print('Erro ao limpar a sessao local: $e');
    }
  }

  // Desativa temporariamente a conta no backend
  Future<bool> deactivateAccount() async {
    if (_token == null) {
      _errorMessage = 'Sessao expirada. Faca login novamente.';
      notifyListeners();
      return false;
    }

    try {
      await _api.post('/auth/deactivate', {}, token: _token);
      await logout();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  // Remove definitivamente a conta no backend
  Future<bool> deleteAccount() async {
    if (_token == null) {
      _errorMessage = 'Sessao expirada. Faca login novamente.';
      notifyListeners();
      return false;
    }

    try {
      await _api.delete('/auth/account', token: _token!);
      await logout();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }
}
