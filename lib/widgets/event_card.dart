import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../utils/date_format.dart';
import 'availability_label.dart';
import 'info_row.dart';

/// Reusable StatelessWidget that shows one event in a list.
///
/// It only displays data; all changes are reported to the parent through
/// [onTap] and [onFavoriteToggle].
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.availablePlaces,
    required this.isFavorite,
    required this.isJoined,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final CampusEvent event;
  final int availablePlaces;
  final bool isFavorite;
  final bool isJoined;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'event-image-${event.id}',
                  child: Image.asset(
                    event.imagePath,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: const CircleBorder(),
                    child: IconButton(
                      key: Key('fav-${event.id}'),
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red.shade600,
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(event.category.icon,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                event.category.label,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isJoined) ...[
                        const JoinedBadge(),
                        const SizedBox(width: 6),
                      ],
                      AvailabilityLabel(availablePlaces: availablePlaces),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InfoRow(
                    icon: Icons.schedule,
                    text: formatDateTime(event.dateTime),
                  ),
                  const SizedBox(height: 2),
                  InfoRow(icon: Icons.place_outlined, text: event.venue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
