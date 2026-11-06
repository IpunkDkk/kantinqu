import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> _daysId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthsId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthsShortId = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Returns format like "Selasa, 24 Oktober 2023"
  static String formatFullDate(DateTime date) {
    final dayName = _daysId[date.weekday - 1];
    final monthName = _monthsId[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  /// Returns format like "24 Okt 2023"
  static String formatMediumDate(DateTime date) {
    final monthShort = _monthsShortId[date.month - 1];
    return '${date.day} $monthShort ${date.year}';
  }

  /// Returns format like "Hari Ini (24 Okt)" or "Besok (25 Okt)" or "24 Okt"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    final monthShort = _monthsShortId[date.month - 1];
    if (diff == 0) {
      return 'Hari Ini (${date.day} $monthShort)';
    } else if (diff == 1) {
      return 'Besok (${date.day} $monthShort)';
    } else if (diff == -1) {
      return 'Kemarin (${date.day} $monthShort)';
    } else {
      return '${date.day} $monthShort';
    }
  }

  /// Returns format like "14:00 WIB"
  static String formatTime(DateTime date) {
    return '${DateFormat('HH:mm').format(date)} WIB';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
