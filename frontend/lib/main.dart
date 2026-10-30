import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restaura a sessao salva antes de montar a interface
  await AuthService().initialize();
  runApp(const MakeYourCardApp());
}

class MakeYourCardApp extends StatelessWidget {
  const MakeYourCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return ListenableBuilder(
      listenable: authService,
      builder: (context, child) => MaterialApp(
        key: ValueKey(authService.isAuthenticated),
        title: 'Make Your Card',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            secondary: Color(0xFFFF1493),
            surface: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            iconTheme: IconThemeData(color: Color(0xFFFFD700)),
            titleTextStyle: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: authService.isAuthenticated ? '/dashboard' : '/login',
        onGenerateInitialRoutes: (name) => [
          MaterialPageRoute(
            settings: RouteSettings(name: name),
            builder: (_) => authService.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen(),
          ),
        ],
        onGenerateRoute: (settings) {
          // Rotas publicas
          if (settings.name == '/login') {
            if (authService.isAuthenticated) {
              return MaterialPageRoute(builder: (_) => const DashboardScreen());
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          }

          if (settings.name == '/register') {
            if (authService.isAuthenticated) {
              return MaterialPageRoute(builder: (_) => const DashboardScreen());
            }
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          }

          // Rotas protegidas (exigem autenticacao ativa)
          final protectedRoutes = [
            '/dashboard',
            '/settings',
            '/create_card',
            '/deckbuilder',
            '/archetypes',
            '/simulator',
          ];

          if (protectedRoutes.contains(settings.name)) {
            if (!authService.isAuthenticated) {
              // Bloqueio de rota: redireciona usuario nao autenticado para login
              return MaterialPageRoute(
                builder: (ctx) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Acesso restrito. Efetue login para continuar.',
                        ),
                        backgroundColor: Color(0xFFFF1493),
                      ),
                    );
                  });
                  return const LoginScreen();
                },
              );
            }

            if (settings.name == '/dashboard') {
              return MaterialPageRoute(builder: (_) => const DashboardScreen());
            }
            if (settings.name == '/settings') {
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            }
          }

          // Rota padrao de fallback caso nao encontrada
          return MaterialPageRoute(
            builder: (_) => authService.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
