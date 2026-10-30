import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';

const user = {
  'id': 'id',
  'accountId': 'MYC-123456',
  'username': 'teste',
  'email': 'teste@example.com',
  'firstName': 'Teste',
  'lastName': 'Usuario',
  'birthDate': '2000-01-01',
  'gender': 'Outro',
  'gameOrigin': 'TCG',
  'preferredPronoun': 'Duelista',
};
http.Response ok(Map<String, dynamic> data) =>
    http.Response(jsonEncode(data), 200);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await AuthService().logout();
  });
  tearDown(() async {
    await AuthService().logout();
    ApiService().setClient(http.Client());
  });

  test('migra sessao antiga e remove token das preferencias', () async {
    SharedPreferences.setMockInitialValues({
      'myc_access_token': 'legacy',
      'myc_current_user': jsonEncode(user),
    });
    ApiService().setClient(MockClient((_) async => ok({'user': user})));
    await AuthService().initialize();
    await Future<void>.delayed(Duration.zero);
    const storage = FlutterSecureStorage();
    expect(await storage.read(key: 'myc_access_token'), 'legacy');
    expect(
      (await SharedPreferences.getInstance()).getString('myc_access_token'),
      isNull,
    );
  });

  test('401 limpa sessao; 500 preserva sessao para nova tentativa', () async {
    var status = 200;
    ApiService().setClient(
      MockClient(
        (_) async => status == 200
            ? ok({'success': true, 'token': 'valid', 'user': user})
            : http.Response('{"message":"Falha"}', status),
      ),
    );
    expect(await AuthService().login('teste', '123456'), isTrue);
    status = 500;
    await expectLater(
      ApiService().get('/auth/me', token: 'valid'),
      throwsA(isA<ApiException>()),
    );
    expect(AuthService().isAuthenticated, isTrue);
    status = 401;
    await expectLater(
      ApiService().get('/auth/me', token: 'valid'),
      throwsA(isA<ApiException>()),
    );
    expect(AuthService().isAuthenticated, isFalse);
    expect(
      await const FlutterSecureStorage().read(key: 'myc_access_token'),
      isNull,
    );
  });

  test('resposta antiga nao sobrescreve usuario de novo login', () async {
    final pending = Completer<http.Response>();
    FlutterSecureStorage.setMockInitialValues({
      'myc_access_token': 'old',
      'myc_current_user': jsonEncode(user),
    });
    ApiService().setClient(
      MockClient(
        (request) async => request.method == 'GET'
            ? pending.future
            : ok({
                'success': true,
                'token': 'new',
                'user': {...user, 'username': 'novo'},
              }),
      ),
    );
    await AuthService().initialize();
    await AuthService().login('novo', '123456');
    pending.complete(ok({'user': user}));
    await Future<void>.delayed(Duration.zero);
    expect(AuthService().currentUser!.username, 'novo');
    expect(AuthService().token, 'new');
  });

  testWidgets('expiracao remove configuracoes e historico de rotas privadas', (
    tester,
  ) async {
    ApiService().setClient(
      MockClient(
        (_) async => ok({'success': true, 'token': 'valid', 'user': user}),
      ),
    );
    await tester.runAsync(() => AuthService().login('teste', '123456'));
    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Configuracoes e Perfil'), findsOneWidget);
    ApiService().setClient(
      MockClient((_) async => http.Response('{"message":"Expirada"}', 401)),
    );
    await tester.runAsync(
      () => expectLater(
        ApiService().get('/auth/me', token: 'valid'),
        throwsA(isA<ApiException>()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('Configuracoes e Perfil'), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets('perfil atualizado aparece no dashboard sem reiniciar', (
    tester,
  ) async {
    ApiService().setClient(
      MockClient(
        (request) async => request.method == 'PUT'
            ? ok({
                'success': true,
                'user': {...user, 'preferredPronoun': 'Mestre'},
              })
            : ok({'success': true, 'token': 'valid', 'user': user}),
      ),
    );
    await tester.runAsync(() => AuthService().login('teste', '123456'));
    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => AuthService().updateUserData(
        AuthService().currentUser!.copyWith(preferredPronoun: 'Mestre'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ola, Mestre teste'), findsOneWidget);
  });

  testWidgets('registro em 320px e configuracoes com fonte ampliada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pump();
    await tester.tap(find.text('Nao possui conta? Registre-se'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    ApiService().setClient(
      MockClient(
        (_) async => ok({'success': true, 'token': 'valid', 'user': user}),
      ),
    );
    await tester.runAsync(() => AuthService().login('teste', '123456'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('salvar perfil duas vezes envia apenas uma requisicao', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var updates = 0;
    ApiService().setClient(
      MockClient((request) async {
        if (request.method == 'PUT') {
          updates++;
          return pending.future;
        }
        return ok({'success': true, 'token': 'valid', 'user': user});
      }),
    );
    await tester.runAsync(() => AuthService().login('teste', '123456'));
    await tester.pumpWidget(const MakeYourCardApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('SALVAR ALTERACOES'));
    await tester.tap(find.text('SALVAR ALTERACOES'));
    await tester.tap(find.text('SALVAR ALTERACOES'));
    await tester.pump();
    expect(updates, 1);
    await tester.runAsync(() async {
      pending.complete(ok({'success': true, 'user': user}));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.text('Dados atualizados com sucesso.'), findsOneWidget);
  });
}
