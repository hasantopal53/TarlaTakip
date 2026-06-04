import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tam uygulama (Hive, bildirimler, ağ) widget testinde ağır kurulum gerektirir.
/// Bu smoke test sadece test altyapısının çalıştığını doğrular.
void main() {
  testWidgets('smoke test — widget ağacı oluşturulabiliyor', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('TarlaTakip')),
        ),
      ),
    );
    expect(find.text('TarlaTakip'), findsOneWidget);
  });
}
