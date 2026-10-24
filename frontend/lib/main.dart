import 'package:flutter/material.dart';

void main() {
  runApp(const MakeYourCardApp());
}

class MakeYourCardApp extends StatelessWidget {
  const MakeYourCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make Your Card',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700), // Dourado
          secondary: Color(0xFFFF1493), // Rosa
          surface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Color(0xFFFFD700)),
          titleTextStyle: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      // Define a rota inicial
      initialRoute: '/login',
      routes: {
        '/login': (context) => const PlaceholderScreen(title: 'Login'),
        '/register': (context) => const PlaceholderScreen(title: 'Registro'),
        '/dashboard': (context) => const PlaceholderScreen(title: 'Dashboard'),
      },
    );
  }
}

// Tela temporaria para validar a navegacao e o tema
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Construcao da tela: $title',
          style: const TextStyle(
            color: Color(0xFFFF1493), 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}