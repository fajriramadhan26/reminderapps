import 'package:reminder/src/models/errors.dart';
import 'package:reminder/src/models/reminder.dart';
import 'package:rxdart/rxdart.dart';

class NewEntryBloc {

  // BehaviorSubject<List<Day>> _checkedDays$;
  // BehaviorSubject<List<Day>> get checkedDays$ => _checkedDays$;

  late BehaviorSubject<int> _selectedInterval$;
  BehaviorSubject<int> get selectedInterval$ => _selectedInterval$;

  late BehaviorSubject<String> _selectedTimeOfDay$;
  BehaviorSubject<String> get selectedTimeOfDay$ => _selectedTimeOfDay$;

  late BehaviorSubject<EntryError> _errorState$;
  BehaviorSubject<EntryError> get errorState$ => _errorState$;

  NewEntryBloc() {
    // _checkedDays$ = BehaviorSubject<List<Day>>.seeded([]);
    _selectedTimeOfDay$ = BehaviorSubject<String>.seeded("None");
    _selectedInterval$ = BehaviorSubject<int>.seeded(0);
    _errorState$ = BehaviorSubject<EntryError>();
  }

  void dispose() {
    // _checkedDays$.close();
    _selectedTimeOfDay$.close();
    _selectedInterval$.close();
  }

  void submitError(EntryError error) {
    _errorState$.add(error);
  }

  void updateInterval(int interval) {
    _selectedInterval$.add(interval);
  }

  void updateTime(String time) {
    _selectedTimeOfDay$.add(time);
  }

  // void addtoDays(Day day) {
  //   List<Day> _updatedDayList = _checkedDays$.value;
  //   if (_updatedDayList.contains(day)) {
  //     _updatedDayList.remove(day);
  //   } else {
  //     _updatedDayList.add(day);
  //   }
  //   _checkedDays$.add(_updatedDayList);
  // }

}
