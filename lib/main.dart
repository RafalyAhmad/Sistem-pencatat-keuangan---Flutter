import 'package:flutter/material.dart';
import 'package:money_tracker_1/presentation/homescreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: MaterialApp(home: ScreenHome()));
  }
}
