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

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _selectedBirthDate.year;
    if (now.month < _selectedBirthDate.month ||
        (now.month == _selectedBirthDate.month && now.day < _selectedBirthDate.day)) {
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

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final UserModel updated = currentUser.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _selectedBirthDate,
      gender: _selectedGender,
      gameOrigin: _selectedGameOrigin,
      preferredPronoun: _selectedPronoun,
    );

    _authService.updateUserData(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados atualizados com sucesso.'),
        backgroundColor: Color(0xFFFFD700),
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
          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
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
            onPressed: () {
              Navigator.pop(ctx);
              _authService.deactivateAccount();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conta desativada com sucesso.'),
                  backgroundColor: Color(0xFFFF1493),
                ),
              );
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
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'ATENCAO: Esta acao e irreversivel. Todos os seus dados, cartas e decks serao permanentemente excluidos do sistema.',
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
            onPressed: () {
              Navigator.pop(ctx);
              _authService.deleteAccount();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conta excluida definitivamente.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Excluir Definitivamente'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildFieldDecoration(String label, IconData icon, {String? helperText}) {
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
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('ID da Conta', user?.accountId ?? 'MYC-000000'),
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
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(color: Colors.white),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                                decoration: _buildFieldDecoration('Nome', Icons.badge),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(color: Colors.white),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o sobrenome' : null,
                                decoration: _buildFieldDecoration('Sobrenome', Icons.badge_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          validator: (v) => (v == null || !v.contains('@')) ? 'E-mail invalido' : null,
                          decoration: _buildFieldDecoration('E-mail', Icons.email),
                        ),
                        const SizedBox(height: 16),
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
                                  if (v == null || v.trim().isEmpty) return 'Informe a data';
                                  if (_calculatedAge < 6) return 'Idade minima 6 anos';
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Data de Nascimento',
                                  helperText: 'Idade: $_calculatedAge anos',
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
                                dropdownColor: const Color(0xFF1F1F1F),
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildFieldDecoration('Sexo', Icons.person_outline),
                                items: _genderOptions.map((g) {
                                  return DropdownMenuItem(value: g, child: Text(g));
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedGender = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGameOrigin,
                          dropdownColor: const Color(0xFF1F1F1F),
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildFieldDecoration('Origem no Jogo', Icons.sports_esports),
                          items: _gameOriginOptions.map((orig) {
                            return DropdownMenuItem(value: orig, child: Text(orig));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedGameOrigin = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Secao 3: Preferencias e Forma de Tratamento
                  _buildSectionHeader('Forma de Tratamento', Icons.record_voice_over),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
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
                          dropdownColor: const Color(0xFF1F1F1F),
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildFieldDecoration('Tratamento', Icons.label),
                          items: _pronounOptions.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p));
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
                      onPressed: _saveProfile,
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
                  _buildSectionHeader('Zona de Seguranca da Conta', Icons.security),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
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
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
