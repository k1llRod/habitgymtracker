import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_grid_item.dart';

class HabitMatrixScreen extends StatelessWidget {
  const HabitMatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final monthName = DateFormat('MMMM yyyy', 'es_ES').format(habitProv.currentMonth);
    final capitalizedMonth = monthName.isNotEmpty
        ? monthName[0].toUpperCase() + monthName.substring(1)
        : monthName;

    final daysInMonth = habitProv.daysInCurrentMonth;
    final today = DateTime.now();
    final isCurrentMonth = today.year == habitProv.currentMonth.year &&
        today.month == habitProv.currentMonth.month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matriz de Hábitos (1 - 31)'),
        actions: [
          IconButton(
            tooltip: 'Explicación y Leyenda',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLegendDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, habitProv),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Hábito'),
      ),
      body: habitProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month selector bar
                Container(
                  color: AppTheme.darkSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: habitProv.previousMonth,
                      ),
                      Text(
                        capitalizedMonth,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: habitProv.nextMonth,
                      ),
                    ],
                  ),
                ),

                // Adherence bar banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppTheme.darkCard,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Adherencia Global del Mes:',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '${habitProv.overallMonthlyAdherence}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.statusCompleted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bullet Journal Matrix Grid
                Expanded(
                  child: habitProv.habits.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay hábitos configurados.\n¡Toca "+" para agregar el primero!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 80),
                            child: DataTable(
                              columnSpacing: 6,
                              horizontalMargin: 12,
                              headingRowHeight: 48,
                              dataRowMinHeight: 46,
                              dataRowMaxHeight: 52,
                              columns: [
                                const DataColumn(
                                  label: SizedBox(
                                    width: 130,
                                    child: Text(
                                      'HÁBITO',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                                    ),
                                  ),
                                ),
                                // Days 1 to 31
                                ...List.generate(daysInMonth, (index) {
                                  final day = index + 1;
                                  final dayDate = DateTime(habitProv.currentMonth.year, habitProv.currentMonth.month, day);
                                  final weekdayLetter = DateFormat('E', 'es_ES').format(dayDate).substring(0, 1).toUpperCase();
                                  final isToday = isCurrentMonth && today.day == day;

                                  return DataColumn(
                                    label: SizedBox(
                                      width: 28,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            weekdayLetter,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: isToday ? AppTheme.primaryColor : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '$day',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isToday ? AppTheme.primaryColor : Colors.white,
                                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                const DataColumn(
                                  label: SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                        'RACHA',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: SizedBox(
                                    width: 45,
                                    child: Center(
                                      child: Text(
                                        '%',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              rows: habitProv.habits.map((habit) {
                                final stats = habitProv.getStats(habit.id);

                                return DataRow(
                                  cells: [
                                    // Habit title & icon with delete on long press
                                    DataCell(
                                      InkWell(
                                        onLongPress: () => _confirmDeleteHabit(context, habitProv, habit),
                                        child: SizedBox(
                                          width: 130,
                                          child: Row(
                                            children: [
                                              Text(habit.icon, style: const TextStyle(fontSize: 16)),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  habit.title,
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Days 1..daysInMonth
                                    ...List.generate(daysInMonth, (index) {
                                      final day = index + 1;
                                      final status = habitProv.getStatus(habit.id, day);
                                      final dateStr = habitProv.getDateStringForDay(day);
                                      final isToday = isCurrentMonth && today.day == day;

                                      return DataCell(
                                        HabitGridItem(
                                          day: day,
                                          status: status,
                                          isToday: isToday,
                                          onTap: () => habitProv.cycleStatus(habit.id, dateStr),
                                          onLongPress: () => _showStatusPickerDialog(
                                            context,
                                            habitProv,
                                            habit.id,
                                            dateStr,
                                            day,
                                          ),
                                        ),
                                      );
                                    }),
                                    // Current Streak
                                    DataCell(
                                      Center(
                                        child: Text(
                                          '🔥 ${stats.currentStreak}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                                        ),
                                      ),
                                    ),
                                    // Adherence %
                                    DataCell(
                                      Center(
                                        child: Text(
                                          '${stats.successRate.toInt()}%',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.statusCompleted),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),

                // Fast Legend Indicator footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppTheme.darkSurface,
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _legendItem('✔', 'Completado', AppTheme.statusCompleted),
                      _legendItem('✘', 'No completado', AppTheme.statusMissed),
                      _legendItem('-', 'Descanso', AppTheme.statusRest),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _legendItem(String icon, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Cómo funciona la Matriz de Hábitos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Toca cualquier celda para alternar entre estados:'),
            SizedBox(height: 6),
            Text('  1. ✔ Completado (Verde): Cumpliste el hábito.'),
            Text('  2. ✘ No completado (Rojo): No se realizó.'),
            Text('  3. - Descanso / Omitido (Naranja): Día justificado (mantiene racha).'),
            Text('  4. Vacío: Pendiente.'),
            SizedBox(height: 12),
            Text('• Mantén presionada una celda para elegir el estado directamente.'),
            Text('• Mantén presionado el nombre del hábito para eliminarlo.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showStatusPickerDialog(
    BuildContext context,
    HabitProvider prov,
    String habitId,
    String dateStr,
    int day,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar estado para el día $day',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppTheme.statusCompleted),
              title: const Text('Completado (✔)'),
              onTap: () {
                prov.setStatus(habitId, dateStr, HabitStatus.completed);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: AppTheme.statusMissed),
              title: const Text('No completado (✘)'),
              onTap: () {
                prov.setStatus(habitId, dateStr, HabitStatus.missed);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle, color: AppTheme.statusRest),
              title: const Text('Descanso / Omitido (-)'),
              onTap: () {
                prov.setStatus(habitId, dateStr, HabitStatus.rest);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              title: const Text('Limpiar / Sin registrar'),
              onTap: () {
                prov.setStatus(habitId, dateStr, HabitStatus.none);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHabit(BuildContext context, HabitProvider prov, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text('¿Eliminar "${habit.title}"?'),
        content: const Text('Se eliminará este hábito y todo su historial de registros.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusMissed),
            onPressed: () {
              prov.deleteHabit(habit.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitProvider prov) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = '🎯';

    final icons = ['🎯', '💧', '😴', '🥩', '🧘‍♂️', '📖', '🥗', '⚡', '🚴‍♂️', '🧠'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          title: const Text('Nuevo Hábito'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Hábito',
                    hintText: 'Ej. Meditar 10 minutos',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción / Propósito',
                    hintText: 'Ej. Claridad mental al despertar',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Elige un Icono / Emoji:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons.map((emoji) {
                    final isSel = selectedIcon == emoji;
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.darkCard,
                          border: isSel ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  prov.addHabit(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    icon: selectedIcon,
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
