import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Alpha shell shows Kindred navigation and daily question', (
    tester,
  ) async {
    await tester.pumpWidget(const KindredApp());
    expect(find.text('Kindred'), findsOneWidget);
    expect(find.text('Today’s question'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
  });

  testWidgets('user can open the create tab', (tester) async {
    await tester.pumpWidget(const KindredApp());
    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    expect(find.text('Give a memory a place to live.'), findsOneWidget);
    expect(find.text('Share a story'), findsOneWidget);
  });
}
