import 'package:fantasy/features/picks/presentation/widgets/error_message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('active error view displays its message and invokes retry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessageView(
            icon: Icons.cloud_off_outlined,
            message: 'Unable to load data',
            actionLabel: 'Try again',
            onAction: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Unable to load data'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });
}
