import 'package:flutter_test/flutter_test.dart';
import 'package:habit_gym_tracker/data/models/habit_model.dart';
import 'package:habit_gym_tracker/data/models/habit_log_model.dart';
import 'package:habit_gym_tracker/domain/usecases/habit_streak_calculator.dart';

void main() {
  group('HabitStreakCalculator Tests', () {
    test('Calculates active streak with consecutive completed days', () {
      final now = DateTime(2026, 10, 8);
      final logs = [
        HabitLog(habitId: 'h1', date: '2026-10-06', status: HabitStatus.completed),
        HabitLog(habitId: 'h1', date: '2026-10-07', status: HabitStatus.completed),
        HabitLog(habitId: 'h1', date: '2026-10-08', status: HabitStatus.completed),
      ];

      final stats = HabitStreakCalculator.calculate(logs, now);

      expect(stats.currentStreak, 3);
      expect(stats.bestStreak, 3);
      expect(stats.completedDays, 3);
      expect(stats.successRate, 100.0);
    });

    test('Rest day preserves current streak without breaking it', () {
      final now = DateTime(2026, 10, 8);
      final logs = [
        HabitLog(habitId: 'h1', date: '2026-10-05', status: HabitStatus.completed),
        HabitLog(habitId: 'h1', date: '2026-10-06', status: HabitStatus.rest),
        HabitLog(habitId: 'h1', date: '2026-10-07', status: HabitStatus.completed),
        HabitLog(habitId: 'h1', date: '2026-10-08', status: HabitStatus.completed),
      ];

      final stats = HabitStreakCalculator.calculate(logs, now);

      expect(stats.currentStreak, 3); // 3 completed days, rest day preserved the continuity
      expect(stats.restDays, 1);
    });

    test('Missed day resets current streak', () {
      final now = DateTime(2026, 10, 8);
      final logs = [
        HabitLog(habitId: 'h1', date: '2026-10-05', status: HabitStatus.completed),
        HabitLog(habitId: 'h1', date: '2026-10-06', status: HabitStatus.completed),
        HabitLog(habitId: 'h1', date: '2026-10-07', status: HabitStatus.missed),
        HabitLog(habitId: 'h1', date: '2026-10-08', status: HabitStatus.completed),
      ];

      final stats = HabitStreakCalculator.calculate(logs, now);

      expect(stats.currentStreak, 1); // Only today after missed yesterday
      expect(stats.bestStreak, 2);    // Oct 5 & 6
      expect(stats.missedDays, 1);
    });
  });
}
