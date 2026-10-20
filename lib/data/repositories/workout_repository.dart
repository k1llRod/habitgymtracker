import 'package:sqflite/sqflite.dart';
import '../../core/constants/default_routines.dart';
import '../../core/database/app_database.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../models/workout_session_model.dart';
import '../models/workout_set_model.dart';

class WorkoutRepository {
  final AppDatabase _dbProvider;

  WorkoutRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  // --- ROUTINES ---
  Future<List<Routine>> getRoutines() async {
    final db = await _dbProvider.database;
    var result = await db.query(
      'routines',
      orderBy: 'orderIndex ASC',
    );

    if (result.isEmpty) {
      final batch = db.batch();
      for (final routine in DefaultData.defaultRoutines) {
        batch.insert('routines', routine.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      result = await db.query(
        'routines',
        orderBy: 'orderIndex ASC',
      );
    }

    return result.map((m) => Routine.fromMap(m)).toList();
  }

  Future<void> saveRoutine(Routine routine) async {
    final db = await _dbProvider.database;
    await db.insert(
      'routines',
      routine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRoutine(String id, String dayKey) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.delete('routines', where: 'id = ?', whereArgs: [id]);
      await txn.delete('exercises', where: 'dayKey = ?', whereArgs: [dayKey]);
    });
  }

  // --- EXERCISES ---
  Future<List<Exercise>> getExercisesForDay(String dayKey) async {
    final db = await _dbProvider.database;
    var result = await db.query(
      'exercises',
      where: 'dayKey = ?',
      whereArgs: [dayKey],
      orderBy: 'orderIndex ASC',
    );
    return result.map((m) => Exercise.fromMap(m)).toList();
  }

  Future<Exercise?> getExerciseById(String exerciseId) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Exercise.fromMap(result.first);
    }
    return null;
  }

  Future<void> saveExercise(Exercise exercise) async {
    final db = await _dbProvider.database;
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExercise(String exerciseId) async {
    final db = await _dbProvider.database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [exerciseId]);
  }

  Future<void> reorderExercises(List<Exercise> exercises) async {
    final db = await _dbProvider.database;
    final batch = db.batch();
    for (int i = 0; i < exercises.length; i++) {
      batch.update(
        'exercises',
        {'orderIndex': i + 1},
        where: 'id = ?',
        whereArgs: [exercises[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  // --- SESSIONS & SETS ---
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
