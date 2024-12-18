import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/presentation/screens/home_screen.dart';
import 'package:word_explorer/presentation/screens/game_screen.dart';

void main() {
  testWidgets('HomeScreen navigates to GameScreen with correct parameters',
      (WidgetTester tester) async {
    // Arrange: Lade den HomeScreen in einen MaterialApp-Wrapper
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // Wähle Dropdown-Werte aus
    await tester.tap(find.byType(DropdownButton<int>)); // Klasse
    await tester.pumpAndSettle();
    await tester.tap(find.text('6').last); // Wähle "Klasse 6"
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first); // Thema
    await tester.pumpAndSettle();
    await tester.tap(find.text('school').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).last); // Wortart
    await tester.pumpAndSettle();
    await tester.tap(find.text('noun').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton).last); // Schwierigkeit
    await tester.pumpAndSettle();
    await tester.tap(find.text('medium').last);
    await tester.pumpAndSettle();

    // Act: Drücke den "Spiel Starten"-Button
    await tester.tap(find.text('Spiel Starten'));
    await tester.pumpAndSettle();

    // Assert: Überprüfe, ob GameScreen geöffnet wurde und die Parameter korrekt sind
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Klasse 6'), findsOneWidget);
    expect(find.text('school'), findsOneWidget);
    expect(find.text('noun'), findsOneWidget);
    expect(find.text('medium'), findsOneWidget);
  });
}
