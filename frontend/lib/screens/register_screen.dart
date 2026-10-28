import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  DateTime? _selectedBirthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  String _selectedGender = 'Prefiro nao informar';
  String _selectedGameOrigin = 'TCG';

  final List<String> _genderOptions = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro nao informar',
  ];

  final List<String> _gameOriginOptions = [
    'TCG',
    'OCG',
    'Master Duel',
    'Duel Links',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'Masculino':
        return Icons.male;
      case 'Feminino':
        return Icons.female;
      case 'Outro':
        return Icons.transgender;
      default:
        return Icons.shield_outlined;
    }
  }

  IconData _getGameOriginIcon(String origin) {
    switch (origin) {
      case 'TCG':
        return Icons.style;
      case 'OCG':
        return Icons.auto_stories;
      case 'Master Duel':
        return Icons.desktop_windows;
      case 'Duel Links':
        return Icons.phone_android;
      default:
        return Icons.sports_esports;
    }
  }

  // Abre seletor de data de nascimento
  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 18, 1, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF141414),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year.toString();
        _birthDateController.text = '$day/$month/$year';
      });
    }
  }

  // Calcula idade a partir da data de nascimento selecionada
  int? get _calculatedAge {
    if (_selectedBirthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - _selectedBirthDate!.year;
    if (now.month < _selectedBirthDate!.month ||
        (now.month == _selectedBirthDate!.month && now.day < _selectedBirthDate!.day)) {
      age--;
    }
    return age >= 0 ? age : 0;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione sua data de nascimento.'),
          backgroundColor: Color(0xFFFF1493),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _authService.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      birthDate: _selectedBirthDate!,
      gender: _selectedGender,
      gameOrigin: _selectedGameOrigin,
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso.'),
          backgroundColor: Color(0xFFFFD700),
        ),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      final errorMsg = _authService.errorMessage ?? 'Erro ao criar conta. Tente novamente.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFFF1493),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperStyle: const TextStyle(color: Color(0xFFFFD700), fontSize: 11),
      labelStyle: const TextStyle(color: Color(0xFFFF1493)),
      prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFD700)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFF1493), width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1493).withValues(alpha: 0.15),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'REGISTRO DE DUELISTA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preencha seus dados para ingressar no Make Your Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Nome e Sobrenome lado a lado
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            style: const TextStyle(color: Colors.white),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                            decoration: _buildInputDecoration('Nome', Icons.badge),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            style: const TextStyle(color: Colors.white),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o sobrenome' : null,
                            decoration: _buildInputDecoration('Sobrenome', Icons.badge_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nome de Usuario
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe o nome de usuario';
                        if (v.trim().length < 3) return 'Minimo de 3 caracteres';
                        return null;
                      },
                      decoration: _buildInputDecoration('Nome de Usuario (Apelido)', Icons.alternate_email),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                        if (!v.contains('@') || !v.contains('.')) return 'Informe um e-mail valido';
                        return null;
                      },
                      decoration: _buildInputDecoration('E-mail', Icons.email),
                    ),
                    const SizedBox(height: 16),

                    // Data de Nascimento e Sexo lado a lado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: _birthDateController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            onTap: () => _selectBirthDate(context),
                            validator: (v) {
                              if (_selectedBirthDate == null || v == null || v.trim().isEmpty) {
                                return 'Informe a data';
                              }
                              final age = _calculatedAge;
                              if (age == null || age < 6) {
                                return 'Idade minima 6 anos';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Data de Nascimento',
                              helperText: _calculatedAge != null ? 'Idade: $_calculatedAge anos' : null,
                              helperStyle: const TextStyle(color: Color(0xFFFFD700), fontSize: 11),
                              labelStyle: const TextStyle(color: Color(0xFFFF1493)),
                              prefixIcon: const Icon(Icons.cake, color: Color(0xFFFFD700)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today, color: Color(0xFFFFD700)),
                                onPressed: () => _selectBirthDate(context),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFFD700)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFF1493), width: 2),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            dropdownColor: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(12),
                            elevation: 16,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration('Sexo', Icons.person_outline),
                            selectedItemBuilder: (context) {
                              return _genderOptions.map((gender) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    gender,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                );
                              }).toList();
                            },
                            items: _genderOptions.map((gender) {
                              final isSelected = gender == _selectedGender;
                              return DropdownMenuItem(
                                value: gender,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Color(0x22FFD700), width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getGenderIcon(gender),
                                        size: 18,
                                        color: isSelected ? const Color(0xFFFF1493) : const Color(0xFFFFD700),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          gender,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check, size: 16, color: Color(0xFFFF1493)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGender = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Origem no Jogo
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGameOrigin,
                      dropdownColor: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                      elevation: 16,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Origem no Jogo', Icons.sports_esports),
                      selectedItemBuilder: (context) {
                        return _gameOriginOptions.map((origin) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              origin,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          );
                        }).toList();
                      },
                      items: _gameOriginOptions.map((origin) {
                        final isSelected = origin == _selectedGameOrigin;
                        return DropdownMenuItem(
                          value: origin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0x22FFD700), width: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getGameOriginIcon(origin),
                                  size: 18,
                                  color: isSelected ? const Color(0xFFFF1493) : const Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    origin,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, size: 16, color: Color(0xFFFF1493)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGameOrigin = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe a senha';
                        if (v.length < 6) return 'Minimo de 6 caracteres';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: const TextStyle(color: Color(0xFFFF1493)),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFD700)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFFFFD700),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF1493), width: 2),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmar Senha
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirme sua senha';
                        if (v != _passwordController.text) return 'As senhas nao coincidem';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        labelStyle: const TextStyle(color: Color(0xFFFF1493)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFD700)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFFFFD700),
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF1493), width: 2),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Botao Criar Conta
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF1493),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _handleRegister,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'CRIAR CONTA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Link voltar para Login
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Ja possui uma conta? Voltar ao Login',
                          style: TextStyle(color: Color(0xFFFFD700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
