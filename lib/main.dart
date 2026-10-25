import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CampusEventExplorerApp());
}

class CampusEventExplorerApp extends StatelessWidget {
  const CampusEventExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Event Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF17646B)),
        // Bundled custom font declared in pubspec.yaml.
        fontFamily: 'Poppins',
      ),
      home: const HomeScreen(),
    );
  }
}
