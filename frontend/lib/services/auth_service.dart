import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

// Servico responsavel pelo gerenciamento de sessao e autenticacao
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // Gera identificador unico de conta para novos usuarios
  String _generateAccountId() {
    final random = Random();
    final numbers = random.nextInt(900000) + 100000;
    return 'MYC-$numbers';
  }

  // Realiza o login do usuario
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulacao de requisicao de autenticacao
    await Future.delayed(const Duration(milliseconds: 600));

    if (identifier.trim().isEmpty || password.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Cria sessao de usuario autenticado
    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      accountId: _generateAccountId(),
      username: identifier.contains('@') ? identifier.split('@').first : identifier,
      email: identifier.contains('@') ? identifier : '$identifier@makeyourcard.com',
      firstName: 'Duelista',
      lastName: 'Principal',
      birthDate: DateTime(2000, 1, 1),
      gender: 'Nao informado',
      gameOrigin: 'TCG',
      plan: 'Gratuito',
      preferredPronoun: 'Duelista',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Registra um novo usuario utilizando data de nascimento
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
    notifyListeners();

    // Simulacao de envio para a API do backend
    await Future.delayed(const Duration(milliseconds: 700));

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      accountId: _generateAccountId(),
      username: username.trim(),
      email: email.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      birthDate: birthDate,
      gender: gender,
      gameOrigin: gameOrigin,
      plan: 'Gratuito',
      preferredPronoun: 'Duelista',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Atualiza os dados cadastrais do usuario
  void updateUserData(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Encerra a sessao
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Desativa temporariamente a conta
  void deactivateAccount() {
    _currentUser = null;
    notifyListeners();
  }

  // Remove definitivamente a conta
  void deleteAccount() {
    _currentUser = null;
    notifyListeners();
  }
}
