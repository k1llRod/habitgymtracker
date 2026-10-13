import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../constants/default_routines.dart';
import 'database_factory.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habit_gym_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final factory = getPlatformDatabaseFactory();
    final String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await factory.getDatabasesPath();
      path = '$dbPath/$filePath';
    }

    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Habits Table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        icon TEXT NOT NULL,
        colorHex TEXT NOT NULL,
        reminderTime TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // 2. Habit Logs Table (Daily Matrix)
    await db.execute('''
      CREATE TABLE habit_logs (
        habitId TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT,
        PRIMARY KEY (habitId, date),
        FOREIGN KEY (habitId) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');

    // 3. Exercises Table
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        dayKey TEXT NOT NULL,
        muscleGroup TEXT NOT NULL,
        name TEXT NOT NULL,
        defaultSets INTEGER NOT NULL,
        defaultReps TEXT NOT NULL,
        isWarmup INTEGER NOT NULL,
        orderIndex INTEGER NOT NULL
      )
    ''');

    // 4. Workout Sessions Table
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        dayKey TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        notes TEXT,
        isFinished INTEGER NOT NULL
      )
    ''');

    // 5. Workout Sets Table
    await db.execute('''
      CREATE TABLE workout_sets (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        reps INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');

    // Seed default habits
    final batch = db.batch();
    for (final habit in DefaultData.defaultHabits) {
      batch.insert('habits', habit.toMap());
    }
    // Seed default exercises
    for (final ex in DefaultData.defaultExercises) {
      batch.insert('exercises', ex.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
