import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/overview/overview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WiandLoApp());
}

class WiandLoApp extends StatelessWidget {
  const WiandLoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiandLo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const OverviewScreen(),
    );
  }
}
