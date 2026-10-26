import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Controlador da animação de flutuação (dura 10 segundos e fica em loop)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo Preto Base
          Container(color: Colors.black),
          
          // Cartas Flutuantes no fundo
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
          
          // Efeito de Vidro/Desfoque sobre as cartas
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.6), // Escurece o fundo desfocado
            ),
          ),
          
          // Formulário de Login (Conteúdo Principal)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.85),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'MAKE YOUR CARD',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: const TextStyle(color: Color(0xFFFF1493)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF1493)),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: const TextStyle(color: Color(0xFFFF1493)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFD700)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF1493)),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFD700)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _login(context),
                      child: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Não possui conta? Registre-se',
                        style: TextStyle(color: Color(0xFFFF1493)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir as cartas flutuantes
  Widget _buildFloatingCard(double left, double top, double rotation, double moveY, double scale) {
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