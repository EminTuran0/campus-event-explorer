import 'package:flutter/material.dart';

import '../data/events_data.dart';
import '../models/campus_event.dart';
import '../state/event_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';
import '../widgets/search_filter_bar.dart';
import 'event_details_screen.dart';

/// The three views of the app.
enum HomeTab { explore, favorites, myEvents }

/// Main StatefulWidget. It owns the [EventStore] and the shared search and
/// category settings, and switches between Explore, Favorites and My Events
/// with a bottom navigation bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.events});

  /// Optional event list (used by tests). Defaults to [campusEvents].
  final List<CampusEvent>? events;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EventStore _store = EventStore(widget.events ?? campusEvents);
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  EventCategory? _category; // null means "All"
  HomeTab _tab = HomeTab.explore;

  bool get _hasActiveFilter => _query.trim().isNotEmpty || _category != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
      _category = null;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  void _toggleFavorite(CampusEvent event) {
    setState(() => _store.toggleFavorite(event.id));
    final added = _store.isFavorite(event.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '"${event.title}" added to favorites.'
                : '"${event.title}" removed from favorites.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _openDetails(CampusEvent event) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailsScreen(
          event: event,
          store: _store,
          // Rebuild the lists whenever details change something.
          onChanged: () => setState(() {}),
        ),
      ),
    );
    // Make sure the lists show the latest state after returning.
    if (mounted) setState(() {});
  }

  List<CampusEvent> _visibleEvents() {
    return _store.filter(
      query: _query,
      category: _category,
      onlyFavorites: _tab == HomeTab.favorites,
      onlyJoined: _tab == HomeTab.myEvents,
    );
  }

  String get _title => switch (_tab) {
    HomeTab.explore => 'Explore Events',
    HomeTab.favorites => 'Favorites',
    HomeTab.myEvents => 'My Events',
  };

  @override
  Widget build(BuildContext context) {
    final events = _visibleEvents();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          SearchFilterBar(
            controller: _searchController,
            selectedCategory: _category,
            onQueryChanged: (value) => setState(() => _query = value),
            onClearQuery: _clearSearch,
            onCategorySelected: (c) => setState(() => _category = c),
          ),
          if (_tab == HomeTab.myEvents) _JoinedSummary(count: _store.joinedCount),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${events.length} matching '
                '${events.length == 1 ? 'event' : 'events'}',
                key: const Key('match-count'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final e = events[index];
                      return EventCard(
                        key: ValueKey(e.id),
                        event: e,
                        availablePlaces: _store.availablePlaces(e.id),
                        isFavorite: _store.isFavorite(e.id),
                        isJoined: _store.isJoined(e.id),
                        onTap: () => _openDetails(e),
                        onFavoriteToggle: () => _toggleFavorite(e),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab.index,
        onDestinationSelected: (i) =>
            setState(() => _tab = HomeTab.values[i]),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _store.favoriteCount > 0,
              label: Text('${_store.favoriteCount}'),
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _store.joinedCount > 0,
              label: Text('${_store.joinedCount}'),
              child: const Icon(Icons.event_available_outlined),
            ),
            selectedIcon: const Icon(Icons.event_available),
            label: 'My Events',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Filters are active: nothing matches the search / category.
    if (_hasActiveFilter) {
      return EmptyState(
        key: const Key('empty-search'),
        icon: Icons.search_off,
        title: 'No events match your search',
        message: 'Try another title or category, or clear the search.',
        actionLabel: 'Clear search and filters',
        onAction: _clearFilters,
      );
    }
    return switch (_tab) {
      HomeTab.explore => const EmptyState(
        icon: Icons.event_busy,
        title: 'No events available',
        message: 'There are no campus events to show right now.',
      ),
      HomeTab.favorites => const EmptyState(
        key: Key('empty-favorites'),
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Tap the heart on an event to save it here.',
      ),
      HomeTab.myEvents => const EmptyState(
        key: Key('empty-my-events'),
        icon: Icons.event_note,
        title: "You haven't joined any events",
        message: 'Open an event and tap "Join event" to take part.',
      ),
    };
  }
}

class _JoinedSummary extends StatelessWidget {
  const _JoinedSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('joined-summary'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.how_to_reg, color: scheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Total joined events: $count',
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
