import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_model.dart';

class ExercisePhotoViewerDialog extends StatelessWidget {
  final Exercise exercise;

  const ExercisePhotoViewerDialog({super.key, required this.exercise});

  static void show(BuildContext context, {required Exercise exercise}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ExercisePhotoViewerDialog(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = exercise.imageUrl != null && exercise.imageUrl!.trim().isNotEmpty;
    final hasInstructions = exercise.instructions != null && exercise.instructions!.trim().isNotEmpty;

    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      exercise.muscleGroup.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),

            // Image Area with Zoom
            Flexible(
              child: Container(
                color: Colors.black,
                constraints: const BoxConstraints(minHeight: 250, maxHeight: 420),
                child: hasImage
                    ? ClipRect(
                        child: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Center(
                            child: _buildImage(exercise.imageUrl!.trim()),
                          ),
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Sin foto asignada',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Bottom Area: instructions and targets
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'Objetivo: ${exercise.defaultSets} series × ${exercise.defaultReps}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (hasInstructions) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, size: 14, color: Colors.amber),
                              SizedBox(width: 6),
                              Text(
                                'Técnica & Postura:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.instructions!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://') || kIsWeb) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text('No se pudo cargar la imagen remota', style: TextStyle(color: Colors.redAccent)),
        ),
      );
    } else {
      return Image.file(
        io.File(url),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text('No se pudo cargar el archivo local', style: TextStyle(color: Colors.redAccent)),
        ),
      );
    }
  }
}
