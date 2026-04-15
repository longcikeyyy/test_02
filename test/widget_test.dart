import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_02/app.dart';
import 'package:test_02/features/auth/presentation/providers/auth_provider.dart';

void main() {
  testWidgets('Shows login screen when not authenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthCubit(),
        child: const PosApp(),
      ),
    );

    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
