import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../global_bloc.dart';
import '../../models/reminder.dart';

class ReminderDetails extends StatelessWidget {
  final Reminder reminder;

  ReminderDetails(this.reminder);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xFF3EB16F),
        ),
        centerTitle: true,
        title: Text(
          "Reminder Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: reminder.startTime[0] +
                    reminder.startTime[1] +
                    ":" +
                    reminder.startTime[2] +
                    reminder.startTime[3],
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    reminder.startTime[0] +
                        reminder.startTime[1] +
                        ":" +
                        reminder.startTime[2] +
                        reminder.startTime[3],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 90,
                      color: Color(0xFF3EB16F),
                    ),
                  ),
                ),
              ),
              MainSection(reminder: reminder),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.06,
                  right: MediaQuery.of(context).size.height * 0.06,
                  top: 25,
                ),
                child: Container(
                  width: 280,
                  height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3EB16F),
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      openAlertBox(context, _globalBloc);
                    },
                    child: Center(
                      child: Text(
                        "Delete Reminder",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  openAlertBox(BuildContext context, GlobalBloc _globalBloc) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(
                      child: Text(
                        "Delete this Reminder?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          _globalBloc.removeReminder(reminder);
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/'),
                          );
                        },
                        child: InkWell(
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF3EB16F),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: InkWell(
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(30.0)),
                            ),
                            child: Text(
                              "No",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
// _globalBloc.removeReminder(reminder);
//                       Navigator.of(context).pop()

class MainSection extends StatelessWidget {
  final Reminder reminder;

  MainSection({
    Key? key,
    required this.reminder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 15,
          ),
          Column(
            children: <Widget>[
              MainInfoTab(
                fieldTitle: "Description",
                fieldInfo: reminder.desc,
              ),
              MainInfoTab(
                fieldTitle: "Location",
                fieldInfo: reminder.loc,
              ),
              MainInfoTab(
                fieldTitle: "Repeat Every",
                fieldInfo: reminder.interval == 1
                    ? reminder.interval.toString() + ' Hour'
                    : reminder.interval.toString() + ' Hours',
              )
            ],
          )
        ],
      ),
    );
  }
}

class MainInfoTab extends StatelessWidget {
  final String fieldTitle;
  final String fieldInfo;

  MainInfoTab({Key? key, required this.fieldTitle, required this.fieldInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: ListView(
        padding: EdgeInsets.only(top: 15),
        shrinkWrap: true,
        children: <Widget>[
          Text(
            fieldTitle,
            style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold),
          ),
          Text(
            fieldInfo,
            style: TextStyle(
                fontSize: 18,
                color: Color(0xFF3EB16F),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
