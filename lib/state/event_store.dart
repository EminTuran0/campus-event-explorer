import 'dart:math';

import '../models/campus_event.dart';

/// Result of trying to join an event.
enum JoinResult { joined, alreadyJoined, full }

/// In-memory app state: available places, favorites and joined events.
///
/// This is a plain Dart class. The widget that owns it ([HomeScreen]) calls
/// `setState` after every change, so no state-management library is used.
/// Data lives only for one app session.
class EventStore {
  EventStore(List<CampusEvent> events)
    : events = List.unmodifiable(events),
      _available = {for (final e in events) e.id: e.initialAvailablePlaces};

  final List<CampusEvent> events;
  final Map<String, int> _available;
  final Set<String> _favoriteIds = {};
  final Set<String> _joinedIds = {};

  CampusEvent byId(String id) => events.firstWhere((e) => e.id == id);

  int availablePlaces(String id) => _available[id]!;
  bool isFull(String id) => availablePlaces(id) == 0;
  bool isFavorite(String id) => _favoriteIds.contains(id);
  bool isJoined(String id) => _joinedIds.contains(id);
  int get joinedCount => _joinedIds.length;
  int get favoriteCount => _favoriteIds.length;

  /// Adds or removes a favorite. Does not change participation or capacity.
  void toggleFavorite(String id) {
    if (!_favoriteIds.remove(id)) {
      _favoriteIds.add(id);
    }
  }

  /// Joins an event once and decreases the available places by one.
  JoinResult join(String id) {
    if (isJoined(id)) return JoinResult.alreadyJoined;
    if (isFull(id)) return JoinResult.full;
    _joinedIds.add(id);
    _available[id] = availablePlaces(id) - 1;
    return JoinResult.joined;
  }

  /// Cancels participation and restores one available place.
  /// Returns false if the student had not joined the event.
  bool cancel(String id) {
    if (!_joinedIds.remove(id)) return false;
    _available[id] = min(byId(id).capacity, availablePlaces(id) + 1);
    return true;
  }

  /// Applies the title search and category filter to the given list.
  ///
  /// The search ignores letter case and surrounding spaces.
  /// A `null` category means "All".
  List<CampusEvent> filter({
    String query = '',
    EventCategory? category,
    bool onlyFavorites = false,
    bool onlyJoined = false,
  }) {
    final normalized = query.trim().toLowerCase();
    return events.where((e) {
      if (onlyFavorites && !isFavorite(e.id)) return false;
      if (onlyJoined && !isJoined(e.id)) return false;
      if (category != null && e.category != category) return false;
      if (normalized.isNotEmpty &&
          !e.title.toLowerCase().contains(normalized)) {
        return false;
      }
      return true;
    }).toList();
  }
}
