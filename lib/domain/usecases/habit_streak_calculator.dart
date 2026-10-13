import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';

class HabitStats {
  final int currentStreak;
  final int bestStreak;
  final int completedDays;
  final int missedDays;
  final int restDays;
  final double successRate;

  HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.completedDays,
    required this.missedDays,
    required this.restDays,
    required this.successRate,
  });
}

class HabitStreakCalculator {
  /// Calculates streak and adherence metrics for a habit given its logs sorted by date.
  static HabitStats calculate(List<HabitLog> logs, DateTime referenceDate) {
    if (logs.isEmpty) {
      return HabitStats(
        currentStreak: 0,
        bestStreak: 0,
        completedDays: 0,
        missedDays: 0,
        restDays: 0,
        successRate: 0.0,
      );
    }

    // Map logs by date (YYYY-MM-DD)
    final logMap = <String, HabitStatus>{};
    int completedCount = 0;
    int missedCount = 0;
    int restCount = 0;

    for (final log in logs) {
      logMap[log.date] = log.status;
      if (log.status == HabitStatus.completed) completedCount++;
      if (log.status == HabitStatus.missed) missedCount++;
      if (log.status == HabitStatus.rest) restCount++;
    }

    // Calculate current streak backward from referenceDate (today or yesterday if today not logged yet)
    int currentStreak = 0;
    DateTime cursor = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    
    // Check if today is completed or rest
    final todayKey = _formatDate(cursor);
    final todayStatus = logMap[todayKey];

    // If today hasn't been logged yet, start checking from yesterday so streak isn't prematurely lost
    if (todayStatus == null || todayStatus == HabitStatus.none) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateKey = _formatDate(cursor);
      final status = logMap[dateKey];

      if (status == HabitStatus.completed) {
        currentStreak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (status == HabitStatus.rest) {
        // Rest days maintain the streak without incrementing or breaking
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        // Missed or unlogged day breaks the current streak
        break;
      }
    }

    // Calculate best streak historically
    final sortedDates = logMap.keys.toList()..sort();
    int bestStreak = 0;
    int tempStreak = 0;

    for (final d in sortedDates) {
      final s = logMap[d];
      if (s == HabitStatus.completed) {
        tempStreak++;
        if (tempStreak > bestStreak) bestStreak = tempStreak;
      } else if (s == HabitStatus.missed) {
        tempStreak = 0;
      }
      // Rest does not reset tempStreak
    }

    final totalActiveDays = completedCount + missedCount;
    final successRate = totalActiveDays > 0
        ? (completedCount / totalActiveDays) * 100.0
        : (completedCount > 0 ? 100.0 : 0.0);

    return HabitStats(
      currentStreak: currentStreak,
      bestStreak: bestStreak > currentStreak ? bestStreak : currentStreak,
      completedDays: completedCount,
      missedDays: missedCount,
      restDays: restCount,
      successRate: double.parse(successRate.toStringAsFixed(1)),
    );
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
