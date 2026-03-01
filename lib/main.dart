
import 'package:flutter/material.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/stats_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const LogicBombApp());
}

class LogicBombApp extends StatelessWidget {
  const LogicBombApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/stats': (_) => const StatsScreen(),
        '/game': (_) => const GameScreen(),
      },
    );
  }
}
