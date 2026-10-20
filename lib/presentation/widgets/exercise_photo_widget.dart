import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ExercisePhotoWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  final VoidCallback? onTap;
  final Widget? placeholder;

  const ExercisePhotoWidget({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.borderRadius = 10,
    this.fit = BoxFit.cover,
    this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    Widget content;
    if (!hasImage) {
      content = placeholder ?? _defaultPlaceholder();
    } else {
      content = _buildImage(imageUrl!.trim());
    }

    final clip = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppTheme.darkCard,
        child: content,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: clip,
      );
    }

    return clip;
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://') || kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _defaultPlaceholder(hasError: true);
        },
      );
    } else {
      return Image.file(
        io.File(url),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _defaultPlaceholder(hasError: true);
        },
      );
    }
  }

  Widget _defaultPlaceholder({bool hasError = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(
          color: hasError ? Colors.redAccent.withValues(alpha: 0.3) : Colors.white12,
        ),
      ),
      child: Center(
        child: Icon(
          hasError ? Icons.broken_image_outlined : Icons.fitness_center,
          size: (width * 0.4).clamp(16, 32),
          color: hasError ? Colors.redAccent.withValues(alpha: 0.6) : Colors.grey.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
