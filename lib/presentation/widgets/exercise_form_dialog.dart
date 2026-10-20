import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';
import 'exercise_photo_widget.dart';

class ExerciseFormDialog extends StatefulWidget {
  final String dayKey;
  final Exercise? initialExercise;
  final int nextOrderIndex;

  const ExerciseFormDialog({
    super.key,
    required this.dayKey,
    this.initialExercise,
    this.nextOrderIndex = 0,
  });

  static Future<Exercise?> show(
    BuildContext context, {
    required String dayKey,
    Exercise? initialExercise,
    int nextOrderIndex = 0,
  }) {
    return showDialog<Exercise>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ExerciseFormDialog(
        dayKey: dayKey,
        initialExercise: initialExercise,
        nextOrderIndex: nextOrderIndex,
      ),
    );
  }

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _selectedMuscle = 'Pectorales';
  int _sets = 4;
  bool _isWarmup = false;
  String? _imageUrl;

  static const List<String> muscleGroups = [
    'Pectorales',
    'Espalda',
    'Piernas',
    'Cuádriceps',
    'Femorales',
    'Glúteos',
    'Pantorrillas',
    'Bíceps',
    'Tríceps',
    'Hombros',
    'Trapecio',
    'Abdominales / Core',
    'Cardio',
    'Cuerpo Completo',
  ];

  static const List<String> repPresets = [
    '10-12 reps',
    '8-10 reps',
    '12-15 reps',
    '6-8 reps',
    '20-25 reps',
    'Al fallo',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialExercise;
    if (init != null) {
      _nameController.text = init.name;
      _repsController.text = init.defaultReps;
      _instructionsController.text = init.instructions ?? '';
      _selectedMuscle = muscleGroups.contains(init.muscleGroup)
          ? init.muscleGroup
          : muscleGroups.first;
      _sets = init.defaultSets;
      _isWarmup = init.isWarmup;
      _imageUrl = init.imageUrl;
    } else {
      _repsController.text = '10-12 reps';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _imageUrl = picked.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a la imagen: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _promptUrlImage() async {
    final urlController = TextEditingController(text: _imageUrl ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Enlace URL de Imagen'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://ejemplo.com/ejercicio.jpg',
            labelText: 'URL de la foto / GIF',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(urlController.text.trim()),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _imageUrl = result;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final reps = _repsController.text.trim().isEmpty ? '10-12 reps' : _repsController.text.trim();
    final instructions = _instructionsController.text.trim().isEmpty
        ? null
        : _instructionsController.text.trim();

    final exercise = Exercise(
      id: widget.initialExercise?.id ?? 'ex_${const Uuid().v4().substring(0, 8)}',
      dayKey: widget.dayKey,
      muscleGroup: _selectedMuscle,
      name: name,
      defaultSets: _sets,
      defaultReps: reps,
      isWarmup: _isWarmup,
      orderIndex: widget.initialExercise?.orderIndex ?? widget.nextOrderIndex,
      imageUrl: (_imageUrl != null && _imageUrl!.trim().isNotEmpty) ? _imageUrl!.trim() : null,
      instructions: instructions,
    );

    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExercise != null;

    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 750),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note : Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Modificar Ejercicio' : 'Nuevo Ejercicio',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),

            // Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Photo
                      const Text(
                        'Foto de Referencia / Técnica',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Agrega una imagen para recordar la postura, el agarre o la máquina correcta.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 170,
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _imageUrl != null ? AppTheme.primaryColor.withValues(alpha: 0.5) : Colors.white12,
                              width: 1.5,
                            ),
                          ),
                          child: _imageUrl != null && _imageUrl!.trim().isNotEmpty
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ExercisePhotoWidget(
                                          imageUrl: _imageUrl,
                                          width: double.infinity,
                                          height: 170,
                                          borderRadius: 12,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black87,
                                        radius: 18,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                          onPressed: () => setState(() => _imageUrl = null),
                                          tooltip: 'Quitar foto',
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 44,
                                        color: AppTheme.primaryColor.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Ninguna foto seleccionada',
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Image Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined, size: 16),
                              label: const Text('Galería', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined, size: 16),
                              label: const Text('Cámara', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _promptUrlImage,
                              icon: const Icon(Icons.link, size: 16),
                              label: const Text('URL Web', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section: Exercise Name
                      const Text(
                        'Nombre del Ejercicio *',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ej. Press Militar con mancuernas en banco',
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa el nombre del ejercicio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Section: Muscle Group
                      const Text(
                        'Grupo Muscular',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMuscle,
                        dropdownColor: AppTheme.darkCard,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.accessibility_new),
                        ),
                        items: muscleGroups
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMuscle = val);
                        },
                      ),
                      const SizedBox(height: 18),

                      // Section: Sets & Reps
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sets Stepper
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Series Predeterminadas',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                        onPressed: _sets > 1 ? () => setState(() => _sets--) : null,
                                      ),
                                      Text(
                                        '$_sets',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                                        onPressed: _sets < 12 ? () => setState(() => _sets++) : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Reps Text / Presets
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Repeticiones Objetivo',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _repsController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: '10-12 reps',
                                    prefixIcon: Icon(Icons.repeat),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Quick Rep Presets
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: repPresets.map((preset) {
                          final isSelected = _repsController.text == preset;
                          return ChoiceChip(
                            label: Text(preset, style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _repsController.text = preset);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Warmup Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '¿Es serie de calentamiento / aproximación?',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        subtitle: const Text(
                          'No sumará fatiga máxima en los cálculos principales.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        value: _isWarmup,
                        activeColor: Colors.orange,
                        onChanged: (val) => setState(() => _isWarmup = val),
                      ),
                      const SizedBox(height: 14),

                      // Instructions / Technical notes
                      const Text(
                        'Instrucciones Técnicas / Consejos de Ejecución',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ej. Mantener codos a 45 grados, retracción escapular, bajar controlado en 2 segundos...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Colors.white12),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: Text(isEditing ? 'Guardar Cambios' : 'Crear Ejercicio'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
