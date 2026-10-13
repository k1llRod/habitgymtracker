enum HabitStatus {
  completed, // ✔
  missed,    // ✘
  rest,      // -
  none;

  static HabitStatus fromString(String? val) {
    switch (val) {
      case 'completed':
        return HabitStatus.completed;
      case 'missed':
        return HabitStatus.missed;
      case 'rest':
        return HabitStatus.rest;
      default:
        return HabitStatus.none;
    }
  }

  String toDbString() {
    return name;
  }
}

class Habit {
  final String id;
  final String title;
  final String description;
  final String icon; // Icon name / emoji
  final String colorHex;
  final String reminderTime; // e.g. "08:00"
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.icon = '🎯',
    this.colorHex = '#2ECC71',
    this.reminderTime = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'colorHex': colorHex,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      icon: (map['icon'] as String?) ?? '🎯',
      colorHex: (map['colorHex'] as String?) ?? '#2ECC71',
      reminderTime: (map['reminderTime'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
