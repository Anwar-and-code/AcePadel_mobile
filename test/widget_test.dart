import 'package:flutter_test/flutter_test.dart';
import 'package:acepadel/main.dart';

void main() {
  testWidgets('AcePadel app starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AcePadelApp());
    
    // Verify the logo is displayed on splash screen
    expect(find.text('acepadel'), findsOneWidget);
  });
}
