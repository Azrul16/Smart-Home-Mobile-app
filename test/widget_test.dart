import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_app/src/widgets/status_toggle_switch.dart';

void main() {
  testWidgets('status toggle renders labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatusToggleSwitch(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('ON'), findsOneWidget);
  });
}
