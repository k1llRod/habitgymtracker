class Exercise {
  final String id;
  final String dayKey; // e.g. 'lunes', 'martes', 'miercoles', 'jueves', 'viernes_a', 'viernes_b', or custom routine dayKey
  final String muscleGroup;
  final String name;
  final int defaultSets;
  final String defaultReps; // e.g. "10-12 reps" or "25 reps" or "al fallo"
  final bool isWarmup;
  final int orderIndex;
  final String? imageUrl; // Local file path or network URL
  final String? instructions; // Guidance / tips on technique and posture

  Exercise({
    required this.id,
    required this.dayKey,
    required this.muscleGroup,
    required this.name,
    this.defaultSets = 4,
    this.defaultReps = '10-12 reps',
    this.isWarmup = false,
    this.orderIndex = 0,
    this.imageUrl,
    this.instructions,
  });

  Exercise copyWith({
    String? id,
    String? dayKey,
    String? muscleGroup,
    String? name,
    int? defaultSets,
    String? defaultReps,
    bool? isWarmup,
    int? orderIndex,
    String? imageUrl,
    String? instructions,
  }) {
    return Exercise(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      name: name ?? this.name,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      isWarmup: isWarmup ?? this.isWarmup,
      orderIndex: orderIndex ?? this.orderIndex,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
    );
  }

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
      'imageUrl': imageUrl,
      'instructions': instructions,
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
      imageUrl: map['imageUrl'] as String?,
      instructions: map['instructions'] as String?,
    );
  }
}
