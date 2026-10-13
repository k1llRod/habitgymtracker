import 'package:sqflite/sqflite.dart';
import '../../core/constants/default_routines.dart';
import '../../core/database/app_database.dart';
import '../models/exercise_model.dart';
import '../models/workout_session_model.dart';
import '../models/workout_set_model.dart';

class WorkoutRepository {
  final AppDatabase _dbProvider;

  WorkoutRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Exercise>> getExercisesForDay(String dayKey) async {
    final db = await _dbProvider.database;
    var result = await db.query(
      'exercises',
      where: 'dayKey = ?',
      whereArgs: [dayKey],
      orderBy: 'orderIndex ASC',
    );
    if (result.isEmpty) {
      final batch = db.batch();
      for (final ex in DefaultData.defaultExercises) {
        batch.insert('exercises', ex.toMap());
      }
      await batch.commit(noResult: true);
      result = await db.query(
        'exercises',
        where: 'dayKey = ?',
        whereArgs: [dayKey],
        orderBy: 'orderIndex ASC',
      );
    }
    return result.map((m) => Exercise.fromMap(m)).toList();
  }

  Future<WorkoutSession> getOrCreateSession(String date, String dayKey) async {
    final db = await _dbProvider.database;
    final existing = await db.query(
      'workout_sessions',
      where: 'date = ? AND dayKey = ?',
      whereArgs: [date, dayKey],
    );

    if (existing.isNotEmpty) {
      return WorkoutSession.fromMap(existing.first);
    }

    final newSession = WorkoutSession(
      id: 'session_${date}_$dayKey',
      date: date,
      dayKey: dayKey,
      startTime: DateTime.now().toIso8601String(),
      isFinished: false,
    );

    await db.insert('workout_sessions', newSession.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return newSession;
  }

  Future<void> updateSession(WorkoutSession session) async {
    final db = await _dbProvider.database;
    await db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<WorkoutSet>> getSetsForSession(String sessionId) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'workout_sets',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'exerciseId ASC, setNumber ASC',
    );
    return result.map((m) => WorkoutSet.fromMap(m)).toList();
  }

  Future<void> saveSet(WorkoutSet set) async {
    final db = await _dbProvider.database;
    await db.insert(
      'workout_sets',
      set.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSet(String setId) async {
    final db = await _dbProvider.database;
    await db.delete('workout_sets', where: 'id = ?', whereArgs: [setId]);
  }

  Future<WorkoutSet?> getLastCompletedSet(String exerciseId) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery('''
      SELECT ws.* FROM workout_sets ws
      INNER JOIN workout_sessions s ON ws.sessionId = s.id
      WHERE ws.exerciseId = ? AND ws.isCompleted = 1 AND ws.weightKg > 0
      ORDER BY s.date DESC, ws.setNumber DESC
      LIMIT 1
    ''', [exerciseId]);

    if (result.isNotEmpty) {
      return WorkoutSet.fromMap(result.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getDailyVolumeHistory({int limitDays = 14}) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery('''
      SELECT s.date, s.dayKey, 
             SUM(ws.weightKg * ws.reps) as totalVolume,
             COUNT(ws.id) as totalSets
      FROM workout_sessions s
      INNER JOIN workout_sets ws ON s.id = ws.sessionId
      WHERE ws.isCompleted = 1 AND ws.weightKg > 0
      GROUP BY s.date, s.dayKey
      ORDER BY s.date ASC
      LIMIT ?
    ''', [limitDays]);

    return result;
  }
}
