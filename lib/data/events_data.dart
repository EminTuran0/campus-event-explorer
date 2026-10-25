import '../models/campus_event.dart';

/// Fictional campus events stored in Dart code (no online service needed).
///
/// All dates are after the assignment deadline (25 October 2026).
/// - `evt-02` is initially FULL (0 available places).
/// - `evt-04` has exactly ONE available place.
final List<CampusEvent> campusEvents = [
  CampusEvent(
    id: 'evt-01',
    title: 'Flutter Workshop for Beginners',
    category: EventCategory.technology,
    dateTime: DateTime(2026, 11, 3, 14, 0),
    venue: 'Engineering Faculty, Lab B-204',
    description:
        'A hands-on introduction to Flutter. We will build a small app '
        'together, covering widgets, layouts and navigation. Bring your '
        'laptop with Flutter installed.',
    capacity: 30,
    initialAvailablePlaces: 12,
  ),
  CampusEvent(
    id: 'evt-02',
    title: 'AI Ethics Panel',
    category: EventCategory.technology,
    dateTime: DateTime(2026, 11, 10, 17, 30),
    venue: 'Main Conference Hall A',
    description:
        'Faculty members and industry guests discuss fairness, privacy and '
        'responsibility in artificial intelligence. A Q&A session follows '
        'the panel.',
    capacity: 120,
    initialAvailablePlaces: 0,
  ),
  CampusEvent(
    id: 'evt-03',
    title: '24-Hour Campus Hackathon',
    category: EventCategory.technology,
    dateTime: DateTime(2026, 11, 21, 9, 0),
    venue: 'Library Innovation Hub',
    description:
        'Form a team of up to four students and build a project that '
        'improves campus life. Mentors, snacks and prizes are provided.',
    capacity: 60,
    initialAvailablePlaces: 18,
  ),
  CampusEvent(
    id: 'evt-04',
    title: 'Watercolor Painting Workshop',
    category: EventCategory.arts,
    dateTime: DateTime(2026, 11, 5, 15, 0),
    venue: 'Fine Arts Studio 2',
    description:
        'Learn basic watercolor techniques such as washes, gradients and '
        'wet-on-wet painting. All materials are provided by the Arts Club.',
    capacity: 15,
    initialAvailablePlaces: 1,
  ),
  CampusEvent(
    id: 'evt-05',
    title: 'Campus Jazz Night',
    category: EventCategory.arts,
    dateTime: DateTime(2026, 11, 14, 20, 0),
    venue: 'Open-Air Amphitheatre',
    description:
        'The university jazz ensemble performs classic standards and new '
        'arrangements. Warm drinks will be served during the concert.',
    capacity: 200,
    initialAvailablePlaces: 85,
  ),
  CampusEvent(
    id: 'evt-06',
    title: 'Student Short Film Screening',
    category: EventCategory.arts,
    dateTime: DateTime(2026, 11, 27, 18, 30),
    venue: 'Culture Center Cinema Room',
    description:
        'A selection of short films made by students of the Cinema Club, '
        'followed by a conversation with the directors.',
    capacity: 80,
    initialAvailablePlaces: 40,
  ),
  CampusEvent(
    id: 'evt-07',
    title: 'Inter-Faculty Football Tournament',
    category: EventCategory.sports,
    dateTime: DateTime(2026, 11, 7, 10, 0),
    venue: 'University Stadium',
    description:
        'Faculties compete in a one-day football tournament. Register as a '
        'player; team assignments are announced on the day.',
    capacity: 64,
    initialAvailablePlaces: 20,
  ),
  CampusEvent(
    id: 'evt-08',
    title: 'Morning Yoga Session',
    category: EventCategory.sports,
    dateTime: DateTime(2026, 11, 12, 8, 0),
    venue: 'Sports Center, Studio 1',
    description:
        'Start the day with a relaxing yoga session suitable for all '
        'levels. Mats are available at the entrance.',
    capacity: 25,
    initialAvailablePlaces: 9,
  ),
  CampusEvent(
    id: 'evt-09',
    title: 'Campus 5K Fun Run',
    category: EventCategory.sports,
    dateTime: DateTime(2026, 11, 29, 9, 30),
    venue: 'Main Gate (start and finish)',
    description:
        'A 5 km run around the campus. Every finisher receives a medal. '
        'Walkers are welcome too.',
    capacity: 150,
    initialAvailablePlaces: 70,
  ),
  CampusEvent(
    id: 'evt-10',
    title: 'CV Writing and Interview Seminar',
    category: EventCategory.career,
    dateTime: DateTime(2026, 11, 18, 13, 30),
    venue: 'Career Center Seminar Room',
    description:
        'Career advisors explain how to prepare a strong CV and how to '
        'answer common interview questions. Short one-to-one reviews follow.',
    capacity: 50,
    initialAvailablePlaces: 22,
  ),
];
