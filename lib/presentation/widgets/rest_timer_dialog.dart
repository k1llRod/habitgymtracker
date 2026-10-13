import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RestTimerDialog extends StatefulWidget {
  final int initialSeconds;

  const RestTimerDialog({super.key, this.initialSeconds = 90});

  static Future<void> show(BuildContext context, {int seconds = 90}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RestTimerDialog(initialSeconds: seconds),
    );
  }

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _totalSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _totalSeconds = seconds;
      _remainingSeconds = seconds;
    });
    _startTimer();
  }

  void _addSeconds(int secs) {
    setState(() {
      _remainingSeconds = (_remainingSeconds + secs).clamp(0, 600);
      if (_remainingSeconds > _totalSeconds) _totalSeconds = _remainingSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return AlertDialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Descanso entre series', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Circular Progress Indicator with Time in Center
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 10 ? AppTheme.statusMissed : AppTheme.primaryColor,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: _remainingSeconds == 0 ? AppTheme.statusCompleted : Colors.white,
                    ),
                  ),
                  Text(
                    _remainingSeconds == 0 ? '¡A darle!' : (_isRunning ? 'Descansando...' : 'Pausado'),
                    style: TextStyle(
                      fontSize: 13,
                      color: _remainingSeconds == 0 ? AppTheme.statusCompleted : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Time Adjustments: +15s / -15s
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => _addSeconds(-15),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('-15s'),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  iconSize: 28,
                ),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => _addSeconds(15),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('+15s'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Presets: 30s, 60s, 90s, 120s
          Wrap(
            spacing: 8,
            children: [30, 60, 90, 120].map((secs) {
              return ChoiceChip(
                label: Text('${secs}s'),
                selected: _totalSeconds == secs,
                onSelected: (_) => _resetTimer(secs),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: _totalSeconds == secs ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
