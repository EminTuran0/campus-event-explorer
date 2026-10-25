// Renders README screenshots into screenshots/ with the real fonts.
// Regenerate with:  flutter test test/screenshots_test.dart --update-goldens
import 'dart:io';

import 'package:campus_event_explorer/main.dart';
import 'package:campus_event_explorer/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _loadFont('Poppins', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
        'assets/fonts/Poppins-$w.ttf',
    ]);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  });

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/$name.png'),
    );
  }

  testWidgets('screenshots', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      await tester.pumpWidget(const CampusEventExplorerApp());
      for (final e in tester.elementList(find.byType(Image))) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await shot(tester, 'explore');

    // Favorite two events from the cards.
    await tester.tap(find.byKey(const Key('fav-evt-01')));
    await tester.pumpAndSettle();

    // Join the last place of the watercolor workshop.
    await tester.enterText(find.byKey(const Key('search-field')), 'water');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(EventCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('details-fav')));
    await tester.tap(find.byKey(const Key('join-button')));
    await tester.pumpAndSettle();
    await shot(tester, 'join_dialog');
    await tester.tap(find.text('Yes'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await shot(tester, 'details');

    await tester.tap(find.byKey(const Key('cancel-button')));
    await tester.pumpAndSettle();
    await shot(tester, 'cancel_dialog');
    await tester.tap(find.text('No'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('clear-search')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await shot(tester, 'favorites');

    await tester.tap(find.text('My Events'));
    await tester.pumpAndSettle();
    await shot(tester, 'my_events');

    await tester.tap(find.text('Explore'));
    await tester.enterText(find.byKey(const Key('search-field')), 'ai ethics');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(EventCard));
    await tester.pumpAndSettle();
    await shot(tester, 'full_event');

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-field')), 'zzzz');
    await tester.pumpAndSettle();
    await shot(tester, 'empty_search');
  });
}
