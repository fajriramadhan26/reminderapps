import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reminder/src/common/convert_time.dart';
import 'package:reminder/src/global_bloc.dart';
import 'package:reminder/src/models/errors.dart';
import 'package:reminder/src/models/reminder.dart';
import 'package:reminder/src/ui/homepage/homepage.dart';
import 'package:reminder/src/ui/new_entry/new_entry_bloc.dart';
import 'package:reminder/src/ui/success_screen/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tza;
import 'package:timezone/timezone.dart' as tz;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NewEntry extends StatefulWidget {
  @override
  _NewEntryState createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
  TextEditingController descController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NewEntryBloc _newEntryBloc = NewEntryBloc();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String latitude = '';
  String longtitude = '';

  void dispose() {
    super.dispose();
    descController.dispose();
    locationController.dispose();
    _newEntryBloc.dispose();
  }

  void initState() {
    initializeNotifications();
    initializeErrorListen();
    getGeoLocationPosition();
    locationController.text = 'Loading...';
    super.initState();
  }

  Future getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    await GetAddressFromLatLong(pos);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    var temp_latitude = position.latitude.toString();
    var temp_longtitude = position.longitude.toString();
    latitude = temp_latitude;
    longtitude = temp_longtitude;
    Placemark place = placemarks[0];
    Placemark place1 = placemarks[2];
    // Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      locationController.text =
          '${place1.street} ${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea},'
          ' ${place.administrativeArea}  ${place.postalCode}, ${place.country}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xFF3EB16F),
        ),
        centerTitle: true,
        title: Text(
          "Add New Mediminder",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        child: Provider<NewEntryBloc>.value(
          value: _newEntryBloc,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 25,
            ),
            children: <Widget>[
              PanelTitle(
                title: "Description",
                isRequired: true,
              ),
              TextFormField(
                minLines: 1,
                maxLines: null,
                style: TextStyle(
                  fontSize: 16,
                ),
                controller: descController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
              PanelTitle(
                title: "Location",
                isRequired: false,
              ),
              TextFormField(
                readOnly: true,
                minLines: 1,
                maxLines: null,
                controller: locationController,
                style: TextStyle(
                  fontSize: 16,
                ),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              PanelTitle(
                title: "Interval Selection",
                isRequired: true,
              ),
              //ScheduleCheckBoxes(),
              IntervalSelection(),
              PanelTitle(
                title: "Starting Time",
                isRequired: true,
              ),
              SelectTime(),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.08,
                  right: MediaQuery.of(context).size.height * 0.08,
                ),
                child: Container(
                  width: 220,
                  height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3EB16F),
                      shape: StadiumBorder(),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onPressed: () {
                      String desc = '';
                      String loc = '';
                      //--------------------Error Checking------------------------
                      //Had to do error checking in UI
                      //Due to unoptimized BLoC value-grabbing architecture
                      if (descController.text == "") {
                        _newEntryBloc.submitError(EntryError.NameNull);
                        return;
                      }
                      if (descController.text != "") {
                        desc = descController.text;
                      }
                      if (locationController.text == "") {
                        loc = 'Loading...';
                      }
                      if (locationController.text != "") {
                        loc = locationController.text;
                      }
                      for (var reminder in _globalBloc.reminderList$.value) {
                        if (desc == reminder.desc) {
                          _newEntryBloc.submitError(EntryError.NameDuplicate);
                          return;
                        }
                      }
                      if (_newEntryBloc.selectedInterval$.value == 0) {
                        _newEntryBloc.submitError(EntryError.Interval);
                        return;
                      }
                      if (_newEntryBloc.selectedTimeOfDay$.value == "None") {
                        _newEntryBloc.submitError(EntryError.StartTime);
                        return;
                      }
                      //---------------------------------------------------------
                      int interval = _newEntryBloc.selectedInterval$.value;
                      String startTime = _newEntryBloc.selectedTimeOfDay$.value;

                      List<int> intIDs =
                          makeIDs(24 / _newEntryBloc.selectedInterval$.value);
                      List<String> notificationIDs = intIDs
                          .map((i) => i.toString())
                          .toList(); //for Shared preference

                      Reminder newEntryReminder = Reminder(
                        notificationIDs: notificationIDs,
                        desc: desc,
                        loc: loc,
                        interval: interval,
                        startTime: startTime,
                      );

                      _globalBloc.updateReminderList(newEntryReminder);
                      zonedScheduleNotification(
                          newEntryReminder, DateTime.now());

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return SuccessScreen();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initializeErrorListen() {
    _newEntryBloc.errorState$.listen(
      (EntryError error) {
        switch (error) {
          case EntryError.NameNull:
            displayError("Please enter the Description");
            break;
          case EntryError.NameDuplicate:
            displayError("Description already exists");
            break;
          case EntryError.Dosage:
            displayError("Location data still generating");
            break;
          case EntryError.Interval:
            displayError("Please select the reminder's interval");
            break;
          case EntryError.StartTime:
            displayError("Please select the reminder's starting time");
            break;
          default:
        }
      },
    );
  }

  void displayError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(error),
        duration: Duration(milliseconds: 2000),
      ),
    );
  }

  List<int> makeIDs(double n) {
    var rng = math.Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(1000000000));
    }
    return ids;
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future onSelectNotification(payload) async {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future zonedScheduleNotification(Reminder reminder, DateTime date) async {
    var hour = int.parse(reminder.startTime.substring(0, 2));
    var minute = int.parse(reminder.startTime.substring(2, 4));
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.TZDateTime currentDateTime =
        tz.TZDateTime.from(date, tz.getLocation(timeZoneName));

    for (int i = 0; i < (24 / reminder.interval).floor(); i++) {
      int scheduledHour = (hour + (reminder.interval * i)) % 24;
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.getLocation(timeZoneName),
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        scheduledHour,
        minute,
      );

      if (scheduledDate.isBefore(currentDateTime)) {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      }

      log('Scheduling notification for: $scheduledDate');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        int.parse(reminder.notificationIDs[i]),
        'REMINDER!',
        reminder.desc,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            channelDescription: 'your channel description',
            icon: "ic_launcher",
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

class IntervalSelection extends StatefulWidget {
  @override
  _IntervalSelectionState createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  var _intervals = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    24,
  ];
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    final NewEntryBloc _newEntryBloc = Provider.of<NewEntryBloc>(context);
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Remind me every  ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            DropdownButton<int>(
              iconEnabledColor: Color(0xFF3EB16F),
              hint: _selected == 0
                  ? Text(
                      "Select an Interval",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    )
                  : null,
              elevation: 4,
              value: _selected == 0 ? null : _selected,
              items: _intervals.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  _selected = newVal!;
                  _newEntryBloc.updateInterval(newVal);
                });
              },
            ),
            Text(
              _selected == 1 ? " hour" : " hours",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectTime extends StatefulWidget {
  @override
  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final NewEntryBloc _newEntryBloc =
        Provider.of<NewEntryBloc>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;
        _newEntryBloc.updateTime("${convertTime(_time.hour.toString())}" +
            "${convertTime(_time.minute.toString())}");
      });
    }
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3EB16F),
            shape: StadiumBorder(),
          ),
          onPressed: () {
            _selectTime(context);
          },
          child: Center(
            child: Text(
              _clicked == false
                  ? "Pick Time"
                  : "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  final String title;
  final bool isRequired;
  PanelTitle({
    Key? key,
    required this.title,
    required this.isRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Text.rich(
        TextSpan(children: <TextSpan>[
          TextSpan(
            text: title,
            style: TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: isRequired ? " *" : "",
            style: TextStyle(fontSize: 14, color: Color(0xFF3EB16F)),
          ),
        ]),
      ),
    );
  }
}
