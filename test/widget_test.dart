import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_bottle/main.dart';

void main() {
  testWidgets('Aquarium app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AquaApp());
    expect(find.byType(AquaApp), findsOneWidget);
  });
}
