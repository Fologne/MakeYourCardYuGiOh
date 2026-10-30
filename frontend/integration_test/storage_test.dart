import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('armazenamento protegido grava, le e apaga no dispositivo', (
    tester,
  ) async {
    const storage = FlutterSecureStorage();
    final key = 'myc_storage_test_${DateTime.now().microsecondsSinceEpoch}';
    try {
      await storage.write(key: key, value: 'temporary-test-value');
      expect(await storage.read(key: key), 'temporary-test-value');
      await storage.delete(key: key);
      expect(await storage.read(key: key), isNull);
    } finally {
      await storage.delete(key: key);
    }
  });
}
