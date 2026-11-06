import 'package:flutter_test/flutter_test.dart';
import 'package:kantiq/main.dart';
import 'package:kantiq/presentation/widgets/energy_chip_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App loads MyPlan home screen with gamification and tasks',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Verify brand
    expect(find.text('MyPlan'), findsOneWidget);
    expect(find.text('Beranda'), findsAtLeastNWidgets(1));

    // Verify user greeting
    expect(find.textContaining('Amanda'), findsOneWidget);

    // Verify gamification widget
    expect(find.text('Taman Pikiran'), findsOneWidget);
    expect(find.textContaining('Monstera Sejuk'), findsOneWidget);
    expect(find.textContaining('Hari Beruntun'), findsOneWidget);

    // Verify filter chips
    expect(find.text('Semua'), findsOneWidget);
    expect(find.textContaining('Fokus Tinggi'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Sedang'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Santai'), findsAtLeastNWidgets(1));

    // Verify task cards
    expect(
      find.text('Selesaikan Laporan Metodologi Penelitian'),
      findsOneWidget,
    );
  });

  testWidgets('Bottom navigation switches tabs cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Tap Kalender tab
    await tester.tap(find.text('Kalender'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Kalender & Linimasa'), findsOneWidget);

    // Tap Statistik tab
    await tester.tap(find.text('Statistik'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Statistik Produktivitas'), findsOneWidget);
    expect(find.text('Grafik Produktivitas Mingguan'), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Profil Pengguna'), findsOneWidget);
    expect(find.text('Amanda'), findsOneWidget);
    expect(find.text('Kebun Tenang & Gamifikasi'), findsOneWidget);
  });

  testWidgets('Filter chips filter task list properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Initially all today tasks are visible
    expect(
      find.text('Selesaikan Laporan Metodologi Penelitian'),
      findsOneWidget,
    );
    expect(
      find.text('Brainstorming Ide Kampanye Media Sosial'),
      findsOneWidget,
    );

    // Tap '⚡ Fokus Tinggi' filter chip inside EnergyFilterBar
    final filterChip = find.descendant(
      of: find.byType(EnergyFilterBar),
      matching: find.text('⚡ Fokus Tinggi'),
    );
    expect(filterChip, findsOneWidget);
    await tester.tap(filterChip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // High focus should be visible, medium should not
    expect(
      find.text('Selesaikan Laporan Metodologi Penelitian'),
      findsOneWidget,
    );
    expect(
      find.text('Brainstorming Ide Kampanye Media Sosial'),
      findsNothing,
    );
  });
}
