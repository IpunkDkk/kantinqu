import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantiq/presentation/screens/add_task_sheet.dart';
import 'package:kantiq/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'AddTaskSheet renders cleanly without overflow on small screens and high text scale',
      (WidgetTester tester) async {
    // Simulate narrow compact phone screen (320px width) with 1.3x text scale
    tester.view.physicalSize = const Size(320, 750);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 750),
              textScaler: TextScaler.linear(1.3),
            ),
            child: const Scaffold(
              body: AddTaskSheet(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify key titles are present and visible
    expect(find.text('Tambah Tugas Baru'), findsOneWidget);
    expect(find.text('NIAT HARI INI'), findsOneWidget);
    expect(find.text('Tingkat Energi Diperlukan'), findsOneWidget);
    expect(find.text('Pecah Jadi Langkah Mikro'), findsOneWidget);
    expect(find.text('Jadwal & Waktu Fokus'), findsOneWidget);
    expect(find.text('Pertumbuhan Kebun Tenang'), findsOneWidget);
    expect(find.textContaining('Simpan Tugas'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
  });

  testWidgets(
      'AddTaskSheet handles extreme narrow width (280px) and large accessibility font scale',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(280, 650);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(280, 650),
              textScaler: TextScaler.linear(1.4),
            ),
            child: const Scaffold(
              body: AddTaskSheet(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tambah Tugas Baru'), findsOneWidget);
  });
}
