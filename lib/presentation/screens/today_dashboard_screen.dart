import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_routines.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/rest_timer_dialog.dart';

class TodayDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const TodayDashboardScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final workoutProv = context.watch<WorkoutProvider>();

    final now = DateTime.now();
    final dateFormatted = DateFormat('EEEE, d MMMM', 'es_ES').format(now);
    final capitalizedDate = dateFormatted.isNotEmpty
        ? dateFormatted[0].toUpperCase() + dateFormatted.substring(1)
        : dateFormatted;

    final todayStr = habitProv.todayString;
    final habits = habitProv.habits;

    int completedHabits = 0;
    for (final h in habits) {
      if (habitProv.getStatusForDate(h.id, todayStr) == HabitStatus.completed) {
        completedHabits++;
      }
    }

    final habitProgress = habits.isNotEmpty ? completedHabits / habits.length : 0.0;
    final todayRoutineName = DefaultData.dayNames[workoutProv.selectedDayKey] ?? 'Entrenamiento';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️‍♂️ Habit & Gym Tracker'),
        actions: [
          IconButton(
            tooltip: 'Temporizador de Descanso',
            icon: const Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
            onPressed: () => RestTimerDialog.show(context),
          ),
        ],
      ),
      body: habitProv.isLoading || workoutProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await habitProv.loadData();
                await workoutProv.loadData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Motivating Quote Card
                  Card(
                    color: AppTheme.darkSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                capitalizedDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '"Para aprender y desaprender hábitos mentales y físicos, hay que entrenar el cerebro con paciencia y constancia."',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 1: Hábitos de Hoy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hábitos de Hoy',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextButton.icon(
                        onPressed: () => onNavigateToTab(1), // Go to Habit Matrix
                        icon: const Icon(Icons.grid_on, size: 16),
                        label: const Text('Ver Matriz'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Habit Progress Bar
                  LinearProgressIndicator(
                    value: habitProgress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.statusCompleted),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completedHabits de ${habits.length} hábitos completados hoy (${(habitProgress * 100).toInt()}%)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // List of today habits
                  ...habits.map((habit) {
                    final status = habitProv.getStatusForDate(habit.id, todayStr);
                    final stats = habitProv.getStats(habit.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.darkSurface,
                          child: Text(habit.icon, style: const TextStyle(fontSize: 18)),
                        ),
                        title: Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: status == HabitStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: status == HabitStatus.completed
                                ? Colors.white60
                                : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Racha actual: 🔥 ${stats.currentStreak} días | Adherencia: ${stats.successRate}%',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            status == HabitStatus.completed
                                ? Icons.check_circle
                                : (status == HabitStatus.missed
                                    ? Icons.cancel
                                    : (status == HabitStatus.rest
                                        ? Icons.remove_circle
                                        : Icons.radio_button_unchecked)),
                            color: status == HabitStatus.completed
                                ? AppTheme.statusCompleted
                                : (status == HabitStatus.missed
                                    ? AppTheme.statusMissed
                                    : (status == HabitStatus.rest
                                        ? AppTheme.statusRest
                                        : Colors.grey)),
                            size: 26,
                          ),
                          onPressed: () => habitProv.cycleStatus(habit.id, todayStr),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Section 2: Rutina de Gimnasio Asignada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Entrenamiento de Hoy',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextButton.icon(
                        onPressed: () => onNavigateToTab(2), // Go to Gym tab
                        icon: const Icon(Icons.fitness_center, size: 16),
                        label: const Text('Abrir Rutina'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Card(
                    color: AppTheme.darkCard,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onNavigateToTab(2),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todayRoutineName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workoutProv.exercises.length} ejercicios planificados',
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatColumn(
                                  label: 'VOLUMEN TOTAL',
                                  value: '${workoutProv.currentSessionVolume.toStringAsFixed(0)} kg',
                                  color: AppTheme.primaryColor,
                                ),
                                _StatColumn(
                                  label: 'SERIES COMPLETADAS',
                                  value: '${workoutProv.completedSetsCount} / ${workoutProv.totalSetsCount}',
                                  color: AppTheme.statusCompleted,
                                ),
                                _StatColumn(
                                  label: 'ESTADO',
                                  value: workoutProv.currentSession?.isFinished == true ? 'Finalizado' : 'En progreso',
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
