import 'package:flutter/material.dart';
import 'package:reminder/src/ui/homepage/homepage.dart';
import 'package:provider/provider.dart';
import 'package:reminder/src/global_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(ReminderApp());
}

class ReminderApp extends StatefulWidget {
  @override
  _ReminderAppState createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  late GlobalBloc globalBloc;

  void initState() {
    globalBloc = GlobalBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>.value(
      value: globalBloc,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
        ),
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
