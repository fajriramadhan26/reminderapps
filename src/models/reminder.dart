class Reminder {
  final List<dynamic> notificationIDs;
  final String desc;
  final String loc;
  final int interval;
  final String startTime;

  Reminder({
    required this.notificationIDs,
    required this.desc,
    required this.loc,
    required this.startTime,
    required this.interval,
  });

  List<dynamic> get getIDs => notificationIDs;
  String get getDesc => desc;
  String get getLoc => loc;
  int get getInterval => interval;
  String get getStartTime => startTime;

  Map<String, dynamic> toJson() {
    return {
      "ids": this.notificationIDs,
      "desc": this.desc,
      "loc": this.loc,
      "interval": this.interval,
      "start": this.startTime,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> parsedJson) {
    return Reminder(
      notificationIDs: parsedJson['ids'],
      desc: parsedJson['desc'],
      loc: parsedJson['loc'],
      interval: parsedJson['interval'],
      startTime: parsedJson['start'],
    );
  }
}
