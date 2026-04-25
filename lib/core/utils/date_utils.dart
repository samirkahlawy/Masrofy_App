class DateUtils {
  static DateTime getStartOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime getEndOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  static int getDaysInCurrentCycle(int cycleDays) {
    final now = DateTime.now();
    final start = getStartOfMonth();
    return now.difference(start).inDays + 1;
  }

  static double getCycleProgress(int cycleDays) {
    final daysPassed = getDaysInCurrentCycle(cycleDays);
    return daysPassed / cycleDays;
  }
}
