import 'package:intl/intl.dart';

String appDateTimeFormatter(DateTime timestamp) {
  final datePart = DateFormat(
    'EEE MMM dd yyyy',
  ).format(timestamp); // Mon Jul 21 2025
  final timePart = DateFormat('h:mm a').format(timestamp); // 9:00 PM
  return '$datePart - $timePart';
}
