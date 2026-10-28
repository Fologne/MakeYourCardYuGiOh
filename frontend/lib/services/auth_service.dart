import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';

// Servico responsavel pelo gerenciamento de sessao e integracao com a API
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response['message'] ?? 'Credenciais invalidas.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Erro na comunicacao com a API de login: $e');
      }

      final errorStr = e.toString().replaceFirst('Exception: ', '');
      if (errorStr.contains('Connection refused') ||
          errorStr.contains('Failed to connect') ||
          errorStr.contains('ClientException')) {
        _errorMessage = 'Nao foi possivel conectar ao servidor (porta 3000). Verifique se o Docker/Backend esta ativo.';
      } else {
        _errorMessage = errorStr;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registra um novo usuario sincronizando com a rota POST /api/auth/register no MongoDB
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
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'gameOrigin': gameOrigin,
        'password': password,
      };

      final response = await _api.post('/auth/register', payload);

      if (response['success'] == true && response['user'] != null) {
        _token = response['token'];
        _currentUser = UserModel.fromMap(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response['message'] ?? 'Falha ao registrar usuario.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Erro na comunicacao com a API de registro: $e');
      }

      final errorStr = e.toString().replaceFirst('Exception: ', '');
      if (errorStr.contains('Connection refused') ||
          errorStr.contains('Failed to connect') ||
          errorStr.contains('ClientException')) {
        _errorMessage = 'Nao foi possivel conectar ao servidor (porta 3000). Inicie o Docker/Backend para salvar no MongoDB.';
      } else {
        _errorMessage = errorStr;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Atualiza os dados cadastrais do usuario no backend
  Future<bool> updateUserData(UserModel updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();

    if (_token != null) {
      try {
        await _api.put('/auth/profile', updatedUser.toMap(), token: _token!);
        return true;
      } catch (e) {
        if (kDebugMode) print('Erro ao sincronizar atualizacao no backend: $e');
      }
    }
    return true;
  }

  // Encerra a sessao
  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  // Desativa temporariamente a conta no backend
  Future<void> deactivateAccount() async {
    if (_token != null) {
      try {
        await _api.post('/auth/deactivate', {}, token: _token);
      } catch (e) {
        if (kDebugMode) print('Erro ao desativar conta no backend: $e');
      }
    }
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  // Remove definitivamente a conta no backend
  Future<void> deleteAccount() async {
    if (_token != null) {
      try {
        await _api.delete('/auth/account', token: _token!);
      } catch (e) {
        if (kDebugMode) print('Erro ao apagar conta no backend: $e');
      }
    }
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}
