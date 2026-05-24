import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/shell/main_shell.dart';

void main() {
  runApp(const ReparPhoneApp());
}

class ReparPhoneApp extends StatelessWidget {
  const ReparPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReparPhone Devis V3',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: const MainShell(),
    );
  }
}
