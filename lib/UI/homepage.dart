import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:taskrace/Data/user_data.dart';
import 'package:taskrace/Data/viewmodel.dart';
import 'package:taskrace/Services/notification_api.dart';
import 'package:taskrace/Theme/theme.dart';
import 'package:taskrace/UI/about.dart';
import 'package:taskrace/UI/help.dart';
import 'package:taskrace/UI/progress_screen.dart';
import '../Theme/typography.dart';

class TaskRaceHomePage extends StatefulWidget {
  const TaskRaceHomePage({super.key});

  static const routeName = "/home";

  @override
  State<TaskRaceHomePage> createState() => _TaskRaceHomePageState();
}

class _TaskRaceHomePageState extends State<TaskRaceHomePage> {
  int days = 0;
  int hours = 0;
  int minutes = 30;
  bool _timePickingMode = false;
  bool isdeadline = false;

  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    listenNotifications();
  }

  void listenNotifications() =>
      NotificationApi.onNotification.stream.listen(((_) {}));

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TaskViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Todo Race", style: TaskRaceTypography.appTitle),
            FutureBuilder(
                future: viewModel.dbManager.getInt("score"),
                builder: ((context, snapshot) {
                  viewModel.setScore();
                  return Text(
                      "LVL : ${TaskViewModel.levelFromScore(viewModel.score)}",
                      style: TaskRaceTypography.title);
                }))
          ],
        ),
      ),
      drawer: FutureBuilder(
        future: viewModel.dbManager.getInt("score"),
        builder: (context, snapshot) => navDrawer(viewModel.score),
      ),
      body: FutureBuilder(
        future: viewModel.dbManager.getTasks(),
        builder: (context, snapshot) {
          if (viewModel.taskslength == 0) {
            viewModel.sortTasks(viewModel.dbManager.getTasks());
          }
          return taskRaceAppBody(
              viewModel.tasks,
              viewModel.expandedCardIndex,
              viewModel.currentScreen,
              viewModel.itemStatusUpdate,
              viewModel.setExpandedCardIndex,
              viewModel.changeTitle,
              viewModel.changeDescription,
              viewModel.changePriority,
              viewModel.changeTime,
              viewModel.gotoScreen,
              viewModel.updateDB);
        },
      ),
      bottomNavigationBar: taskRaceBNB(viewModel.currentScreen,
          viewModel.gotoScreen, viewModel.setExpandedCardIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: viewModel.currentScreen == Status.todo &&
              !_timePickingMode &&
              viewModel.expandedCardIndex == -1
          ? Card(
              shape: const BeveledRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                onPressed: () {
                  if (viewModel.expandedCardIndex == -1) {
                    setState(() {
                      viewModel.addTask();
                    });
                  }
                },
                child: const Icon(Icons.add, size: 32),
              ),
            )
          : null,
    );
  }

  Widget navDrawer(int score) {
    return Drawer(
      backgroundColor: TaskRaceTheme.secondaryColor,
      elevation: 4,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: ListView(
        children: [
          Container(
            color: TaskRaceTheme.primarycolor,
            child: Column(
              children: [
                Image.asset(
                  "assests/ic_launcher.png",
                ),
                Text(
                  "Task Race",
                  style: TaskRaceTypography.appTitle,
                ),
              ],
            ),
          ),
          TextButton(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all(TaskRaceTheme.onPrimary)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ProgressScreen.routeName,
                  arguments: score);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.score),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Progress",
                    style: TaskRaceTypography.title,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all(TaskRaceTheme.onPrimary)),
            onPressed: (() {
              Navigator.pop(context);
              Navigator.pushNamed(context, HelpScreen.routeName);
            }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.help_center_sharp),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "How to use TaskRace",
                    style: TaskRaceTypography.title,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all(TaskRaceTheme.onPrimary)),
            onPressed: (() {
              Navigator.pop(context);
              Navigator.pushNamed(context, AboutScreen.routeName);
            }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.contact_mail),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "About Developer",
                    style: TaskRaceTypography.title,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget taskRaceBNB(
      Status curScreen, Function gotoScreen, Function setExpandedCardIndex) {
    return BottomAppBar(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: Status.values
            .map(
              (screen) => Card(
                elevation: 4,
                shape: BeveledRectangleBorder(
                    side: BorderSide(
                        color: curScreen == screen
                            ? TaskRaceTheme.primaryVariant
                            : Colors.transparent,
                        width: 4),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      TaskRaceTheme.primarycolor,
                      TaskRaceTheme.primaryVariant
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
                  child: TextButton(
                    onPressed: () => setState(() {
                      gotoScreen(screen);
                      setExpandedCardIndex(-1);
                    }),
                    child: Container(
                      height: 32,
                      width: 96,
                      alignment: Alignment.center,
                      child: Text(
                        screen.name.toUpperCase(),
                        style: curScreen == screen
                            ? TaskRaceTypography.bottomBarItemClicked
                            : TaskRaceTypography.bottomBarItemNotClicked,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget taskRaceAppBody(
      List<Task> tasks,
      int expandedCardIndex,
      Status currentScreen,
      Function itemStatusUpdate,
      Function setExpandedCardIndex,
      Function changeTitle,
      Function changeDescription,
      Function changePriority,
      Function changetInterval,
      Function gotoScreen,
      Function updateDB) {
    return ListView.builder(
      key: Key(currentScreen.name),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(tasks[index].title),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) => setState(() {
            if (index == expandedCardIndex) {
              setExpandedCardIndex(-1);
            } else if (index < expandedCardIndex) {
              setExpandedCardIndex(expandedCardIndex - 1);
            }
            itemStatusUpdate(index);
            _timePickingMode = false;
          }),
          child: Card(
            shape: const BeveledRectangleBorder(
                side: BorderSide(color: Colors.transparent, width: 2),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    topRight: Radius.circular(24))),
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  setExpandedCardIndex(expandedCardIndex == index ? -1 : index);
                  _timePickingMode = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    TaskRaceTheme.primarycolor,
                    TaskRaceTheme.primaryVariant
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
                child: taskCard(
                    index,
                    expandedCardIndex,
                    tasks[index],
                    currentScreen,
                    changeTitle,
                    changeDescription,
                    changePriority,
                    changetInterval,
                    updateDB),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget taskCard(
      int index,
      int expandedCardIndex,
      Task task,
      Status currentScreen,
      Function changeTitle,
      Function changeDescription,
      Function changePriority,
      Function changetInterval,
      Function updateDB) {
    if (index != expandedCardIndex) {
      return Text(
        task.title,
        style: TaskRaceTypography.title,
      );
    }

    if (currentScreen == Status.todo) {
      return editableFields(task, index, changeTitle, changeDescription,
          changePriority, changetInterval, updateDB);
    } else {
      return nonEditableFields(task);
    }
  }

  Widget editableFields(
      Task task,
      int index,
      Function changeTitle,
      Function changeDescription,
      Function changePriority,
      Function changeTime,
      Function updateDB) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Title", style: TaskRaceTypography.miniLabel),
        EditableText(
          controller: TextEditingController(text: task.title),
          focusNode: FocusNode(),
          style: TaskRaceTypography.title,
          cursorColor: TaskRaceTheme.secondaryColor,
          backgroundCursorColor: TaskRaceTheme.backgroundcolor,
          onChanged: (value) => changeTitle(index, value),
          onSubmitted: (value) => setState(() {
            updateDB(index);
          }),
        ),
        const Divider(),
        Text("Description", style: TaskRaceTypography.miniLabel),
        const SizedBox(height: 4),
        EditableText(
          controller: TextEditingController(text: task.description),
          focusNode: FocusNode(),
          style: TaskRaceTypography.description,
          maxLines: 5,
          cursorColor: TaskRaceTheme.secondaryColor,
          backgroundCursorColor: TaskRaceTheme.backgroundcolor,
          onChanged: (value) => changeDescription(index, value),
          onSubmitted: (_) => setState(() {
            updateDB(index);
          }),
        ),
        const Divider(),
        Text("Priority", style: TaskRaceTypography.miniLabel),
        const SizedBox(height: 4),
        DropdownButton<Priority>(
          value: task.priority,
          items: Priority.values.map((Priority value) {
            return DropdownMenuItem<Priority>(
              value: value,
              child: Text(value.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) => setState(() {
            changePriority(index, value);
          }),
        ),
        const Divider(),
        Text(_timePickingMode ? (isdeadline ? "Deadline" : "Interval") : "Time",
            style: TaskRaceTypography.miniLabel),
        const SizedBox(height: 4),
        if (_timePickingMode)
          isdeadline
              ? datePicker(task, index, changeTime)
              : intervalPicker(task, index, changeTime)
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              timeModeLabel("Interval", task),
              timeModeLabel("Deadline", task)
            ],
          )
      ],
    );
  }

  Widget timeModeLabel(String label, Task task) {
    return ElevatedButton(
      onPressed: () => setState(() {
        _timePickingMode = true;
        isdeadline = label == "Deadline";
        if (!isdeadline) {
          days = task.interval.inDays;
          hours = task.interval.inHours - days * 24;
          minutes = task.interval.inMinutes - task.interval.inHours * 60;
        }
      }),
      child: Text(label, style: TaskRaceTypography.defaultStyle),
    );
  }

  Widget datePicker(Task task, int index, Function changeTime) {
    changeTime(index, true, validify: true);
    return DateTimePicker(
      type: DateTimePickerType.dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 4 * 365)),
      initialDate: task.time,
      dateHintText: task.time.toIso8601String().split('.')[0],
      onChanged: (value) {
        setState(() {
          _timePickingMode = false;
          changeTime(index, true, time: DateTime.parse(value));
        });
      },
    );
  }

  Widget intervalPicker(Task task, int index, Function changeTime) {
    return Column(
      children: [
        Row(
          children: [
            numberPicker("Days", 0, 31, days, (value) => days = value),
            numberPicker("Hours", 0, 23, hours, (value) => hours = value),
            numberPicker("Minutes", 0, 59, minutes, (value) => minutes = value)
          ],
        ),
        ElevatedButton(
          onPressed: () => setState(() {
            Duration interval =
                Duration(days: days, hours: hours, minutes: minutes);
            interval =
                interval.inMinutes > 0 ? interval : const Duration(minutes: 1);
            changeTime(index, false, interval: interval);
            _timePickingMode = false;
          }),
          child: const Text("Confirm"),
        )
      ],
    );
  }

  Widget numberPicker(
      String label, int min, int max, int tvalue, Function onChanged) {
    return Column(
      children: [
        Text(label),
        NumberPicker(
          itemWidth: MediaQuery.of(context).size.width / 4 - 10,
          itemCount: 3,
          minValue: min,
          maxValue: max,
          value: tvalue,
          onChanged: (value) => setState(() {
            onChanged(value);
          }),
        ),
      ],
    );
  }

  Widget nonEditableFields(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Title",
          style: TaskRaceTypography.miniLabel,
        ),
        Text(
          task.title,
          style: TaskRaceTypography.title,
        ),
        const Divider(),
        Text("Description", style: TaskRaceTypography.miniLabel),
        const SizedBox(height: 4),
        Text(
          task.description,
          style: TaskRaceTypography.description,
        ),
        const Divider(),
        Text("Priority", style: TaskRaceTypography.miniLabel),
        const SizedBox(height: 4),
        Text(task.priority.name.toUpperCase()),
        const Divider(),
        Text(task.isDeadline ? "Deadline" : "Interval",
            style: TaskRaceTypography.miniLabel),
        const SizedBox(height: 4),
        Text(
            task.isDeadline
                ? task.time.toIso8601String().split('.')[0]
                : "${task.interval.inMinutes} minutes",
            style: TaskRaceTypography.defaultStyle)
      ],
    );
  }
}
