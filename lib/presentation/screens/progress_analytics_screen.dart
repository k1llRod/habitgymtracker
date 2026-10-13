import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/habit_provider.dart';
import '../providers/workout_provider.dart';

class ProgressAnalyticsScreen extends StatelessWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final workoutProv = context.watch<WorkoutProvider>();

    final habits = habitProv.habits;
    final volumeHistory = workoutProv.volumeHistory;

    int bestOverallStreak = 0;
    int totalCompletedHabitDays = 0;
    for (final h in habits) {
      final s = habitProv.getStats(h.id);
      if (s.bestStreak > bestOverallStreak) bestOverallStreak = s.bestStreak;
      totalCompletedHabitDays += s.completedDays;
    }

    double totalVolumeAccumulated = 0;
    for (final row in volumeHistory) {
      totalVolumeAccumulated += (row['totalVolume'] as num?)?.toDouble() ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas y Progreso'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 4 Big Metrics Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryStatCard(
                  title: 'MEJOR RACHA',
                  value: '🔥 $bestOverallStreak',
                  subtitle: 'días continuos',
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStatCard(
                  title: 'ADHERENCIA',
                  value: '${habitProv.overallMonthlyAdherence}%',
                  subtitle: 'este mes',
                  color: AppTheme.statusCompleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryStatCard(
                  title: 'VOLUMEN TOTAL',
                  value: '${(totalVolumeAccumulated / 1000).toStringAsFixed(1)} ton',
                  subtitle: '${totalVolumeAccumulated.toStringAsFixed(0)} kg movidos',
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStatCard(
                  title: 'HÁBITOS LOGRADOS',
                  value: '✔ $totalCompletedHabitDays',
                  subtitle: 'registros exitosos',
                  color: Colors.tealAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart 1: Volumen de Entrenamiento (Tonelaje por Sesión)
          const Text(
            'Volumen de Entrenamiento por Sesión (kg)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),

          Card(
            color: AppTheme.darkCard,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: volumeHistory.isEmpty
                  ? const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Completa series con peso para visualizar tu sobrecarga progresiva.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxVolume(volumeHistory) * 1.2,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final row = volumeHistory[group.x.toInt()];
                                final date = row['date'] as String? ?? '';
                                return BarTooltipItem(
                                  '$date\n${rod.toY.toStringAsFixed(0)} kg',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (val, meta) {
                                  if (val == meta.max || val == meta.min) return const SizedBox.shrink();
                                  return Text(
                                    val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : val.toInt().toString(),
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < volumeHistory.length) {
                                    final dateStr = volumeHistory[idx]['date'] as String? ?? '';
                                    final parts = dateStr.split('-');
                                    if (parts.length >= 3) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text('${parts[2]}/${parts[1]}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      );
                                    }
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (val) => const FlLine(color: Colors.white10, strokeWidth: 1),
                          ),
                          barGroups: List.generate(volumeHistory.length, (index) {
                            final row = volumeHistory[index];
                            final vol = (row['totalVolume'] as num?)?.toDouble() ?? 0.0;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: vol,
                                  color: AppTheme.primaryColor,
                                  width: 14,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Breakdown: Consistencia por Hábito
          const Text(
            'Consistencia y Adherencia por Hábito',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),

          ...habits.map((habit) {
            final stats = habitProv.getStats(habit.id);
            final rate = stats.successRate;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(habit.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            habit.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Text(
                          '${rate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: rate >= 80 ? AppTheme.statusCompleted : (rate >= 50 ? Colors.orangeAccent : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (rate / 100.0).clamp(0.0, 1.0),
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rate >= 80 ? AppTheme.statusCompleted : (rate >= 50 ? Colors.orangeAccent : AppTheme.primaryColor),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Racha actual: 🔥 ${stats.currentStreak} días', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('Mejor racha: 🏆 ${stats.bestStreak} días', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('✔ ${stats.completedDays} / ✘ ${stats.missedDays}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  double _getMaxVolume(List<Map<String, dynamic>> history) {
    double maxV = 1000.0;
    for (final h in history) {
      final v = (h['totalVolume'] as num?)?.toDouble() ?? 0.0;
      if (v > maxV) maxV = v;
    }
    return maxV;
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
