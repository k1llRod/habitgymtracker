class WorkoutSession {
  final String id;
  final String date; // YYYY-MM-DD
  final String dayKey;
  final String? startTime;
  final String? endTime;
  final String notes;
  final bool isFinished;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.dayKey,
    this.startTime,
    this.endTime,
    this.notes = '',
    this.isFinished = false,
  });

  WorkoutSession copyWith({
    String? id,
    String? date,
    String? dayKey,
    String? startTime,
    String? endTime,
    String? notes,
    bool? isFinished,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      dayKey: dayKey ?? this.dayKey,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'dayKey': dayKey,
      'startTime': startTime,
      'endTime': endTime,
      'notes': notes,
      'isFinished': isFinished ? 1 : 0,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      date: map['date'] as String,
      dayKey: map['dayKey'] as String,
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      notes: (map['notes'] as String?) ?? '',
      isFinished: ((map['isFinished'] as int?) ?? 0) == 1,
    );
  }
}
