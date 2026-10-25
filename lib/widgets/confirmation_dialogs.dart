import 'package:flutter/material.dart';

import '../models/campus_event.dart';
import '../utils/date_format.dart';

/// Asks the student to confirm joining. Shows title, date/time and venue.
/// Returns true only when "Yes" is pressed; "No" or dismissing returns false.
Future<bool> showJoinConfirmationDialog(
  BuildContext context,
  CampusEvent event,
) {
  return _showConfirmation(
    context,
    title: 'Join this event?',
    event: event,
    question: 'Do you want to join this event?',
  );
}

/// Asks the student to confirm cancelling their participation.
Future<bool> showCancelConfirmationDialog(
  BuildContext context,
  CampusEvent event,
) {
  return _showConfirmation(
    context,
    title: 'Cancel participation?',
    event: event,
    question: 'Your place will be released for other students.',
  );
}

Future<bool> _showConfirmation(
  BuildContext context, {
  required String title,
  required CampusEvent event,
  required String question,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogLine(label: 'Event', value: event.title),
          _DialogLine(
            label: 'Date & time',
            value: formatDateTime(event.dateTime),
          ),
          _DialogLine(label: 'Venue', value: event.venue),
          const SizedBox(height: 12),
          Text(question),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
  // Dismissing the dialog (tap outside / back) gives null -> treated as No.
  return result ?? false;
}

class _DialogLine extends StatelessWidget {
  const _DialogLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
