import 'package:campus_event_explorer/main.dart';
import 'package:campus_event_explorer/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openEvent(WidgetTester tester, String title) async {
  await tester.enterText(find.byKey(const Key('search-field')), title);
  await tester.pumpAndSettle();
  expect(find.byType(EventCard), findsOneWidget);
  await tester.tap(find.byType(EventCard));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty search shows a message and can be cleared',
      (tester) async {
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.enterText(find.byKey(const Key('search-field')), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-search')), findsOneWidget);
    expect(find.text('0 matching events'), findsOneWidget);

    await tester.tap(find.text('Clear search and filters'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('empty-search')), findsNothing);
    expect(find.text('10 matching events'), findsOneWidget);
  });

  testWidgets('full event shows Full and cannot be joined', (tester) async {
    await tester.pumpWidget(const CampusEventExplorerApp());
    await _openEvent(tester, 'AI Ethics Panel');

    final button =
        tester.widget<ButtonStyleButton>(find.byKey(const Key('full-button')));
    expect(button.onPressed, isNull);
    expect(find.text('Full'), findsOneWidget);
  });

  testWidgets('join with Yes, then cancel dialog with No keeps state',
      (tester) async {
    await tester.pumpWidget(const CampusEventExplorerApp());
    await _openEvent(tester, 'Watercolor Painting Workshop');

    // Join the last place.
    await tester.tap(find.byKey(const Key('join-button')));
    await tester.pumpAndSettle();
    expect(find.text('Join this event?'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Full'), findsOneWidget);
    expect(find.byKey(const Key('cancel-button')), findsOneWidget);

    // Cancel dialog: "No" leaves the data unchanged.
    await tester.tap(find.byKey(const Key('cancel-button')));
    await tester.pumpAndSettle();
    expect(find.text('Cancel participation?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cancel-button')), findsOneWidget);

    // Cancel with "Yes" restores one place.
    await tester.tap(find.byKey(const Key('cancel-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Only 1 place left'), findsOneWidget);
    expect(find.byKey(const Key('join-button')), findsOneWidget);
  });

  testWidgets('dismissing join dialog changes nothing; double-tap enlarges',
      (tester) async {
    await tester.pumpWidget(const CampusEventExplorerApp());
    await _openEvent(tester, 'Campus Jazz Night');

    await tester.tap(find.byKey(const Key('join-button')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // outside the dialog
    await tester.pumpAndSettle();
    expect(find.text('Join this event?'), findsNothing);
    expect(find.text('85 places left'), findsOneWidget);
    expect(find.byKey(const Key('join-button')), findsOneWidget);

    final image = find.byKey(const Key('details-image'));
    await tester.tap(image);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(image);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('enlarged-image')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Event Details'), findsOneWidget);
  });

  testWidgets('favorite from card appears in Favorites view', (tester) async {
    await tester.pumpWidget(const CampusEventExplorerApp());
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('empty-favorites')), findsOneWidget);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fav-evt-01')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter Workshop for Beginners'), findsOneWidget);
    expect(find.text('1 matching event'), findsOneWidget);
  });
}
