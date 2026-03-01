import 'package:flutter_test/flutter_test.dart';

import 'package:bomber/main.dart';

void main() {
  testWidgets('navigates from splash to stats and into game', (tester) async {
    await tester.pumpWidget(const LogicBombApp());

    expect(find.text('Logic Bomb'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.text('Score'), findsOneWidget);
  });
}
