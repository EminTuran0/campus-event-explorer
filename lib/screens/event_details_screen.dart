import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../state/event_store.dart';
import '../utils/date_format.dart';
import '../widgets/availability_label.dart';
import '../widgets/confirmation_dialogs.dart';
import 'image_viewer_screen.dart';

/// Shows all information about one event, with a favorite control and a
/// join / cancel button. Double-tapping the image opens [ImageViewerScreen].
class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.store,
    required this.onChanged,
  });

  final CampusEvent event;
  final EventStore store;

  /// Tells the home screen to rebuild its lists.
  final VoidCallback onChanged;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  CampusEvent get _event => widget.event;
  EventStore get _store => widget.store;

  void _update(VoidCallback change) {
    setState(change);
    widget.onChanged();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _toggleFavorite() {
    _update(() => _store.toggleFavorite(_event.id));
    _showMessage(
      _store.isFavorite(_event.id)
          ? 'Added to favorites.'
          : 'Removed from favorites.',
    );
  }

  Future<void> _join() async {
    final confirmed = await showJoinConfirmationDialog(context, _event);
    if (!mounted) return;
    if (!confirmed) {
      _showMessage('No changes were made.');
      return;
    }
    late JoinResult result;
    _update(() {
      result = _store.join(_event.id);
    });
    switch (result) {
      case JoinResult.joined:
        final left = _store.availablePlaces(_event.id);
        _showMessage(
          'You joined "${_event.title}". '
          '$left ${left == 1 ? 'place' : 'places'} left.',
        );
      case JoinResult.alreadyJoined:
        _showMessage('You have already joined this event.');
      case JoinResult.full:
        _showMessage('Sorry, this event is full.');
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showCancelConfirmationDialog(context, _event);
    if (!mounted) return;
    if (!confirmed) {
      _showMessage('Your participation was kept.');
      return;
    }
    _update(() => _store.cancel(_event.id));
    _showMessage('Participation cancelled. One place was released.');
  }

  void _openImage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ImageViewerScreen(
          imagePath: _event.imagePath,
          heroTag: 'event-image-${_event.id}',
          title: _event.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = _store.availablePlaces(_event.id);
    final joined = _store.isJoined(_event.id);
    final favorite = _store.isFavorite(_event.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            key: const Key('details-fav'),
            tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red.shade600,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GestureDetector(
            key: const Key('details-image'),
            onDoubleTap: _openImage,
            child: Hero(
              tag: 'event-image-${_event.id}',
              child: Image.asset(
                _event.imagePath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Double-tap the image to enlarge',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(
                      avatar: Icon(_event.category.icon, size: 18),
                      label: Text(_event.category.label),
                      visualDensity: VisualDensity.compact,
                    ),
                    AvailabilityLabel(availablePlaces: available),
                    if (joined) const JoinedBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _DetailTile(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: formatDate(_event.dateTime),
                      ),
                      _DetailTile(
                        icon: Icons.schedule,
                        label: 'Time',
                        value: formatTime(_event.dateTime),
                      ),
                      _DetailTile(
                        icon: Icons.place_outlined,
                        label: 'Venue',
                        value: _event.venue,
                      ),
                      _DetailTile(
                        icon: Icons.groups_outlined,
                        label: 'Total capacity',
                        value: '${_event.capacity} people',
                      ),
                      _DetailTile(
                        icon: Icons.event_seat_outlined,
                        label: 'Available places',
                        value: '$available of ${_event.capacity}',
                      ),
                      _DetailTile(
                        icon: Icons.tag,
                        label: 'Event ID',
                        value: _event.id,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'About this event',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(_event.description, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _buildParticipationButton(joined: joined, available: available),
        ),
      ),
    );
  }

  Widget _buildParticipationButton({
    required bool joined,
    required int available,
  }) {
    // A joined student can always cancel, even if the event is now full.
    if (joined) {
      return OutlinedButton.icon(
        key: const Key('cancel-button'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade700),
        ),
        onPressed: _cancel,
        icon: const Icon(Icons.event_busy),
        label: const Text('Cancel participation'),
      );
    }
    if (available == 0) {
      return FilledButton.icon(
        key: const Key('full-button'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: null, // Full events cannot be joined.
        icon: const Icon(Icons.block),
        label: const Text('Full - cannot join'),
      );
    }
    return FilledButton.icon(
      key: const Key('join-button'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      onPressed: _join,
      icon: const Icon(Icons.how_to_reg),
      label: const Text('Join event'),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
