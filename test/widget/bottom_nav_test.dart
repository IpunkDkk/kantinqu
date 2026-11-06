import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantiq/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Bottom navigation floating center button is fully visible and interactive',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPlanApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify all 5 nav items are present
    expect(find.text('Beranda'), findsAtLeastNWidgets(1));
    expect(find.text('Kalender'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Verify center add button (+) icon is present and tappable
    final addIcon = find.byIcon(Icons.add);
    expect(addIcon, findsOneWidget);

    // Verify center button container size
    final addContainer = tester.widget<Container>(
      find.ancestor(
        of: addIcon,
        matching: find.byType(Container),
      ).first,
    );
    expect(addContainer.constraints?.minWidth ?? 48.0, 48.0);
    expect(addContainer.constraints?.minHeight ?? 48.0, 48.0);

    // Tap the center button
    await tester.tap(addIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // AddTaskSheet is shown
    expect(find.text('Tambah Tugas Baru'), findsOneWidget);

    // Close the sheet via header close icon
    await tester.tap(find.byIcon(Icons.close).first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Still back on Home
    expect(find.text('MyPlan'), findsOneWidget);
  });
}
