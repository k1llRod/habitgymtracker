import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/routine_model.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_form_dialog.dart';
import '../widgets/exercise_photo_viewer_dialog.dart';
import '../widgets/exercise_photo_widget.dart';

class RoutineDetailEditorScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailEditorScreen({super.key, required this.routine});

  @override
  State<RoutineDetailEditorScreen> createState() =>
      _RoutineDetailEditorScreenState();
}

class _RoutineDetailEditorScreenState extends State<RoutineDetailEditorScreen> {
  late Routine _routine;
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _routine = widget.routine;
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    final workoutProv = context.read<WorkoutProvider>();
    final list = await workoutProv.getExercisesForRoutine(_routine.dayKey);
    setState(() {
      _exercises = list;
      _isLoading = false;
    });
  }

  Future<void> _editRoutineInfo() async {
    final nameCtrl = TextEditingController(text: _routine.name);
    final descCtrl = TextEditingController(text: _routine.description ?? '');
    String selectedIcon = _routine.icon ?? '💪';

    final icons = ['💪', '🏋️‍♂️', '🦵', '🎯', '🔥', '⚡', '🏃‍♂️', '🧘‍♂️', '🥊', '🚴‍♂️'];

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Información de la Rutina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ícono representativo:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((emoji) {
                    final isSel = selectedIcon == emoji;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIcon = emoji),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryColor.withValues(alpha: 0.25) : AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? AppTheme.primaryColor : Colors.white12,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la rutina',
                    hintText: 'Ej. Pierna & Glúteos Hipertrofia',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción / Enfoque',
                    hintText: 'Ej. Día de fuerza pesada y bombeo final',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final updated = _routine.copyWith(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        icon: selectedIcon,
      );
      if (!mounted) return;
      final workoutProv = context.read<WorkoutProvider>();
      await workoutProv.addOrUpdateRoutine(updated);
      setState(() {
        _routine = updated;
      });
    }
  }

  Future<void> _addExercise() async {
    final nextOrder = _exercises.isEmpty ? 1 : _exercises.last.orderIndex + 1;
    final newExercise = await ExerciseFormDialog.show(
      context,
      dayKey: _routine.dayKey,
      nextOrderIndex: nextOrder,
    );

    if (newExercise != null) {
      if (!mounted) return;
      final workoutProv = context.read<WorkoutProvider>();
      await workoutProv.addOrUpdateExercise(newExercise);
      await _loadExercises();
    }
  }

  Future<void> _editExercise(Exercise ex) async {
    final updated = await ExerciseFormDialog.show(
      context,
      dayKey: _routine.dayKey,
      initialExercise: ex,
    );

    if (updated != null) {
      if (!mounted) return;
      final workoutProv = context.read<WorkoutProvider>();
      await workoutProv.addOrUpdateExercise(updated);
      await _loadExercises();
    }
  }

  Future<void> _deleteExercise(Exercise ex) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('¿Eliminar ejercicio?'),
        content: Text('Se eliminará "${ex.name}" de esta rutina.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final workoutProv = context.read<WorkoutProvider>();
      await workoutProv.deleteExercise(ex.id, dayKey: _routine.dayKey);
      await _loadExercises();
    }
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });

    final workoutProv = context.read<WorkoutProvider>();
    await workoutProv.reorderExercises(_exercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_routine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar detalles de la rutina',
            onPressed: _editRoutineInfo,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercise,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Añadir Ejercicio'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Routine Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.darkSurface,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _routine.icon ?? '💪',
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _routine.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_routine.description != null &&
                                _routine.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _routine.description!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${_exercises.length} ejercicios',
                                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ID: ${_routine.dayKey}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Helper drag notice
                if (_exercises.length > 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: AppTheme.darkCard,
                    child: const Row(
                      children: [
                        Icon(Icons.swap_vert, size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          'Mantén presionado y arrastra para reordenar los ejercicios',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                // Exercises List
                Expanded(
                  child: _exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fitness_center_outlined, size: 54, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text(
                                'Aún no hay ejercicios en esta rutina',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Toca el botón para añadir tu primer ejercicio con foto.',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _addExercise,
                                icon: const Icon(Icons.add),
                                label: const Text('Añadir Ejercicio'),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
                          itemCount: _exercises.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final ex = _exercises[index];
                            final hasPhoto = ex.imageUrl != null && ex.imageUrl!.isNotEmpty;
                            final hasNotes = ex.instructions != null && ex.instructions!.isNotEmpty;

                            return Card(
                              key: ValueKey(ex.id),
                              margin: const EdgeInsets.only(bottom: 10),
                              color: AppTheme.darkCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: ex.isWarmup
                                      ? Colors.orange.withValues(alpha: 0.3)
                                      : Colors.white10,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                leading: Stack(
                                  children: [
                                    ExercisePhotoWidget(
                                      imageUrl: ex.imageUrl,
                                      width: 54,
                                      height: 54,
                                      borderRadius: 8,
                                      onTap: hasPhoto
                                          ? () => ExercisePhotoViewerDialog.show(context, exercise: ex)
                                          : () => _editExercise(ex),
                                    ),
                                    if (hasPhoto)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
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
                                title: Text(
                                  ex.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: ex.isWarmup
                                                ? Colors.orange.withValues(alpha: 0.2)
                                                : AppTheme.primaryColor.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            ex.isWarmup ? 'CALENTAMIENTO' : ex.muscleGroup.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: ex.isWarmup ? Colors.orange : AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${ex.defaultSets} × ${ex.defaultReps}',
                                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    if (hasNotes) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.info_outline, size: 12, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              ex.instructions!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white70),
                                      tooltip: 'Editar ejercicio y foto',
                                      onPressed: () => _editExercise(ex),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                      tooltip: 'Eliminar ejercicio',
                                      onPressed: () => _deleteExercise(ex),
                                    ),
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 4, right: 4),
                                        child: Icon(Icons.drag_handle, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _editExercise(ex),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
