import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/habit_provider.dart';
import 'presentation/providers/workout_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  runApp(const HabitGymTrackerApp());
}

class HabitGymTrackerApp extends StatelessWidget {
  const HabitGymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HabitProvider()..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider()..loadData(),
        ),
      ],
      child: MaterialApp(
        title: 'Habit & Gym Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
