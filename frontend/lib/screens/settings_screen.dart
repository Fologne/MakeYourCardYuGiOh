import '../widgets/responsive_form_row.dart';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;

  late DateTime _selectedBirthDate;
  late String _selectedGender;
  late String _selectedGameOrigin;
  late String _selectedPronoun;

  final List<String> _pronounOptions = [
    'Duelista',
    'Mestre',
    'Jogador',
    'Invocador',
  ];

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
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedBirthDate = user?.birthDate ?? DateTime(2000, 1, 1);

    final day = _selectedBirthDate.day.toString().padLeft(2, '0');
    final month = _selectedBirthDate.month.toString().padLeft(2, '0');
    final year = _selectedBirthDate.year.toString();
    _birthDateController = TextEditingController(text: '$day/$month/$year');

    _selectedGender = user?.gender ?? 'Prefiro nao informar';
    if (!_genderOptions.contains(_selectedGender)) {
      _selectedGender = 'Prefiro nao informar';
    }
    _selectedGameOrigin = user?.gameOrigin ?? 'TCG';
    if (!_gameOriginOptions.contains(_selectedGameOrigin)) {
      _selectedGameOrigin = 'TCG';
    }
    _selectedPronoun = user?.preferredPronoun ?? 'Duelista';
    if (!_pronounOptions.contains(_selectedPronoun)) {
      _selectedPronoun = 'Duelista';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
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

  IconData _getPronounIcon(String pronoun) {
    switch (pronoun) {
      case 'Mestre':
        return Icons.military_tech;
      case 'Jogador':
        return Icons.sports_esports;
      case 'Invocador':
        return Icons.auto_awesome;
      default:
        return Icons.shield;
    }
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _selectedBirthDate.year;
    if (now.month < _selectedBirthDate.month ||
        (now.month == _selectedBirthDate.month &&
            now.day < _selectedBirthDate.day)) {
      age--;
    }
    return age >= 0 ? age : 0;
  }

  // Abre seletor para alteracao de data de nascimento
  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
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

    if (picked != null && mounted) {
      setState(() {
        _selectedBirthDate = picked;
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year.toString();
        _birthDateController.text = '$day/$month/$year';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setState(() => _isSaving = false);
      return;
    }

    final UserModel updated = currentUser.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _selectedBirthDate,
      gender: _selectedGender,
      gameOrigin: _selectedGameOrigin,
      preferredPronoun: _selectedPronoun,
    );

    final success = await _authService.updateUserData(updated);

    if (!mounted) return;

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Dados atualizados com sucesso.'
              : (_authService.errorMessage ?? 'Falha ao atualizar os dados.'),
        ),
        backgroundColor: success
            ? const Color(0xFFFFD700)
            : const Color(0xFFFF1493),
      ),
    );
  }

  void _confirmDeactivateAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Desativar Conta',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Sua conta sera desativada temporariamente e sua sessao sera encerrada. Voce podera reativa-la fazendo login novamente no futuro.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1493),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(ctx);
              Navigator.pop(ctx);

              final success = await _authService.deactivateAccount();

              if (!mounted) return;

              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Conta desativada. Faca login para reativa-la.',
                    ),
                    backgroundColor: Color(0xFFFF1493),
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      _authService.errorMessage ??
                          'Falha ao desativar a conta.',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Apagar Conta Definitivamente',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'ATENCAO: Esta acao e irreversivel. Seu cadastro sera permanentemente excluido do sistema.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(ctx);
              Navigator.pop(ctx);

              final success = await _authService.deleteAccount();

              if (!mounted) return;

              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Conta excluida definitivamente.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      _authService.errorMessage ?? 'Falha ao excluir a conta.',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Excluir Definitivamente'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildFieldDecoration(
    String label,
    IconData icon, {
    String? helperText,
  }) {
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
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Configuracoes e Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Secao 1: Identificacao fixa da conta
                  _buildSectionHeader('Identificacao da Conta', Icons.badge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'ID da Conta',
                          user?.accountId ?? 'MYC-000000',
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        _buildInfoRow('Nome de Usuario', user?.username ?? '-'),
                        const Divider(color: Colors.white24, height: 20),
                        _buildInfoRow('Plano Atual', user?.plan ?? 'Gratuito'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Secao 2: Dados cadastrais alteraveis
                  _buildSectionHeader('Dados do Perfil', Icons.person),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ResponsiveFormRow(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(color: Colors.white),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Informe o nome'
                                    : null,
                                decoration: _buildFieldDecoration(
                                  'Nome',
                                  Icons.badge,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(color: Colors.white),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Informe o sobrenome'
                                    : null,
                                decoration: _buildFieldDecoration(
                                  'Sobrenome',
                                  Icons.badge_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'E-mail invalido'
                              : null,
                          decoration: _buildFieldDecoration(
                            'E-mail',
                            Icons.email,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ResponsiveFormRow(
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
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Informe a data';
                                  }
                                  if (_calculatedAge < 6) {
                                    return 'Idade minima 6 anos';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Data de Nascimento',
                                  helperText: 'Idade: $_calculatedAge anos',
                                  helperStyle: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 11,
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFFF1493),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.cake,
                                    color: Color(0xFFFFD700),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFFFFD700),
                                    ),
                                    onPressed: () => _selectBirthDate(context),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFFFD700),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFFF1493),
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(12),
                                elevation: 16,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFFFD700),
                                ),
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildFieldDecoration(
                                  'Sexo',
                                  Icons.person_outline,
                                ),
                                selectedItemBuilder: (context) {
                                  return _genderOptions.map((g) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        g,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                items: _genderOptions.map((g) {
                                  final isSelected = g == _selectedGender;
                                  return DropdownMenuItem(
                                    value: g,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0x22FFD700),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getGenderIcon(g),
                                            size: 18,
                                            color: isSelected
                                                ? const Color(0xFFFF1493)
                                                : const Color(0xFFFFD700),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              g,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? const Color(0xFFFFD700)
                                                    : Colors.white,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Color(0xFFFF1493),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedGender = v);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGameOrigin,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 16,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFFFFD700),
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildFieldDecoration(
                            'Origem no Jogo',
                            Icons.sports_esports,
                          ),
                          selectedItemBuilder: (context) {
                            return _gameOriginOptions.map((orig) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  orig,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items: _gameOriginOptions.map((orig) {
                            final isSelected = orig == _selectedGameOrigin;
                            return DropdownMenuItem(
                              value: orig,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 2,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0x22FFD700),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getGameOriginIcon(orig),
                                      size: 18,
                                      color: isSelected
                                          ? const Color(0xFFFF1493)
                                          : const Color(0xFFFFD700),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        orig,
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFFFFD700)
                                              : Colors.white,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0xFFFF1493),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedGameOrigin = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Secao 3: Preferencias e Forma de Tratamento
                  _buildSectionHeader(
                    'Forma de Tratamento',
                    Icons.record_voice_over,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Como o sistema deve se referir a voce:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPronoun,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 16,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFFFFD700),
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildFieldDecoration(
                            'Tratamento',
                            Icons.label,
                          ),
                          selectedItemBuilder: (context) {
                            return _pronounOptions.map((p) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          items: _pronounOptions.map((p) {
                            final isSelected = p == _selectedPronoun;
                            return DropdownMenuItem(
                              value: p,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 2,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0x22FFD700),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getPronounIcon(p),
                                      size: 18,
                                      color: isSelected
                                          ? const Color(0xFFFF1493)
                                          : const Color(0xFFFFD700),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        p,
                                        style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFFFFD700)
                                              : Colors.white,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Color(0xFFFF1493),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedPronoun = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botao de salvar alteracoes
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: const Text(
                        'SALVAR ALTERACOES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Secao 4: Zona de Acoes Criticas (Conta)
                  _buildSectionHeader(
                    'Zona de Seguranca da Conta',
                    Icons.security,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF1493),
                            side: const BorderSide(color: Color(0xFFFF1493)),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: _confirmDeactivateAccount,
                          child: const Text('Desativar Conta Temporariamente'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: _confirmDeleteAccount,
                          child: const Text('Apagar Conta Definitivamente'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
