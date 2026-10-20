import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/routine_model.dart';
import '../providers/workout_provider.dart';
import 'routine_detail_editor_screen.dart';

class RoutineManagementScreen extends StatelessWidget {
  const RoutineManagementScreen({super.key});

  Future<void> _showCreateRoutineDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = '💪';

    final icons = ['💪', '🏋️‍♂️', '🦵', '🎯', '🔥', '⚡', '🏃‍♂️', '🧘‍♂️', '🥊', '🚴‍♂️', '🥇', '🏆'];

    final result = await showDialog<Routine?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Crear Nueva Rutina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elige un ícono para tu rutina:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
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
                          color: isSel
                              ? AppTheme.primaryColor.withValues(alpha: 0.25)
                              : AppTheme.darkCard,
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
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Rutina *',
                    hintText: 'Ej. Sábado: Full Body & Core',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Descripción / Objetivo',
                    hintText: 'Ej. Rutina de bombeo y abdominales de fin de semana',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final rawKey = name
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9]'), '_')
                    .replaceAll(RegExp(r'_+'), '_');
                final dayKey = 'custom_${rawKey.isEmpty ? const Uuid().v4().substring(0, 6) : rawKey}';

                final newRoutine = Routine(
                  id: 'rot_${const Uuid().v4().substring(0, 8)}',
                  name: name,
                  dayKey: dayKey,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  icon: selectedIcon,
                  orderIndex: 99,
                  isCustom: true,
                );

                Navigator.of(ctx).pop(newRoutine);
              },
              child: const Text('Crear Rutina'),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      final workoutProv = context.read<WorkoutProvider>();
      await workoutProv.addOrUpdateRoutine(result);

      if (context.mounted) {
        // Open the editor directly for the new routine
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoutineDetailEditorScreen(routine: result),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteRoutine(BuildContext context, Routine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('¿Eliminar Rutina?'),
        content: Text(
          'Se eliminará "${routine.name}" y todos los ejercicios asignados a ella.',
          style: const TextStyle(color: Colors.white70),
        ),
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

    if (confirm == true && context.mounted) {
      final workoutProv = context.read<WorkoutProvider>();
      await workoutProv.deleteRoutine(routine);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rutina "${routine.name}" eliminada.'),
            backgroundColor: AppTheme.darkCard,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProv = context.watch<WorkoutProvider>();
    final routines = workoutProv.routines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Rutinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear nueva rutina',
            onPressed: () => _showCreateRoutineDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRoutineDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Rutina'),
      ),
      body: routines.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay rutinas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showCreateRoutineDialog(context),
                    child: const Text('Crear Primera Rutina'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: routines.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: AppTheme.primaryColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personaliza tus entrenamientos',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Selecciona cualquier rutina para modificar sus ejercicios, reordenarlos o agregar fotos explicativas.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final routine = routines[index - 1];
                final isSelectedActive = workoutProv.selectedDayKey == routine.dayKey;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppTheme.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelectedActive ? AppTheme.primaryColor : Colors.white10,
                      width: isSelectedActive ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RoutineDetailEditorScreen(routine: routine),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.darkCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Center(
                                  child: Text(
                                    routine.icon ?? '💪',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            routine.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        if (isSelectedActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Activa Hoy',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (routine.description != null && routine.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        routine.description!,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Colors.white10),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  workoutProv.selectDay(routine.dayKey);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Rutina "${routine.name}" seleccionada en el Gimnasio'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_circle_outline, size: 16),
                                label: const Text('Entrenar esta rutina', style: TextStyle(fontSize: 12)),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70),
                                    tooltip: 'Editar ejercicios y fotos',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => RoutineDetailEditorScreen(routine: routine),
                                        ),
                                      );
                                    },
                                  ),
                                  if (routine.isCustom)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      tooltip: 'Eliminar rutina',
                                      onPressed: () => _confirmDeleteRoutine(context, routine),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
