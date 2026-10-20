class Routine {
  final String id;
  final String name;
  final String dayKey;
  final String? description;
  final String? icon;
  final int orderIndex;
  final bool isCustom;

  Routine({
    required this.id,
    required this.name,
    required this.dayKey,
    this.description,
    this.icon,
    this.orderIndex = 0,
    this.isCustom = false,
  });

  Routine copyWith({
    String? id,
    String? name,
    String? dayKey,
    String? description,
    String? icon,
    int? orderIndex,
    bool? isCustom,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      dayKey: dayKey ?? this.dayKey,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      orderIndex: orderIndex ?? this.orderIndex,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dayKey': dayKey,
      'description': description,
      'icon': icon,
      'orderIndex': orderIndex,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] as String,
      name: map['name'] as String,
      dayKey: map['dayKey'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      orderIndex: (map['orderIndex'] as int?) ?? 0,
      isCustom: ((map['isCustom'] as int?) ?? 0) == 1,
    );
  }
}
