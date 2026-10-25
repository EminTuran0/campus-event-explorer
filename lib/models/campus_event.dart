import 'package:flutter/material.dart';

/// Event categories. Each category has a label, an icon and a local image.
enum EventCategory {
  technology('Technology', Icons.memory, 'assets/images/technology.png'),
  arts('Arts', Icons.palette, 'assets/images/arts.png'),
  sports('Sports', Icons.sports_soccer, 'assets/images/sports.png'),
  career('Career', Icons.work_outline, 'assets/images/career.png');

  const EventCategory(this.label, this.icon, this.imagePath);

  final String label;
  final IconData icon;
  final String imagePath;
}

/// Immutable description of a campus event.
///
/// The number of available places changes while the app is running, so it is
/// kept in [EventStore]; this class only stores the initial value.
class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.venue,
    required this.description,
    required this.capacity,
    required this.initialAvailablePlaces,
  }) : assert(capacity > 0),
       assert(initialAvailablePlaces >= 0 &&
           initialAvailablePlaces <= capacity);

  final String id;
  final String title;
  final EventCategory category;
  final DateTime dateTime;
  final String venue;
  final String description;
  final int capacity;
  final int initialAvailablePlaces;

  String get imagePath => category.imagePath;
}
