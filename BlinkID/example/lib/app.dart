import 'package:flutter/material.dart';

import 'home_screen.dart';

class BlinkIdExampleApp extends StatelessWidget {
  const BlinkIdExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BlinkID Example',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}
