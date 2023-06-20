import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskrace/Data/viewmodel.dart';
import 'package:taskrace/UI/about.dart';
import 'package:taskrace/UI/help.dart';
import 'package:taskrace/UI/homepage.dart';
import 'package:taskrace/UI/progress_screen.dart';
import 'Theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Race',
      theme: TaskRaceTheme.theme,
      home: ChangeNotifierProvider(
          create: (context) => TaskViewModel(),
          child: const TaskRaceHomePage()),
      routes: {
        ProgressScreen.routeName: (context) => const ProgressScreen(),
        HelpScreen.routeName: (context) => const HelpScreen(),
        AboutScreen.routeName: (context) => const AboutScreen()
      },
    );
  }
}
