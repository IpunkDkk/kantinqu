import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kantiq/presentation/screens/profile_screen.dart';
import 'package:kantiq/presentation/screens/statistics_screen.dart';
import 'package:kantiq/providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('StatisticsScreen displays productivity charts, metrics, and cognitive balance',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const StatisticsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Statistik Produktivitas'), findsOneWidget);
    expect(find.text('Evaluasi Ritme & Fokus'), findsOneWidget);
    expect(find.text('Ringkasan Fokus'), findsOneWidget);
    expect(find.text('Jam Fokus'), findsOneWidget);
    expect(find.text('Grafik Produktivitas Mingguan'), findsOneWidget);
    expect(find.text('Keseimbangan Beban Kognitif'), findsOneWidget);
    expect(find.text('Jendela Emas Fokus Harian'), findsOneWidget);
  });

  testWidgets('ProfileScreen displays user identity, gamification hub, badges, and settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profil Pengguna'), findsOneWidget);
    expect(find.text('Amanda'), findsOneWidget);
    expect(find.text('Kebun Tenang & Gamifikasi'), findsOneWidget);
    expect(find.text('Monstera Sejuk'), findsOneWidget);
    expect(find.text('Lencana Pencapaian'), findsOneWidget);
    expect(find.text('Langkah Mikro'), findsOneWidget);
    expect(find.text('Pengaturan & Preferensi'), findsOneWidget);
    expect(find.text('Pengingat Lembut'), findsOneWidget);
  });
}
