import '../../data/models/workout_set_model.dart';

class VolumeCalculator {
  /// Calculates total tonnage (kg) for completed sets
  static double calculateTotalVolume(List<WorkoutSet> sets) {
    double total = 0.0;
    for (final s in sets) {
      if (s.isCompleted && s.weightKg > 0 && s.reps > 0) {
        total += (s.weightKg * s.reps);
      }
    }
    return total;
  }

  /// Calculates volume for a specific exercise
  static double calculateExerciseVolume(List<WorkoutSet> sets, String exerciseId) {
    final filtered = sets.where((s) => s.exerciseId == exerciseId).toList();
    return calculateTotalVolume(filtered);
  }

  /// Estimates 1 Rep Max using the Epley formula: weight * (1 + reps / 30)
  static double estimateOneRepMax(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return weightKg;
    final oneRm = weightKg * (1.0 + (reps / 30.0));
    return double.parse(oneRm.toStringAsFixed(1));
  }

  /// Total completed reps across all sets
  static int calculateTotalReps(List<WorkoutSet> sets) {
    int total = 0;
    for (final s in sets) {
      if (s.isCompleted) {
        total += s.reps;
      }
    }
    return total;
  }
}
