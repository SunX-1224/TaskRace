import 'package:taskrace/Services/notification_api.dart';

import 'user_data.dart';
import 'database.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskViewModel extends ChangeNotifier {
  DBManager dbManager = DBManager.instance;

  List<Task> _todo = List.empty(growable: true);
  List<Task> _focused = List.empty(growable: true);
  List<Task> _done = List.empty(growable: true);
  int _score = 0;

  int get score {
    return _score;
  }

  Status _currentScreen = Status.todo;
  int _expandedCardIndex = -1;
  final String _titleTemplate = "Task #";
  int get taskslength {
    return _todo.length + _focused.length + _done.length;
  }

  List<Task> get tasks {
    if (_currentScreen == Status.done) {
      return _done;
    } else if (_currentScreen == Status.focused) {
      return _focused;
    } else {
      return _todo;
    }
  }

  Status get currentScreen {
    return _currentScreen;
  }

  int get expandedCardIndex {
    return _expandedCardIndex;
  }

  Future sortTasks(Future<List<Task>>? ntasks) async {
    _todo = [];
    _focused = [];
    _done = [];
    if (ntasks != null) {
      for (var task in await ntasks) {
        if (task.status == Status.todo) {
          _todo.add(task);
        } else if (task.status == Status.focused) {
          _focused.add(task);
        } else {
          _done.add(task);
        }
      }
    }
  }

  Future setScore() async {
    _score = await dbManager.getInt("score");
  }

  int _getID() {
    int tId = 1;
    for (var task in _todo + _focused + _done) {
      if (task.id >= tId) {
        tId = task.id + 1;
      }
    }
    return tId;
  }

  void gotoScreen(Status screen) {
    _currentScreen = screen;
  }

  void addTask() {
    int nid = _getID();
    Task ntask = Task(
        id: nid,
        title: _titleTemplate + nid.toString(),
        description: "None",
        priority: Priority.normal,
        time: DateTime.now().add(const Duration(days: 1)),
        interval: const Duration(days: 0, hours: 1));
    _todo.add(ntask);
    dbManager.inserttask(ntask);
    setExpandedCardIndex(_todo.length - 1);
  }

  void changeTitle(int index, String value) {
    _todo[index] = _todo[index].copy(title: value == "" ? "None" : value);
  }

  void updateDB(int index) async {
    await dbManager.updateTask(_todo[index]);
  }

  void changeDescription(int index, String value) {
    _todo[index] = _todo[index].copy(description: value == "" ? "None" : value);
  }

  void changePriority(int index, Priority value) {
    _todo[index] = _todo[index].copy(priority: value);
    dbManager.updateTask(_todo[index]);
  }

  void changeTime(int index, bool isdeadline,
      {bool validify = false, DateTime? time, Duration? interval}) {
    if (validify) {
      if (isdeadline) {
        DateTime t = _todo[index].time.compareTo(DateTime.now()) == 1
            ? _todo[index].time
            : DateTime.now().add(const Duration(days: 1));
        _todo[index] = _todo[index].copy(isDeadline: true, time: t);
      } else {
        Duration d = _todo[index].interval.inMinutes <= 0
            ? const Duration(minutes: 5)
            : _todo[index].interval;
        _todo[index] = _todo[index].copy(isDeadline: false, interval: d);
      }
    } else {
      if (isdeadline) {
        _todo[index] = _todo[index].copy(isDeadline: true, time: time!);
      } else {
        _todo[index] =
            _todo[index].copy(isDeadline: false, interval: interval!);
      }
    }
    dbManager.updateTask(_todo[index]);
  }

  void setExpandedCardIndex(int index) {
    _expandedCardIndex = index;
  }

  void itemStatusUpdate(int index) async {
    Task removedTask;
    if (_currentScreen == Status.done) {
      removedTask = _done.removeAt(index);
      dbManager.deleteTask(removedTask);
    } else if (_currentScreen == Status.focused) {
      removedTask = _focused.removeAt(index).copy(status: Status.done);
      _done.add(removedTask);
      dbManager.updateTask(removedTask);
      bool elg = await NotificationApi.cancelTaskNotification(removedTask.id);
      if (elg) _score += removedTask.priority.index + 1;
      await dbManager.storeInt("score", _score);
    } else {
      removedTask = _todo.removeAt(index).copy(status: Status.focused);
      _focused.add(removedTask);
      dbManager.updateTask(removedTask);
      scheduleNotification(removedTask);
    }
  }

  void scheduleNotification(Task task) {
    Duration interval;
    List<int> prList;
    int secs;
    if (task.isDeadline) {
      interval = subPresent(task.time);
    } else {
      interval = task.interval;
    }
    secs = interval.inMinutes * 60;
    if (secs < 0) return;

    if (task.priority == Priority.veryImportant) {
      prList = secs >> 6 < 720 ? [30, 60, 90, 100] : [25, 50, 75, 95, 100];
    } else if (task.priority == Priority.important) {
      prList = secs >> 6 < 720 ? [40, 70, 100] : [30, 60, 90, 100];
    } else {
      prList = secs >> 6 < 720 ? [50, 100] : [40, 70, 100];
    }

    for (var i = 0; i < prList.length; i++) {
      int t = prList[i] * secs ~/ 100;
      Duration d = Duration(seconds: t);

      NotificationApi.showScheduledNotification(
          id: NotificationApi.generateID(task.id, i),
          scheduledDate: DateTime.now().add(d),
          title: generateTitle(secs - t),
          description: task.title);
    }
  }

  String generateTitle(int dSeconds) {
    Duration duration = Duration(seconds: dSeconds);
    int days = duration.inDays;
    int years = days ~/ 365;
    int months = (days - years * 365) * 12 ~/ 365;
    int hours = duration.inHours - days * 24;
    int minutes = duration.inMinutes - duration.inHours * 60;
    days = days - years * 365 - months * 365 ~/ 12;

    if (years > 0) return "$years years $months months $days days remaining";
    if (months > 0) return "$months months $days days remaining";
    if (days > 0) return "$days days $hours hours $minutes minutes remaining";
    if (hours > 0) return "$hours hours $minutes minutes remaining";
    if (dSeconds > 0) {
      return "$minutes minutes ${dSeconds - duration.inMinutes * 60} seconds remaining";
    }
    return "Time's up !! Hope you've Completed the task";
  }

  static Duration subPresent(DateTime time) {
    final now = DateTime.now();
    int dm = time.minute - now.minute;
    int dh = time.hour - now.hour;
    int dd = time.day -
        now.day +
        (time.month - now.month) * 365 ~/ 12 +
        (time.year - now.year) * 365;
    return Duration(days: dd, hours: dh, minutes: dm);
  }

  static int levelFromScore(int score) {
    int level = 0;
    int min = 0;
    int diff = 1;
    while (true) {
      diff += 2;
      min += diff;
      if (score ~/ min == 0) break;
      level += 1;
    }
    return level;
  }

  static int progress(int level, int score) {
    int min = 0;
    int max = 0;

    int diff = 1;
    for (int i = 0; i < level; i++) {
      diff += 2;
      min += diff;
    }
    diff += 2;
    max = min + diff;
    return ((score - min) / (max - min) * 100).ceil();
  }
}
