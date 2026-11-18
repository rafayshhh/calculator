class BusinessDaysResult {
  final int businessDays;
  final int totalCalendarDays;
  final int weekendDays;
  final int holidaysExcluded;
  final DateTime? firstBusinessDay;
  final DateTime? lastBusinessDay;

  const BusinessDaysResult({
    required this.businessDays,
    required this.totalCalendarDays,
    required this.weekendDays,
    required this.holidaysExcluded,
    this.firstBusinessDay,
    this.lastBusinessDay,
  });
}

class DateAddSubtractResult {
  final DateTime resultDate;
  final String dayOfWeek;
  final DateTime originalDate;
  final String operation;
  final int years;
  final int months;
  final int weeks;
  final int days;
  final bool isLeapYear;

  const DateAddSubtractResult({
    required this.resultDate,
    required this.dayOfWeek,
    required this.originalDate,
    required this.operation,
    required this.years,
    required this.months,
    required this.weeks,
    required this.days,
    required this.isLeapYear,
  });
}

class TimestampResult {
  final int unixSeconds;
  final int unixMilliseconds;
  final DateTime utcDateTime;
  final DateTime localDateTime;
  final String formattedUtc;
  final String formattedLocal;
  final String iso8601Utc;
  final String iso8601Local;

  const TimestampResult({
    required this.unixSeconds,
    required this.unixMilliseconds,
    required this.utcDateTime,
    required this.localDateTime,
    required this.formattedUtc,
    required this.formattedLocal,
    required this.iso8601Utc,
    required this.iso8601Local,
  });
}

class DateDifferenceResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalWeeks;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;
  final String formattedSummary;

  const DateDifferenceResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalWeeks,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
    required this.formattedSummary,
  });
}

class AgeResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  final int totalMonths;
  final int totalWeeks;
  final int totalHours;
  final int nextBirthdayDays;
  final String dayOfWeekBorn;

  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
    required this.totalMonths,
    required this.totalWeeks,
    required this.totalHours,
    required this.nextBirthdayDays,
    required this.dayOfWeekBorn,
  });
}

class DateTimeEngine {
  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static bool isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  static int daysInMonth(int year, int month) {
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  static String getWeekdayName(int weekday) {
    if (weekday >= 1 && weekday <= 7) {
      return _weekdays[weekday - 1];
    }
    return '';
  }

  static BusinessDaysResult calculateBusinessDays({
    required DateTime start,
    required DateTime end,
    required Set<int> weekendDays,
    required Set<DateTime> holidays,
  }) {
    DateTime s = DateTime(start.year, start.month, start.day);
    DateTime e = DateTime(end.year, end.month, end.day);
    if (s.isAfter(e)) {
      final tmp = s;
      s = e;
      e = tmp;
    }

    final holidaySet = holidays
        .map((h) => '${h.year}-${h.month.toString().padLeft(2, '0')}-${h.day.toString().padLeft(2, '0')}')
        .toSet();

    int totalCalendarDays = e.difference(s).inDays + 1;
    int businessCount = 0;
    int weekendCount = 0;
    int holidayCount = 0;
    DateTime? firstBiz;
    DateTime? lastBiz;

    DateTime curr = s;
    while (!curr.isAfter(e)) {
      final isWknd = weekendDays.contains(curr.weekday);
      final key = '${curr.year}-${curr.month.toString().padLeft(2, '0')}-${curr.day.toString().padLeft(2, '0')}';
      final isHol = holidaySet.contains(key);

      if (isWknd) {
        weekendCount++;
      } else if (isHol) {
        holidayCount++;
      } else {
        businessCount++;
        firstBiz ??= curr;
        lastBiz = curr;
      }

      curr = curr.add(const Duration(days: 1));
    }

    return BusinessDaysResult(
      businessDays: businessCount,
      totalCalendarDays: totalCalendarDays,
      weekendDays: weekendCount,
      holidaysExcluded: holidayCount,
      firstBusinessDay: firstBiz,
      lastBusinessDay: lastBiz,
    );
  }

  static DateAddSubtractResult calculateDateAddSubtract({
    required DateTime initialDate,
    required String operation, // 'add' or 'subtract'
    required int years,
    required int months,
    required int weeks,
    required int days,
  }) {
    final isSubtract = operation.toLowerCase() == 'subtract';
    final sign = isSubtract ? -1 : 1;

    int totalMonths = initialDate.year * 12 + (initialDate.month - 1) + sign * (years * 12 + months);
    int newYear = totalMonths ~/ 12;
    int newMonth = (totalMonths % 12) + 1;
    int maxDay = daysInMonth(newYear, newMonth);
    int newDay = initialDate.day > maxDay ? maxDay : initialDate.day;

    DateTime intermediate = DateTime(newYear, newMonth, newDay, initialDate.hour, initialDate.minute, initialDate.second);
    int additionalDays = sign * (weeks * 7 + days);
    DateTime result = intermediate.add(Duration(days: additionalDays));

    return DateAddSubtractResult(
      resultDate: result,
      dayOfWeek: getWeekdayName(result.weekday),
      originalDate: initialDate,
      operation: operation,
      years: years,
      months: months,
      weeks: weeks,
      days: days,
      isLeapYear: isLeapYear(result.year),
    );
  }

  static DateTime addSubtractTime({
    required DateTime initialDate,
    required int years,
    required int months,
    required int days,
    required int hours,
    required int minutes,
    required bool isSubtract,
  }) {
    final sign = isSubtract ? -1 : 1;
    int totalMonths = initialDate.year * 12 + (initialDate.month - 1) + sign * (years * 12 + months);
    int newYear = totalMonths ~/ 12;
    int newMonth = (totalMonths % 12) + 1;
    int maxDay = daysInMonth(newYear, newMonth);
    int newDay = initialDate.day > maxDay ? maxDay : initialDate.day;

    DateTime intermediate = DateTime(newYear, newMonth, newDay, initialDate.hour, initialDate.minute, initialDate.second);
    Duration delta = Duration(
      days: sign * days,
      hours: sign * hours,
      minutes: sign * minutes,
    );
    return intermediate.add(delta);
  }

  static TimestampResult convertTimestamp({
    int? unixSeconds,
    int? unixMilliseconds,
    DateTime? dateTime,
    String? isoString,
  }) {
    DateTime dt;
    if (unixSeconds != null) {
      dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000, isUtc: true);
    } else if (unixMilliseconds != null) {
      dt = DateTime.fromMillisecondsSinceEpoch(unixMilliseconds, isUtc: true);
    } else if (dateTime != null) {
      dt = dateTime.toUtc();
    } else if (isoString != null && isoString.isNotEmpty) {
      dt = DateTime.parse(isoString).toUtc();
    } else {
      dt = DateTime.now().toUtc();
    }

    final local = dt.toLocal();
    final sec = dt.millisecondsSinceEpoch ~/ 1000;
    final ms = dt.millisecondsSinceEpoch;

    String formatDt(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      final h = d.hour.toString().padLeft(2, '0');
      final min = d.minute.toString().padLeft(2, '0');
      final s = d.second.toString().padLeft(2, '0');
      return '$y-$m-$day $h:$min:$s';
    }

    return TimestampResult(
      unixSeconds: sec,
      unixMilliseconds: ms,
      utcDateTime: dt,
      localDateTime: local,
      formattedUtc: '${formatDt(dt)} UTC',
      formattedLocal: formatDt(local),
      iso8601Utc: dt.toIso8601String(),
      iso8601Local: local.toIso8601String(),
    );
  }

  static DateDifferenceResult calculateDifference({
    required DateTime start,
    required DateTime end,
  }) {
    DateTime s = start;
    DateTime e = end;
    bool isNegative = false;
    if (s.isAfter(e)) {
      final tmp = s;
      s = e;
      e = tmp;
      isNegative = true;
    }

    int years = e.year - s.year;
    int months = e.month - s.month;
    int days = e.day - s.day;

    if (days < 0) {
      final prevMonth = e.month == 1 ? 12 : e.month - 1;
      final prevYear = e.month == 1 ? e.year - 1 : e.year;
      days += daysInMonth(prevYear, prevMonth);
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    final totalDuration = e.difference(s);
    final totalDays = totalDuration.inDays;
    final totalWeeks = totalDays ~/ 7;
    final totalHours = totalDuration.inHours;
    final totalMinutes = totalDuration.inMinutes;
    final totalSeconds = totalDuration.inSeconds;

    final parts = <String>[];
    if (years > 0) parts.add('$years ${years == 1 ? "year" : "years"}');
    if (months > 0) parts.add('$months ${months == 1 ? "month" : "months"}');
    if (days > 0 || parts.isEmpty) parts.add('$days ${days == 1 ? "day" : "days"}');

    String summary = parts.join(', ');
    if (isNegative) summary = '-($summary)';

    return DateDifferenceResult(
      years: years,
      months: months,
      days: days,
      totalDays: totalDays,
      totalWeeks: totalWeeks,
      totalHours: totalHours,
      totalMinutes: totalMinutes,
      totalSeconds: totalSeconds,
      formattedSummary: summary,
    );
  }

  static AgeResult calculateAge({
    required DateTime birthDate,
    DateTime? asOfDate,
  }) {
    final now = asOfDate ?? DateTime.now();
    final diff = calculateDifference(start: birthDate, end: now);

    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    final nextBdayDays = nextBirthday.difference(now).inDays;

    return AgeResult(
      years: diff.years,
      months: diff.months,
      days: diff.days,
      totalDays: diff.totalDays,
      totalMonths: diff.years * 12 + diff.months,
      totalWeeks: diff.totalWeeks,
      totalHours: diff.totalHours,
      nextBirthdayDays: nextBdayDays,
      dayOfWeekBorn: getWeekdayName(birthDate.weekday),
    );
  }

  static int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(
      '${date.difference(DateTime(date.year, 1, 1)).inDays + 1}',
    );
    int wDay = date.weekday;
    int weekNum = ((dayOfYear - wDay + 10) / 7).floor();
    if (weekNum < 1) {
      weekNum = 52;
    } else if (weekNum > 52) {
      if (DateTime(date.year, 12, 31).weekday < 4) {
        weekNum = 1;
      }
    }
    return weekNum;
  }
}
