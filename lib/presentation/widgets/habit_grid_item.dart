import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';

class HabitGridItem extends StatelessWidget {
  final int day;
  final HabitStatus status;
  final bool isToday;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const HabitGridItem({
    super.key,
    required this.day,
    required this.status,
    this.isToday = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget iconWidget;

    switch (status) {
      case HabitStatus.completed:
        bgColor = AppTheme.statusCompleted;
        iconWidget = const Icon(Icons.check, size: 14, color: Colors.white);
        break;
      case HabitStatus.missed:
        bgColor = AppTheme.statusMissed;
        iconWidget = const Icon(Icons.close, size: 14, color: Colors.white);
        break;
      case HabitStatus.rest:
        bgColor = AppTheme.statusRest;
        iconWidget = const Icon(Icons.remove, size: 14, color: Colors.white);
        break;
      case HabitStatus.none:
        bgColor = isToday ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.statusNone;
        iconWidget = Text(
          '$day',
          style: TextStyle(
            fontSize: 10,
            color: isToday ? Colors.white : Colors.white38,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        );
        break;
    }

    return Tooltip(
      message: 'Día $day: ${status.name}',
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: isToday
                ? Border.all(color: AppTheme.primaryColor, width: 1.5)
                : null,
          ),
          alignment: Alignment.center,
          child: iconWidget,
        ),
      ),
    );
  }
}
