enum Priority { normal, important, veryImportant }

enum Status { todo, focused, done }

class TaskFields {
  static String id = '_id';
  static String title = 'title';
  static String description = 'description';
  static String priority = 'priority';
  static String status = 'status';
  static String isDeadline = 'isDeadline';
  static String time = 'time';
  static String interval = 'interval';
}

class Task {
  int id;
  String title;
  String description;
  Priority priority;
  bool isDeadline;
  DateTime time;
  Duration interval;
  Status status;

  Task(
      {required this.id,
      required this.title,
      required this.description,
      required this.priority,
      required this.time,
      required this.interval,
      this.isDeadline = false,
      this.status = Status.todo});

  Map<String, dynamic> toJson() {
    return {
      TaskFields.id: id,
      TaskFields.title: title,
      TaskFields.description: description,
      TaskFields.priority: priority.index,
      TaskFields.isDeadline: isDeadline ? 1 : 0,
      TaskFields.time: time2str(time),
      TaskFields.interval: dur2str(interval),
      TaskFields.status: status.index
    };
  }

  static String time2str(DateTime t) {
    return "${t.year}:${t.month}:${t.day}:${t.hour}:${t.minute}";
  }

  static DateTime str2time(String str) {
    List<String> sl = str.split(':');
    if (sl.length < 5) throw ("Invalid time string");
    return DateTime(
      int.parse(sl[0]),
      int.parse(sl[1]),
      int.parse(sl[2]),
      int.parse(sl[3]),
      int.parse(sl[4]),
    );
  }

  static String dur2str(Duration dur) {
    return "${dur.inMinutes}";
  }

  static Duration str2dur(String str) {
    return Duration(minutes: int.parse(str));
  }

  static Task fromJson(Map<String, Object?> json) {
    Priority priority = Priority.normal;
    Status status = Status.todo;

    switch (json[TaskFields.status] as int) {
      case 1:
        status = Status.focused;
        break;
      case 2:
        status = Status.done;
        break;
      default:
    }

    switch (json[TaskFields.priority] as int) {
      case 1:
        priority = Priority.important;
        break;
      case 2:
        priority = Priority.veryImportant;
        break;
      default:
    }

    bool isdl = (json[TaskFields.isDeadline] as int) == 1;

    return Task(
        id: json[TaskFields.id] as int,
        title: json[TaskFields.title] as String,
        description: json[TaskFields.description] as String,
        priority: priority,
        isDeadline: isdl,
        time: str2time(json[TaskFields.time] as String),
        interval: str2dur(json[TaskFields.interval] as String),
        status: status);
  }

  Task copy(
          {int? id,
          String? title,
          String? description,
          Priority? priority,
          bool? isDeadline,
          DateTime? time,
          Duration? interval,
          Status? status}) =>
      Task(
          id: id ?? this.id,
          title: title ?? this.title,
          description: description ?? this.description,
          priority: priority ?? this.priority,
          isDeadline: isDeadline ?? this.isDeadline,
          time: time ?? this.time,
          interval: interval ?? this.interval,
          status: status ?? this.status);
}
