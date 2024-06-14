import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/reminder.dart';

class GlobalBloc {
  // BehaviorSubject<Day> _selectedDay$;
  // BehaviorSubject<Day> get selectedDay$ => _selectedDay$.stream;

  // BehaviorSubject<Period> _selectedPeriod$;
  // BehaviorSubject<Period> get selectedPeriod$ => _selectedPeriod$.stream;

  late BehaviorSubject<List<Reminder>> _reminderList$;
  BehaviorSubject<List<Reminder>> get reminderList$ => _reminderList$;

  GlobalBloc() {
    _reminderList$ = BehaviorSubject<List<Reminder>>.seeded([]);
    makeReminderList();
    // _selectedDay$ = BehaviorSubject<Day>.seeded(Day.Saturday);
    // _selectedPeriod$ = BehaviorSubject<Period>.seeded(Period.Week);
  }

  // void updateSelectedDay(Day day) {
  //   _selectedDay$.add(day);
  // }

  // void updateSelectedPeriod(Period period) {
  //   _selectedPeriod$.add(period);
  // }

  Future removeReminder(Reminder tobeRemoved) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    List<String> reminderJsonList = [];

    var blocList = _reminderList$.value;
    blocList.removeWhere(
        (reminder) => reminder.desc == tobeRemoved.desc);

    for (int i = 0; i < (24 / tobeRemoved.interval).floor(); i++) {
      flutterLocalNotificationsPlugin
          .cancel(int.parse(tobeRemoved.notificationIDs[i]));
    }
    if (blocList.length != 0) {
      for (var blocreminder in blocList) {
        String reminderJson = jsonEncode(blocreminder.toJson());
        reminderJsonList.add(reminderJson);
      }
    }
    sharedUser.setStringList('reminders', reminderJsonList);
    _reminderList$.add(blocList);
  }

  Future updateReminderList(Reminder newReminder) async {
    var blocList = _reminderList$.value;
    blocList.add(newReminder);
    _reminderList$.add(blocList);
    Map<String, dynamic> tempMap = newReminder.toJson();
    print(tempMap);
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    String newReminderJson = jsonEncode(tempMap);
    List<String>? reminderJsonList = [];
    if (sharedUser.getStringList('reminders') == null) {
      reminderJsonList.add(newReminderJson);
    } else {
      reminderJsonList = sharedUser.getStringList('reminders');
      reminderJsonList?.add(newReminderJson);
    }
    sharedUser.setStringList('reminders', reminderJsonList!);
  }

  Future makeReminderList() async {
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    List<String>? jsonList = sharedUser.getStringList('reminders');
    List<Reminder> prefList = [];
    if (jsonList == null) {
      return;
    } else {
      for (String jsonReminder in jsonList) {
        Map<String, dynamic> userMap = jsonDecode(jsonReminder);
        Reminder tempReminder = Reminder.fromJson(userMap);
        prefList.add(tempReminder);
      }
      _reminderList$.add(prefList);
    }
  }

  void dispose() {
    // _selectedDay$.close();
    // _selectedPeriod$.close();
    _reminderList$.close();
  }
}
