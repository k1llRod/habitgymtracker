import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/default_routines.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/workout_set_model.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/usecases/volume_calculator.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository;
  final Uuid _uuid = const Uuid();

  String _selectedDayKey = 'lunes';
  DateTime _selectedDate = DateTime.now();
  List<Exercise> _exercises = [];
  WorkoutSession? _currentSession;
  List<WorkoutSet> _currentSets = [];
  final Map<String, WorkoutSet?> _lastSets = {};
  List<Map<String, dynamic>> _volumeHistory = [];
  bool _isLoading = true;

  WorkoutProvider({WorkoutRepository? repository})
      : _repository = repository ?? WorkoutRepository() {
    _selectedDayKey = DefaultData.getDayKeyForDateTime(DateTime.now());
  }

  String get selectedDayKey => _selectedDayKey;
  DateTime get selectedDate => _selectedDate;
  List<Exercise> get exercises => _exercises;
  WorkoutSession? get currentSession => _currentSession;
  List<WorkoutSet> get currentSets => _currentSets;
  Map<String, WorkoutSet?> get lastSets => _lastSets;
  List<Map<String, dynamic>> get volumeHistory => _volumeHistory;
  bool get isLoading => _isLoading;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  double get currentSessionVolume => VolumeCalculator.calculateTotalVolume(_currentSets);
  int get completedSetsCount => _currentSets.where((s) => s.isCompleted).length;
  int get totalSetsCount => _currentSets.length;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _repository.getExercisesForDay(_selectedDayKey);
      _currentSession = await _repository.getOrCreateSession(
        formattedDate,
        _selectedDayKey,
      );
      _currentSets = await _repository.getSetsForSession(_currentSession!.id);

      // If session is newly created and has no sets, auto-generate default sets for each exercise!
      if (_currentSets.isEmpty) {
        for (final ex in _exercises) {
          for (int i = 1; i <= ex.defaultSets; i++) {
            final newSet = WorkoutSet(
              id: 'set_${_uuid.v4().substring(0, 8)}',
              sessionId: _currentSession!.id,
              exerciseId: ex.id,
              setNumber: i,
              weightKg: 0.0,
              reps: 0,
              isCompleted: false,
            );
            await _repository.saveSet(newSet);
            _currentSets.add(newSet);
          }
        }
      }

      // Fetch last recorded weights for each exercise
      _lastSets.clear();
      for (final ex in _exercises) {
        _lastSets[ex.id] = await _repository.getLastCompletedSet(ex.id);
      }

      _volumeHistory = await _repository.getDailyVolumeHistory();
    } catch (e) {
      debugPrint('Error loading workout data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDay(String dayKey) {
    if (_selectedDayKey == dayKey) return;
    _selectedDayKey = dayKey;
    loadData();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedDayKey = DefaultData.getDayKeyForDateTime(date);
    loadData();
  }

  List<WorkoutSet> getSetsForExercise(String exerciseId) {
    return _currentSets
        .where((s) => s.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
  }

  Future<void> updateSet(WorkoutSet set) async {
    final index = _currentSets.indexWhere((s) => s.id == set.id);
    if (index != -1) {
      _currentSets[index] = set;
      notifyListeners();
      await _repository.saveSet(set);
      _volumeHistory = await _repository.getDailyVolumeHistory();
    }
  }

  Future<void> addSetToExercise(String exerciseId) async {
    if (_currentSession == null) return;
    final existing = getSetsForExercise(exerciseId);
    final nextNumber = existing.isEmpty ? 1 : existing.last.setNumber + 1;
    final lastWeight = existing.isNotEmpty ? existing.last.weightKg : 0.0;
    final lastReps = existing.isNotEmpty ? existing.last.reps : 10;

    final newSet = WorkoutSet(
      id: 'set_${_uuid.v4().substring(0, 8)}',
      sessionId: _currentSession!.id,
      exerciseId: exerciseId,
      setNumber: nextNumber,
      weightKg: lastWeight,
      reps: lastReps,
      isCompleted: false,
    );

    _currentSets.add(newSet);
    notifyListeners();

    await _repository.saveSet(newSet);
  }

  Future<void> removeSet(String setId) async {
    _currentSets.removeWhere((s) => s.id == setId);
    notifyListeners();
    await _repository.deleteSet(setId);
  }

  Future<void> toggleSetCompleted(String setId) async {
    final index = _currentSets.indexWhere((s) => s.id == setId);
    if (index != -1) {
      final current = _currentSets[index];
      final updated = current.copyWith(isCompleted: !current.isCompleted);
      _currentSets[index] = updated;
      notifyListeners();

      await _repository.saveSet(updated);
      _volumeHistory = await _repository.getDailyVolumeHistory();
    }
  }

  Future<void> finishSession(String notes) async {
    if (_currentSession == null) return;
    final updated = _currentSession!.copyWith(
      endTime: DateTime.now().toIso8601String(),
      isFinished: true,
      notes: notes,
    );
    _currentSession = updated;
    notifyListeners();

    await _repository.updateSession(updated);
  }
}
