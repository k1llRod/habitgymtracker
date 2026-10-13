import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/default_routines.dart';
import '../../core/theme/app_theme.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rest_timer_dialog.dart';

class WorkoutTrackerScreen extends StatelessWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProv = context.watch<WorkoutProvider>();

    final dayKeys = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes_a',
      'viernes_b',
    ];

    final dayLabels = [
      'LUN: Pecho/Bíceps',
      'MAR: Espalda/Tríceps',
      'MIÉ: Piernas/Cuádriceps',
      'JUE: Hombro/Trapecio',
      'VIE (A): Femoral/Glúteo',
      'VIE (B): Brazos',
    ];

    final currentDayTitle = DefaultData.dayNames[workoutProv.selectedDayKey] ?? 'Entrenamiento';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas de Gimnasio'),
        actions: [
          IconButton(
            tooltip: 'Cambiar Fecha',
            icon: const Icon(Icons.event),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: workoutProv.selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                workoutProv.selectDate(picked);
              }
            },
          ),
          IconButton(
            tooltip: 'Temporizador de Descanso',
            icon: const Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
            onPressed: () => RestTimerDialog.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => RestTimerDialog.show(context, seconds: 90),
        icon: const Icon(Icons.timer),
        label: const Text('Descanso 90s'),
      ),
      body: workoutProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Day Selector Horizontal Scroll
                Container(
                  color: AppTheme.darkSurface,
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: dayKeys.length,
                    itemBuilder: (context, index) {
                      final key = dayKeys[index];
                      final isSelected = workoutProv.selectedDayKey == key;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(dayLabels[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) workoutProv.selectDay(key);
                          },
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Session Summary Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppTheme.darkCard,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(workoutProv.selectedDate),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentDayTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _MetricPill(
                            icon: Icons.scale,
                            value: '${workoutProv.currentSessionVolume.toStringAsFixed(0)} kg',
                            label: 'Volumen',
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _MetricPill(
                            icon: Icons.check_circle_outline,
                            value: '${workoutProv.completedSetsCount}/${workoutProv.totalSetsCount}',
                            label: 'Series',
                            color: AppTheme.statusCompleted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Exercise Cards List
                Expanded(
                  child: workoutProv.exercises.isEmpty
                      ? const Center(child: Text('No hay ejercicios registrados para este día.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: workoutProv.exercises.length + 1,
                          itemBuilder: (context, index) {
                            if (index == workoutProv.exercises.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton.icon(
                                  onPressed: () => _showFinishDialog(context, workoutProv),
                                  icon: const Icon(Icons.flag),
                                  label: Text(workoutProv.currentSession?.isFinished == true
                                      ? 'Editar Notas de Sesión'
                                      : 'Finalizar Entrenamiento'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: workoutProv.currentSession?.isFinished == true
                                        ? AppTheme.statusCompleted
                                        : AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              );
                            }

                            final exercise = workoutProv.exercises[index];
                            final sets = workoutProv.getSetsForExercise(exercise.id);
                            final lastSet = workoutProv.lastSets[exercise.id];

                            return ExerciseCard(
                              exercise: exercise,
                              sets: sets,
                              lastSet: lastSet,
                              onUpdateSet: (s) => workoutProv.updateSet(s),
                              onToggleComplete: (id) => workoutProv.toggleSetCompleted(id),
                              onAddSet: () => workoutProv.addSetToExercise(exercise.id),
                              onDeleteSet: (id) => workoutProv.removeSet(id),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showFinishDialog(BuildContext context, WorkoutProvider prov) {
    final notesCtrl = TextEditingController(text: prov.currentSession?.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Completar Sesión de Hoy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volumen Total Levantado: ${prov.currentSessionVolume.toStringAsFixed(0)} kg\n'
              'Series Realizadas: ${prov.completedSetsCount} de ${prov.totalSetsCount}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas / Sensaciones de hoy',
                hintText: 'Ej. Buena congestión en pecho inclinado, subir peso la próxima semana...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              prov.finishSession(notesCtrl.text.trim());
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.statusCompleted,
                  content: Text('¡Entrenamiento registrado con éxito! 💪 Gran trabajo.'),
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
