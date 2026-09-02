import 'package:flutter_test/flutter_test.dart';
import 'package:nirapod_ai/main.dart';

void main() {
  testWidgets('splash screen displays Nirapod AI branding', (tester) async {
    await tester.pumpWidget(const NirapodApp());

    expect(find.text('Nirapod AI'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Detect. Analyze. Protect.'), findsOneWidget);
  });
}
