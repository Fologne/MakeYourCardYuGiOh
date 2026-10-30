import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await AuthService().logout();
  });

  // A tela de login tem animacao continua, por isso nao usamos pumpAndSettle
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('Valida renderizacao da tela de Login inicial', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MakeYourCardApp());
    await settle(tester);

    // Verifica elementos fundamentais da tela de login
    expect(find.text('MAKE YOUR CARD'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('Nao possui conta? Registre-se'), findsOneWidget);
  });

  testWidgets('Valida navegacao para tela de Registro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MakeYourCardApp());
    await settle(tester);

    // Clica no botao de registro
    await tester.tap(find.text('Nao possui conta? Registre-se'));
    await settle(tester);

    // Verifica elementos da tela de registro
    expect(find.text('REGISTRO DE DUELISTA'), findsOneWidget);
    expect(find.text('CRIAR CONTA'), findsOneWidget);
  });

  testWidgets('Valida bloqueio de rota para usuario nao autenticado', (
    WidgetTester tester,
  ) async {
    final authService = AuthService();
    await authService.logout();

    await tester.pumpWidget(const MakeYourCardApp());
    await settle(tester);

    // Tenta navegar diretamente para rota protegida
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/dashboard');
    await settle(tester);

    // Deve permanecer ou ser redirecionado para Login
    expect(find.text('ENTRAR'), findsOneWidget);
  });
}
