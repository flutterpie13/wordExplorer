import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/presentation/widgets/flip_card.dart';

void main() {
  group('FlipCard Widget', () {
    testWidgets('should display the back of the card by default',
        (WidgetTester tester) async {
      // Arrange: Erstelle das Widget mit Standardwerten
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              frontContent: 'Front Content',
              isFlipped: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert: Die Rückseite der Karte sollte angezeigt werden
      expect(find.text('BACK'), findsOneWidget);
      expect(find.text('Front Content'), findsNothing);
    });

    testWidgets('should display the front of the card when flipped',
        (WidgetTester tester) async {
      // Arrange: Erstelle das Widget mit umgedrehter Karte
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              frontContent: 'Front Content',
              isFlipped: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Act: Starte die Animation
      await tester.pumpAndSettle();

      // Assert: Die Vorderseite der Karte sollte angezeigt werden
      expect(find.text('Front Content'), findsOneWidget);
      expect(find.text('BACK'), findsNothing);
    });

    testWidgets('should trigger onTap callback when tapped',
        (WidgetTester tester) async {
      // Arrange: Mock-Funktion für die Tap-Aktion
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCard(
              frontContent: 'Front Content',
              isFlipped: false,
              onTap: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      // Act: Führe die Tap-Geste aus
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();

      // Assert: Die Tap-Aktion sollte ausgelöst werden
      expect(isTapped, isTrue);
    });

    testWidgets('should toggle between front and back content on flip state',
        (WidgetTester tester) async {
      // Arrange: Widget initialisieren
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              bool isFlipped = false;
              return Scaffold(
                body: Center(
                  child: FlipCard(
                    frontContent: 'Front Content',
                    isFlipped: isFlipped,
                    onTap: () {
                      setState(() {
                        isFlipped = !isFlipped;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Act & Assert: Anfangszustand überprüfen
      expect(find.text('BACK'), findsOneWidget);
      expect(find.text('Front Content'), findsNothing);

      // Karte umdrehen
      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle(); // Warte auf Animation

      // Überprüfe, ob die Vorderseite angezeigt wird
      expect(find.text('Front Content'), findsOneWidget);
      expect(find.text('BACK'), findsNothing);
    });
  });
}
