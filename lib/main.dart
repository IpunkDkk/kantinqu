import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'providers/task_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyPlanApp());
}

class MyPlanApp extends StatelessWidget {
  const MyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'MyPlan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainShellScreen(),
      ),
    );
  }
}
