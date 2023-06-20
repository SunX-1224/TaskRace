import 'package:flutter/material.dart';
import 'package:taskrace/Theme/theme.dart';
import '../Theme/typography.dart';
import '../Data/viewmodel.dart';
import '../UI/ui_helpers.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const routeName = "/progress_screen";
  @override
  Widget build(BuildContext context) {
    final score = ModalRoute.of(context)!.settings.arguments as int;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Progress", style: TaskRaceTypography.appTitle),
            Text(
              "Level ${TaskViewModel.levelFromScore(score)} : ${TaskViewModel.progress(TaskViewModel.levelFromScore(score), score)} %",
              style: TaskRaceTypography.title,
            ),
          ],
        ),
      ),
      body: progressScreenBody(score),
    );
  }

  Widget progressScreenBody(int score) {
    int level = TaskViewModel.levelFromScore(score);
    int progress = TaskViewModel.progress(level, score);
    const foregroundColor = Color(0xffaaaaaa);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: Ranks.values.length,
      itemBuilder: (context, index) {
        return Card(
          color: foregroundColor.withOpacity(index <= level ? 0 : 1),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.all(Radius.elliptical(24, 12))),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  Ranks.values[index].name.toUpperCase(),
                  style: index <= level
                      ? TaskRaceTypography.title
                      : TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: foregroundColor.withOpacity(1)),
                ),
              ),
              index <= level
                  ? LinearProgressIndicator(
                      color: TaskRaceTheme.primarycolor,
                      backgroundColor: TaskRaceTheme.secondaryColor,
                      minHeight: 8,
                      value: index < level ? 1 : progress / 100,
                    )
                  : const SizedBox(
                      height: 8,
                    ),
            ],
          ),
        );
      },
    );
  }
}
