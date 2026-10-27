import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService().logout();
  });

  testWidgets('Valida renderizacao da tela de Login inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pumpAndSettle();

    // Verifica elementos fundamentais da tela de login
    expect(find.text('MAKE YOUR CARD'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('Nao possui conta? Registre-se'), findsOneWidget);
  });

  testWidgets('Valida navegacao para tela de Registro', (WidgetTester tester) async {
    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pumpAndSettle();

    // Clica no botao de registro
    await tester.tap(find.text('Nao possui conta? Registre-se'));
    await tester.pumpAndSettle();

    // Verifica elementos da tela de registro
    expect(find.text('REGISTRO DE DUELISTA'), findsOneWidget);
    expect(find.text('CRIAR CONTA'), findsOneWidget);
  });

  testWidgets('Valida bloqueio de rota para usuario nao autenticado', (WidgetTester tester) async {
    final authService = AuthService();
    authService.logout();

    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pumpAndSettle();

    // Tenta navegar diretamente para rota protegida
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/dashboard');
    await tester.pumpAndSettle();

    // Deve permanecer ou ser redirecionado para Login
    expect(find.text('ENTRAR'), findsOneWidget);
  });
}
