import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Controlador da animacao de flutuacao
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await _authService.login(
      _identifierController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais invalidas. Verifique seus dados.'),
          backgroundColor: Color(0xFFFF1493),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo preto base
          Container(color: Colors.black),

          // Cartas flutuantes no fundo
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildFloatingCard(-50, 100, 0.2, -15, 0.4),
                  _buildFloatingCard(250, 50, -0.1, 10, 0.3),
                  _buildFloatingCard(100, 400, 0.3, -5, 0.5),
                  _buildFloatingCard(-100, 600, -0.2, 20, 0.3),
                  _buildFloatingCard(300, 700, 0.1, -10, 0.4),
                ],
              );
            },
          ),

          // Efeito de vidro sobre as cartas
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),

          // Formulario de login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A).withValues(alpha: 0.88),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1493).withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MAKE YOUR CARD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Acesse sua conta para duelar e criar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Campo Email / Usuario
                        TextFormField(
                          controller: _identifierController,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe seu e-mail ou usuario';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'E-mail ou Usuario',
                            labelStyle: TextStyle(color: Color(0xFFFF1493)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFFD700)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFF1493), width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.redAccent, width: 2),
                            ),
                            prefixIcon: Icon(Icons.person, color: Color(0xFFFFD700)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo Senha
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe sua senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve conter ao menos 6 caracteres';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: const TextStyle(color: Color(0xFFFF1493)),
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
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFD700)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFFFD700),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Botao de login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _handleLogin,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Link para Registro
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Nao possui conta? Registre-se',
                            style: TextStyle(
                              color: Color(0xFFFF1493),
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  // Widget auxiliar para construir cartas flutuantes no fundo
  Widget _buildFloatingCard(
    double left,
    double top,
    double rotation,
    double moveY,
    double scale,
  ) {
    final offset = _controller.value * (moveY * 15);
    final dynamicRotation = rotation * math.pi + (_controller.value * 0.15);

    return Positioned(
      left: left,
      top: top + offset,
      child: Transform.rotate(
        angle: dynamicRotation,
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            'assets/images/card_back.png',
            width: 250,
            height: 360,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 250,
              height: 360,
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }
}
