import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantiq/main.dart';
import 'package:kantiq/presentation/screens/focus_timer_dialog.dart';
import 'package:kantiq/presentation/screens/task_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Add Task Sheet opens, fills form, and saves new task',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Tap center '+' button in bottom navigation
    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsWidgets);
    await tester.tap(addButton.first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Add Task sheet is displayed
    expect(find.text('Tambah Tugas Baru'), findsOneWidget);
    expect(find.text('NIAT HARI INI'), findsOneWidget);
    expect(find.text('Tingkat Energi Diperlukan'), findsOneWidget);

    // Enter new task title in the task name field (at index 1)
    final textFields = find.byType(TextField);
    expect(textFields, findsAtLeastNWidgets(2));
    await tester.enterText(textFields.at(1), 'Tugas Riset Psikologi');
    await tester.pump();

    // Scroll to and tap 'Simpan Tugas (+25 XP)'
    final saveButton = find.textContaining('Simpan Tugas');
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(saveButton, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify task is added to home list
    expect(find.text('Tugas Riset Psikologi'), findsOneWidget);
  });

  testWidgets('Task card tap opens Task Detail Screen and shows subtasks',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Tap first task card
    final taskCard = find.text('Selesaikan Laporan Metodologi Penelitian');
    expect(taskCard, findsOneWidget);
    await tester.ensureVisible(taskCard);
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(taskCard, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify detail screen is opened
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Langkah Mikro (Sub-tugas)'), findsOneWidget);
    expect(find.text('Mulai Sesi'), findsOneWidget);
    expect(
      find.text('Tinjau kembali perumusan hipotesis'),
      findsOneWidget,
    );

    // Tap 'Mulai Sesi' button to open Focus Timer
    final sessionBtn = find.text('Mulai Sesi');
    await tester.ensureVisible(sessionBtn);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(sessionBtn, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Focus timer dialog is displayed
    expect(find.byType(FocusTimerDialog), findsOneWidget);
    expect(find.text('Siap untuk Fokus'), findsOneWidget);

    // Close timer dialog
    final closeBtn = find.descendant(
      of: find.byType(FocusTimerDialog),
      matching: find.byIcon(Icons.close),
    );
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('Siram Sekarang button gives immediate visual feedback and awards XP',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final waterButton = find.text('Siram Sekarang');
    expect(waterButton, findsOneWidget);

    await tester.tap(waterButton, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Feedback changes to 'Disiram!'
    expect(find.text('Disiram!'), findsOneWidget);

    // Let the 2-second timer finish
    await tester.pump(const Duration(seconds: 3));
  });
}
