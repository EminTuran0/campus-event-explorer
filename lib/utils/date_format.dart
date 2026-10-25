const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// Example: "Tue, 3 Nov 2026"
String formatDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

/// Example: "14:00"
String formatTime(DateTime d) => '${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';

/// Example: "Tue, 3 Nov 2026 · 14:00"
String formatDateTime(DateTime d) => '${formatDate(d)} · ${formatTime(d)}';
