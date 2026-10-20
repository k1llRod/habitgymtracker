import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/workout_set_model.dart';
import 'exercise_photo_viewer_dialog.dart';
import 'exercise_photo_widget.dart';
import 'rest_timer_dialog.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final WorkoutSet? lastSet;
  final Function(WorkoutSet) onUpdateSet;
  final Function(String) onToggleComplete;
  final VoidCallback onAddSet;
  final Function(String) onDeleteSet;
  final VoidCallback? onEditExercise;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.sets,
    this.lastSet,
    required this.onUpdateSet,
    required this.onToggleComplete,
    required this.onAddSet,
    required this.onDeleteSet,
    this.onEditExercise,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = exercise.imageUrl != null && exercise.imageUrl!.trim().isNotEmpty;
    final hasInstructions = exercise.instructions != null && exercise.instructions!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Photo Thumbnail
                Stack(
                  children: [
                    ExercisePhotoWidget(
                      imageUrl: exercise.imageUrl,
                      width: 58,
                      height: 58,
                      borderRadius: 10,
                      onTap: hasPhoto
                          ? () => ExercisePhotoViewerDialog.show(context, exercise: exercise)
                          : onEditExercise,
                      placeholder: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add_a_photo_outlined, size: 20, color: Colors.grey),
                          tooltip: 'Añadir foto de guía',
                          onPressed: onEditExercise,
                        ),
                      ),
                    ),
                    if (hasPhoto)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.zoom_in, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: exercise.isWarmup
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : AppTheme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              exercise.isWarmup ? 'CALENTAMIENTO' : exercise.muscleGroup.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: exercise.isWarmup ? Colors.orange : AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${exercise.defaultSets} × ${exercise.defaultReps}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Header Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEditExercise != null)
                      IconButton(
                        tooltip: 'Modificar ejercicio o foto',
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                        onPressed: onEditExercise,
                      ),
                    IconButton(
                      tooltip: 'Temporizador de descanso',
                      icon: const Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
                      onPressed: () => RestTimerDialog.show(context),
                    ),
                  ],
                ),
              ],
            ),

            if (lastSet != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.history, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Anterior: ${lastSet!.weightKg > 0 ? '${lastSet!.weightKg} kg' : ''} × ${lastSet!.reps} reps',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],

            if (hasInstructions) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => ExercisePhotoViewerDialog.show(context, exercise: exercise),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          exercise.instructions!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.amber),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.amber),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),

            // Header for Sets table
            const Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text('SET', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text('PESO (KG)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text('REPETICIONES', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Text('ESTADO', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // List of Sets
            ...sets.map((set) => _SetRow(
              set: set,
              onUpdate: onUpdateSet,
              onToggleComplete: () {
                onToggleComplete(set.id);
                if (!set.isCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 4),
                      content: const Text('¡Serie completada!'),
                      action: SnackBarAction(
                        label: 'DESCANSO 90s',
                        textColor: AppTheme.primaryColor,
                        onPressed: () => RestTimerDialog.show(context, seconds: 90),
                      ),
                    ),
                  );
                }
              },
              onDelete: () => onDeleteSet(set.id),
            )),

            const SizedBox(height: 8),
            // Add Set button
            OutlinedButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Añadir Serie'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size.fromHeight(36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final WorkoutSet set;
  final Function(WorkoutSet) onUpdate;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const _SetRow({
    required this.set,
    required this.onUpdate,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weightKg > 0 ? widget.set.weightKg.toString() : '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set.weightKg != widget.set.weightKg &&
        _weightController.text != widget.set.weightKg.toString()) {
      _weightController.text = widget.set.weightKg > 0 ? widget.set.weightKg.toString() : '';
    }
    if (oldWidget.set.reps != widget.set.reps &&
        _repsController.text != widget.set.reps.toString()) {
      _repsController.text = widget.set.reps > 0 ? widget.set.reps.toString() : '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final reps = int.tryParse(_repsController.text.trim()) ?? 0;

    if (weight != widget.set.weightKg || reps != widget.set.reps) {
      widget.onUpdate(widget.set.copyWith(
        weightKg: weight,
        reps: reps,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.set.isCompleted;

    return Dismissible(
      key: Key(widget.set.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.redAccent.withValues(alpha: 0.8),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDone ? AppTheme.statusCompleted.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Set Number
            SizedBox(
              width: 36,
              child: Center(
                child: Text(
                  '${widget.set.setNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDone ? AppTheme.statusCompleted : Colors.white,
                  ),
                ),
              ),
            ),

            // Weight Input
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.white70 : Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: EdgeInsets.zero,
                    fillColor: isDone ? Colors.black26 : AppTheme.darkSurface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDone ? AppTheme.statusCompleted.withValues(alpha: 0.4) : Colors.white10,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Reps Input
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.white70 : Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: EdgeInsets.zero,
                    fillColor: isDone ? Colors.black26 : AppTheme.darkSurface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDone ? AppTheme.statusCompleted.withValues(alpha: 0.4) : Colors.white10,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Complete Status Toggle Checkbox
            SizedBox(
              width: 48,
              child: Center(
                child: InkWell(
                  onTap: widget.onToggleComplete,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? AppTheme.statusCompleted : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 20,
                      color: isDone ? Colors.white : Colors.white30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
