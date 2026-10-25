import 'package:flutter/material.dart';

/// Small colored label: "Full", "Only 1 place left" or "N places left".
class AvailabilityLabel extends StatelessWidget {
  const AvailabilityLabel({super.key, required this.availablePlaces});

  final int availablePlaces;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;
    if (availablePlaces == 0) {
      text = 'Full';
      color = Colors.red.shade700;
    } else if (availablePlaces == 1) {
      text = 'Only 1 place left';
      color = Colors.orange.shade800;
    } else {
      text = '$availablePlaces places left';
      color = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "Joined" badge shown on events the student takes part in.
class JoinedBadge extends StatelessWidget {
  const JoinedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary),
          const SizedBox(width: 4),
          Text(
            'Joined',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
