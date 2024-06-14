import 'package:flutter/material.dart';
import 'package:reminder/src/global_bloc.dart';
import 'package:reminder/src/models/reminder.dart';
import 'package:reminder/src/ui/reminder_details/reminder_details.dart';
import 'package:reminder/src/ui/new_entry/new_entry.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Reminder Apps',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFF6F8FC),
        elevation: 0.0,
      ),
      body: Container(
        color: Color(0xFFF6F8FC),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 7,
              child: Provider<GlobalBloc>.value(
                child: ReminderList(),
                value: _globalBloc,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: Color(0xFF3EB16F),
        child: Icon(
          Icons.add,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewEntry(),
            ),
          );
        },
      ),
    );
  }
}

class ReminderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc _globalBloc = Provider.of<GlobalBloc>(context);
    return StreamBuilder<List<Reminder>>(
      stream: _globalBloc.reminderList$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else if (snapshot.data?.length == 0) {
          return Container(
            color: Color(0xFFF6F8FC),
            child: Center(
              child: Text(
                "Press + to add Reminder",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFFC9C9C9),
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        } else {
          return Container(
            color: Color(0xFFF6F8FC),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ReminderCard(snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }
}

class ReminderCard extends StatefulWidget {
  final Reminder reminder;

  ReminderCard(this.reminder);

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        highlightColor: Colors.white,
        splashColor: Colors.grey,
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder<Null>(
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: animation.value,
                        child: ReminderDetails(widget.reminder),
                      );
                    });
              },
              transitionDuration: Duration(milliseconds: 500),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: widget.reminder.startTime[0] +
                    widget.reminder.startTime[1] +
                    ":" +
                    widget.reminder.startTime[2] +
                    widget.reminder.startTime[3],
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.reminder.startTime[0] +
                        widget.reminder.startTime[1] +
                        ":" +
                        widget.reminder.startTime[2] +
                        widget.reminder.startTime[3],
                    style: TextStyle(
                        fontSize: 50,
                        color: Color(0xFF3EB16F),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Text(
                widget.reminder.desc,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }
}
