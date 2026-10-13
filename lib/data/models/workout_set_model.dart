class WorkoutSet {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isCompleted;

  WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    this.weightKg = 0.0,
    this.reps = 0,
    this.isCompleted = false,
  });

  WorkoutSet copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? setNumber,
    double? weightKg,
    int? reps,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      exerciseId: map['exerciseId'] as String,
      setNumber: (map['setNumber'] as int?) ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      reps: (map['reps'] as int?) ?? 0,
      isCompleted: ((map['isCompleted'] as int?) ?? 0) == 1,
    );
  }
}
