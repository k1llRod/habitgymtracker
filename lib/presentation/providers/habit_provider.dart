import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_log_model.dart';
import '../../data/repositories/habit_repository.dart';
import '../../domain/usecases/habit_streak_calculator.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository;
  final Uuid _uuid = const Uuid();

  List<Habit> _habits = [];
  final Map<String, HabitStatus> _logsMap = {}; // key: "habitId_yyyy-MM-dd"
  final Map<String, HabitStats> _statsMap = {}; // key: habitId -> HabitStats
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isLoading = true;

  HabitProvider({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  List<Habit> get habits => _habits;
  DateTime get currentMonth => _currentMonth;
  bool get isLoading => _isLoading;

  int get daysInCurrentMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  HabitStatus getStatus(String habitId, int day) {
    final dateStr = getDateStringForDay(day);
    return _logsMap['${habitId}_$dateStr'] ?? HabitStatus.none;
  }

  HabitStatus getStatusForDate(String habitId, String dateStr) {
    return _logsMap['${habitId}_$dateStr'] ?? HabitStatus.none;
  }

  String getDateStringForDay(int day) {
    final d = day.toString().padLeft(2, '0');
    final m = _currentMonth.month.toString().padLeft(2, '0');
    return '${_currentMonth.year}-$m-$d';
  }

  HabitStats getStats(String habitId) {
    return _statsMap[habitId] ??
        HabitStats(
          currentStreak: 0,
          bestStreak: 0,
          completedDays: 0,
          missedDays: 0,
          restDays: 0,
          successRate: 0.0,
        );
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _repository.getAllHabits();
      await _loadMonthLogs();
      await _refreshAllStats();
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMonthLogs() async {
    final logs = await _repository.getLogsForMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    _logsMap.clear();
    for (final log in logs) {
      _logsMap['${log.habitId}_${log.date}'] = log.status;
    }
  }

  Future<void> _refreshAllStats() async {
    for (final h in _habits) {
      final allLogs = await _repository.getLogsForHabit(h.id);
      _statsMap[h.id] = HabitStreakCalculator.calculate(allLogs, DateTime.now());
    }
  }

  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    loadData();
  }

  void previousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    loadData();
  }

  Future<void> cycleStatus(String habitId, String date) async {
    final current = _logsMap['${habitId}_$date'] ?? HabitStatus.none;
    HabitStatus next;

    switch (current) {
      case HabitStatus.none:
        next = HabitStatus.completed;
        break;
      case HabitStatus.completed:
        next = HabitStatus.missed;
        break;
      case HabitStatus.missed:
        next = HabitStatus.rest;
        break;
      case HabitStatus.rest:
        next = HabitStatus.none;
        break;
    }

    _logsMap['${habitId}_$date'] = next;
    notifyListeners();

    await _repository.setHabitLog(HabitLog(
      habitId: habitId,
      date: date,
      status: next,
    ));

    // Update stats
    final allLogs = await _repository.getLogsForHabit(habitId);
    _statsMap[habitId] = HabitStreakCalculator.calculate(allLogs, DateTime.now());
    notifyListeners();
  }

  Future<void> setStatus(String habitId, String date, HabitStatus status) async {
    _logsMap['${habitId}_$date'] = status;
    notifyListeners();

    await _repository.setHabitLog(HabitLog(
      habitId: habitId,
      date: date,
      status: status,
    ));

    final allLogs = await _repository.getLogsForHabit(habitId);
    _statsMap[habitId] = HabitStreakCalculator.calculate(allLogs, DateTime.now());
    notifyListeners();
  }

  Future<void> addHabit({
    required String title,
    String description = '',
    String icon = '🎯',
    String colorHex = '#2ECC71',
    String reminderTime = '',
  }) async {
    final habit = Habit(
      id: 'h_${_uuid.v4().substring(0, 8)}',
      title: title,
      description: description,
      icon: icon,
      colorHex: colorHex,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
    );

    await _repository.insertHabit(habit);
    await loadData();
  }

  Future<void> deleteHabit(String habitId) async {
    await _repository.deleteHabit(habitId);
    await loadData();
  }

  String get todayString => DateFormat('yyyy-MM-dd').format(DateTime.now());

  double get overallMonthlyAdherence {
    if (_habits.isEmpty) return 0.0;
    double total = 0.0;
    for (final h in _habits) {
      total += getStats(h.id).successRate;
    }
    return double.parse((total / _habits.length).toStringAsFixed(1));
  }
}
