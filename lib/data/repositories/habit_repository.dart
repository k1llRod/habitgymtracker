import 'package:sqflite/sqflite.dart';
import '../../core/constants/default_routines.dart';
import '../../core/database/app_database.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';

class HabitRepository {
  final AppDatabase _dbProvider;

  HabitRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Habit>> getAllHabits() async {
    final db = await _dbProvider.database;
    final result = await db.query('habits', orderBy: 'createdAt ASC');
    if (result.isEmpty) {
      final batch = db.batch();
      for (final habit in DefaultData.defaultHabits) {
        batch.insert('habits', habit.toMap());
      }
      await batch.commit(noResult: true);
      final seeded = await db.query('habits', orderBy: 'createdAt ASC');
      return seeded.map((m) => Habit.fromMap(m)).toList();
    }
    return result.map((m) => Habit.fromMap(m)).toList();
  }

  Future<void> insertHabit(Habit habit) async {
    final db = await _dbProvider.database;
    await db.insert('habits', habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await _dbProvider.database;
    await db.update('habits', habit.toMap(),
        where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> deleteHabit(String habitId) async {
    final db = await _dbProvider.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
  }

  Future<List<HabitLog>> getLogsForMonth(int year, int month) async {
    final db = await _dbProvider.database;
    final monthStr = month.toString().padLeft(2, '0');
    final prefix = '$year-$monthStr-%';
    final result = await db.query(
      'habit_logs',
      where: 'date LIKE ?',
      whereArgs: [prefix],
    );
    return result.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<List<HabitLog>> getLogsForDate(String date) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    return result.map((m) => HabitLog.fromMap(m)).toList();
  }

  Future<void> setHabitLog(HabitLog log) async {
    final db = await _dbProvider.database;
    if (log.status == HabitStatus.none) {
      await db.delete(
        'habit_logs',
        where: 'habitId = ? AND date = ?',
        whereArgs: [log.habitId, log.date],
      );
    } else {
      await db.insert(
        'habit_logs',
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
