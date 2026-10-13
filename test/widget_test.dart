import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_gym_tracker/core/theme/app_theme.dart';
import 'package:habit_gym_tracker/data/models/habit_model.dart';
import 'package:habit_gym_tracker/presentation/widgets/habit_grid_item.dart';

void main() {
  testWidgets('HabitGridItem renders correctly and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: HabitGridItem(
            day: 15,
            status: HabitStatus.completed,
            isToday: true,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byType(HabitGridItem));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
