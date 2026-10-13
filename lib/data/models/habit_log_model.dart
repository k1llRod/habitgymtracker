import 'habit_model.dart';

class HabitLog {
  final String habitId;
  final String date; // format YYYY-MM-DD
  final HabitStatus status;
  final String note;

  HabitLog({
    required this.habitId,
    required this.date,
    required this.status,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date,
      'status': status.toDbString(),
      'note': note,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      habitId: map['habitId'] as String,
      date: map['date'] as String,
      status: HabitStatus.fromString(map['status'] as String?),
      note: (map['note'] as String?) ?? '',
    );
  }
}
