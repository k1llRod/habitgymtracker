import 'package:flutter_test/flutter_test.dart';
import 'package:habit_gym_tracker/data/models/workout_set_model.dart';
import 'package:habit_gym_tracker/domain/usecases/volume_calculator.dart';

void main() {
  group('VolumeCalculator Tests', () {
    test('Calculates total volume (tonnage) only for completed sets', () {
      final sets = [
        WorkoutSet(id: 's1', sessionId: 'sess1', exerciseId: 'ex1', setNumber: 1, weightKg: 80.0, reps: 10, isCompleted: true), // 800
        WorkoutSet(id: 's2', sessionId: 'sess1', exerciseId: 'ex1', setNumber: 2, weightKg: 85.0, reps: 10, isCompleted: true), // 850
        WorkoutSet(id: 's3', sessionId: 'sess1', exerciseId: 'ex1', setNumber: 3, weightKg: 90.0, reps: 8, isCompleted: false), // uncompleted -> 0
      ];

      final total = VolumeCalculator.calculateTotalVolume(sets);
      expect(total, 1650.0);
    });

    test('Estimates 1 Rep Max accurately using Epley formula', () {
      // 100 kg for 10 reps: 100 * (1 + 10/30) = 133.33 -> 133.3 kg
      final oneRm = VolumeCalculator.estimateOneRepMax(100.0, 10);
      expect(oneRm, 133.3);

      // 1 rep returns exact weight
      final singleRep = VolumeCalculator.estimateOneRepMax(120.0, 1);
      expect(singleRep, 120.0);
    });
  });
}
