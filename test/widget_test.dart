import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_02/app.dart';

void main() {
  testWidgets('Shows login screen when not authenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PosApp()));

    expect(find.text('POS Login'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
