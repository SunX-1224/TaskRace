import 'package:flutter/material.dart';
import '../Theme/typography.dart';

const elements = """
Title : Title of the task (Default : Task#x)\n\n
Description : Description about the task (Default : None)\n\n
Priority : Priority level of the task (Used to set frequency of the notification)\n\n
Time :\n
    Interval : Target time interval for task to accomplish in\n
    Deadline : Deadline for the task to complete
""";

const suggestions = """
1 > Keep the title short and informative\n\n
2 > Add important and forgettable things in description for easy reminder later\n\n
3 > Choose the priority appropriately according to task or (use it according to number of reminders needed :: normal : 2, important : 3 - 4, very important : 4 - 5)\n\n
4 > Use time mode cleverly as need or if indecisible use 'Interval' for relatively short task (in range of days)
  and 'Deadline' for long task (months, years)\n\n
5 > Notification ringtone can be set as your like from application's setting page (Long press on app's icon on main menu to open it). 
You can also turn off notifications form here if you don't want to get reminded about your tasks.
""";

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
  static const routeName = "/help";
}

class _HelpScreenState extends State<HelpScreen> {
  int expandedCardIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Help", style: TaskRaceTypography.appTitle),
          ],
        ),
      ),
      body: helpBody(),
    );
  }

  Widget helpBody() {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: const BeveledRectangleBorder(
          side: BorderSide(width: 4, color: Colors.transparent),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(
              "Status",
              style: TaskRaceTypography.title,
            ),
            const Divider(),
            Text(
              """TODO : It is where you can add a new task. You can slide a task-card to right to move it into FOCUSED section. (All the elements of a task are explained below)\n""",
              style: TaskRaceTypography.description,
            ),
            Text(
              """FOCUSED : You can move a task into this section to focus on that task. Once a task is in this section, throughout the time until the task deadline is reached or its assigned interval is crossed, you will get reminders about time remaining to complete the task few times based on the priority of the task.\n""",
              style: TaskRaceTypography.description,
            ),
            Text(
              """Done : After you complete the task, you can slide the task to this section which holds all the task you've accomplished. You can slide the task to right to delete it if you want.\n
               """,
              style: TaskRaceTypography.description,
            ),
            const Divider(),
            Text(
              "Task Elements",
              style: TaskRaceTypography.title,
            ),
            const Divider(),
            Text(
              elements,
              style: TaskRaceTypography.description,
            ),
            const Divider(),
            Text(
              "Suggestions for Usage",
              style: TaskRaceTypography.title,
            ),
            const Divider(),
            Text(
              suggestions,
              style: TaskRaceTypography.description,
            )
          ],
        ),
      ),
    );
  }
}
