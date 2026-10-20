import 'package:flutter_test/flutter_test.dart';
import 'package:habit_gym_tracker/data/models/exercise_model.dart';
import 'package:habit_gym_tracker/data/models/routine_model.dart';

void main() {
  group('Routine Model Tests', () {
    test('Routine serialization and deserialization works correctly', () {
      final routine = Routine(
        id: 'rot_custom_1',
        name: 'Sábado: Core & Hiit',
        dayKey: 'custom_sabado',
        description: 'Rutina de fin de semana para quemar grasa',
        icon: '🔥',
        orderIndex: 6,
        isCustom: true,
      );

      final map = routine.toMap();
      expect(map['id'], 'rot_custom_1');
      expect(map['name'], 'Sábado: Core & Hiit');
      expect(map['isCustom'], 1);

      final fromMap = Routine.fromMap(map);
      expect(fromMap.id, routine.id);
      expect(fromMap.name, routine.name);
      expect(fromMap.dayKey, routine.dayKey);
      expect(fromMap.description, routine.description);
      expect(fromMap.icon, routine.icon);
      expect(fromMap.orderIndex, routine.orderIndex);
      expect(fromMap.isCustom, true);
    });

    test('Routine copyWith updates specific fields', () {
      final routine = Routine(
        id: 'rot_1',
        name: 'Pecho',
        dayKey: 'lunes',
      );

      final updated = routine.copyWith(name: 'Pecho & Tríceps', icon: '💪');
      expect(updated.id, 'rot_1');
      expect(updated.name, 'Pecho & Tríceps');
      expect(updated.icon, '💪');
    });
  });

  group('Exercise Model Tests with Image and Instructions', () {
    test('Exercise serialization preserves imageUrl and instructions', () {
      final exercise = Exercise(
        id: 'ex_1',
        dayKey: 'lunes',
        muscleGroup: 'Pectorales',
        name: 'Press de Banca',
        defaultSets: 4,
        defaultReps: '10-12 reps',
        isWarmup: false,
        orderIndex: 1,
        imageUrl: 'https://example.com/bench_press.jpg',
        instructions: 'Bajar barra al esternón con codos a 45 grados',
      );

      final map = exercise.toMap();
      expect(map['imageUrl'], 'https://example.com/bench_press.jpg');
      expect(map['instructions'], 'Bajar barra al esternón con codos a 45 grados');

      final fromMap = Exercise.fromMap(map);
      expect(fromMap.imageUrl, exercise.imageUrl);
      expect(fromMap.instructions, exercise.instructions);
      expect(fromMap.name, exercise.name);
    });

    test('Exercise copyWith updates imageUrl and instructions', () {
      final exercise = Exercise(
        id: 'ex_2',
        dayKey: 'martes',
        muscleGroup: 'Espalda',
        name: 'Dominadas',
      );

      final updated = exercise.copyWith(
        imageUrl: '/storage/emulated/0/photos/pullup.png',
        instructions: 'Pecho a la barra sin balanceo',
      );

      expect(updated.imageUrl, '/storage/emulated/0/photos/pullup.png');
      expect(updated.instructions, 'Pecho a la barra sin balanceo');
    });
  });
}
