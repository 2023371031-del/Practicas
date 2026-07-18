import 'package:flutter_test/flutter_test.dart';

import 'package:ble_werable_app/main.dart';

void main() {
  testWidgets('App renders BLE scanner screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BleWearableApp());
    expect(find.text('Escáner BLE'), findsOneWidget);
  });
}
