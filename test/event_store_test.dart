import 'package:campus_event_explorer/data/events_data.dart';
import 'package:campus_event_explorer/models/campus_event.dart';
import 'package:campus_event_explorer/state/event_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event data', () {
    test('has at least six events in at least three categories', () {
      expect(campusEvents.length, greaterThanOrEqualTo(6));
      final categories = campusEvents.map((e) => e.category).toSet();
      expect(categories.length, greaterThanOrEqualTo(3));
    });

    test('IDs are unique', () {
      final ids = campusEvents.map((e) => e.id).toSet();
      expect(ids.length, campusEvents.length);
    });

    test('one full event and one event with exactly one place', () {
      expect(campusEvents.where((e) => e.initialAvailablePlaces == 0),
          isNotEmpty);
      expect(campusEvents.where((e) => e.initialAvailablePlaces == 1),
          isNotEmpty);
    });

    test('dates are after the deadline and places are within capacity', () {
      final deadline = DateTime(2026, 10, 25, 23, 59);
      for (final e in campusEvents) {
        expect(e.dateTime.isAfter(deadline), isTrue, reason: e.id);
        expect(e.initialAvailablePlaces, inInclusiveRange(0, e.capacity));
      }
    });

    test('uses at least three distinct images', () {
      expect(campusEvents.map((e) => e.imagePath).toSet().length,
          greaterThanOrEqualTo(3));
    });
  });

  group('EventStore', () {
    late EventStore store;
    setUp(() => store = EventStore(campusEvents));

    test('join decreases places once; repeated join creates no duplicate', () {
      const id = 'evt-01';
      final before = store.availablePlaces(id);
      expect(store.join(id), JoinResult.joined);
      expect(store.join(id), JoinResult.alreadyJoined);
      expect(store.availablePlaces(id), before - 1);
      expect(store.joinedCount, 1);
    });

    test('full event cannot be joined', () {
      expect(store.join('evt-02'), JoinResult.full);
      expect(store.availablePlaces('evt-02'), 0);
      expect(store.isJoined('evt-02'), isFalse);
    });

    test('last place: join makes it full, cancel restores one place', () {
      const id = 'evt-04';
      expect(store.join(id), JoinResult.joined);
      expect(store.isFull(id), isTrue);
      expect(store.cancel(id), isTrue);
      expect(store.availablePlaces(id), 1);
      expect(store.isJoined(id), isFalse);
    });

    test('cancel without joining changes nothing', () {
      expect(store.cancel('evt-05'), isFalse);
      expect(store.availablePlaces('evt-05'), 85);
    });

    test('favorites do not change participation or capacity', () {
      store.toggleFavorite('evt-03');
      expect(store.isFavorite('evt-03'), isTrue);
      expect(store.availablePlaces('evt-03'), 18);
      expect(store.isJoined('evt-03'), isFalse);
      store.toggleFavorite('evt-03');
      expect(store.isFavorite('evt-03'), isFalse);
    });

    test('search ignores case and surrounding spaces', () {
      final result = store.filter(query: '   jAzZ  ');
      expect(result.map((e) => e.id), ['evt-05']);
    });

    test('search and category filter work together', () {
      expect(
        store.filter(query: 'workshop', category: EventCategory.arts)
            .map((e) => e.id),
        ['evt-04'],
      );
      expect(
        store.filter(query: 'workshop', category: EventCategory.sports),
        isEmpty,
      );
    });

    test('favorites and joined filters', () {
      store.toggleFavorite('evt-07');
      store.join('evt-08');
      expect(store.filter(onlyFavorites: true).map((e) => e.id), ['evt-07']);
      expect(store.filter(onlyJoined: true).map((e) => e.id), ['evt-08']);
    });
  });
}
