import 'dart:io';

import 'package:corona_diary/api/map.dart';
import 'package:corona_diary/main.dart';
import 'package:corona_diary/models/entries.dart';
import 'package:corona_diary/models/settings.dart';
import 'package:corona_diary/pages/entry_management_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

DateFormat _dateFormat = DateFormat("dd.MM.yyyy   HH:mm");

class OverviewPage extends StatefulWidget {
  OverviewPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OverviewPage createState() => _OverviewPage();
}

class _OverviewPage extends State<OverviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _generateOverview(context),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.data[0] is Center) return snapshot.data[0];
        return Center(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: snapshot.data,
          ),
        );
      },
    );
  }
}

final _infoText = Center(
    child:
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
  Padding(
    padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
    child: Text(
      "Die Welt ist groß, aber für die App ist sie noch klein. Besuche sie, halte aber Abstand und denke an deine Mund-Nasen-Bedeckung!",
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
          color: Color.fromARGB(255, 122, 122, 122)),
    ),
  ),
]));

Future<List<Widget>> _generateOverview(BuildContext context) async {
  removeEntriesOlderThen((await getSettings()).daysUntilRemoval);

  sleep(new Duration(milliseconds: 250));

  List<Widget> widgets = [];
  Entries entries = await getAllEntries();

  entries.entryList.forEach((entry) {
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(entry.startTime);
    final startDate = _dateFormat.format(startDateTime);

    final endDateTime = (entry.endTime != null
        ? DateTime.fromMillisecondsSinceEpoch(entry.endTime)
        : null);
    final endDate =
        (endDateTime != null ? _dateFormat.format(endDateTime) : null);

    final container = GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlue, width: 2)),
        child: Column(
          children: [
            Container(
              child: renderMap(context, entry.latitude, entry.longitude),
              width: MediaQuery.of(context).size.width,
              height: 300,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: RichText(
                text: new TextSpan(
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: DynamicTheme.of(context)
                          .data
                          .textTheme
                          .bodyText1
                          .color),
                  children: <TextSpan>[
                    new TextSpan(
                        text: ("\n${entry.name}"),
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25.0)),
                    new TextSpan(
                        text:
                            ("\n${entry.latitude != null ? entry.toAddressString() : ""}\n")),
                    new TextSpan(
                        text: "Startzeit:\n",
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(text: startDate),
                    new TextSpan(
                        text: (entry.endTime != null ? "\nEndzeit:\n" : ""),
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(
                        text: (entry.endTime != null ? "$endDate" : "")),
                    new TextSpan(
                        text: ((entry.description ?? "").trim().isNotEmpty
                            ? "\nBeschreibung: \n"
                            : ""),
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(
                      text: ((entry.description ?? "").trim().isNotEmpty
                          ? "${entry.description}"
                          : ""),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Bearbeiten"),
                content: Text("Was möchtest du tun?"),
                actions: <Widget>[
                  FlatButton(
                      child: Text("Löschen"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        removeEntryById(entry.id);
                        Fluttertoast.showToast(msg: "Eintrag gelöscht.");
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainPage()));
                      }),
                  FlatButton(
                      child: Text("Bearbeiten"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EntryManagementPage(entry: entry)));
                      }),
                  FlatButton(
                      child: Text("Abbrechen"),
                      onPressed: () => Navigator.of(context).pop())
                ],
              );
            });
      },
    );
    widgets.add(container);
    widgets.add(SizedBox(height: 15));
  });

  if (entries.entryList.isEmpty) widgets.add(_infoText);

  return widgets;
}
