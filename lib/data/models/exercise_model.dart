class Exercise {
  final String id;
  final String dayKey; // 'lunes', 'martes', 'miercoles', 'jueves', 'viernes_a', 'viernes_b'
  final String muscleGroup;
  final String name;
  final int defaultSets;
  final String defaultReps; // e.g. "10-12 reps" or "25 reps" or "al fallo"
  final bool isWarmup;
  final int orderIndex;

  Exercise({
    required this.id,
    required this.dayKey,
    required this.muscleGroup,
    required this.name,
    this.defaultSets = 4,
    this.defaultReps = '10-12 reps',
    this.isWarmup = false,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayKey': dayKey,
      'muscleGroup': muscleGroup,
      'name': name,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'isWarmup': isWarmup ? 1 : 0,
      'orderIndex': orderIndex,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      dayKey: map['dayKey'] as String,
      muscleGroup: map['muscleGroup'] as String,
      name: map['name'] as String,
      defaultSets: (map['defaultSets'] as int?) ?? 4,
      defaultReps: (map['defaultReps'] as String?) ?? '10-12 reps',
      isWarmup: ((map['isWarmup'] as int?) ?? 0) == 1,
      orderIndex: (map['orderIndex'] as int?) ?? 0,
    );
  }
}
