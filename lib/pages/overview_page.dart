import 'package:corona_diary/api/map.dart';
import 'package:corona_diary/models/entries.dart';
import 'package:flutter/material.dart';

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

  void setStateRemote(Function function) {
    setState(function);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _generateOverview(context, this.setStateRemote),
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

Future<List<Widget>> _generateOverview(
    BuildContext context, Function stateCallback) async {
  List<Widget> widgets = [];
  Entries entries = await getAllEntries();

  entries.entryList.forEach((entry) {
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(entry.startTime);
    final startDate =
        "${startDateTime.day}.${startDateTime.month}.${startDateTime.year}   ${startDateTime.hour}:${startDateTime.minute}";

    final endDateTime = (entry.endTime != null
        ? DateTime.fromMillisecondsSinceEpoch(entry.endTime)
        : null);
    final endDate = (endDateTime != null
        ? "${endDateTime.day}.${endDateTime.month}.${endDateTime.year}   ${endDateTime.hour}:${endDateTime.minute}"
        : null);

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
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: ("\n${entry.name}"),
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25.0)),
                    new TextSpan(text: ("\n${entry.toAddressString()}\n")),
                    new TextSpan(
                        text: "Startzeit:\n",
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    new TextSpan(text: startDate),
                    new TextSpan(
                        text: (entry.endTime != null ? "\nEndzeit:" : ""),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    new TextSpan(
                        text: (entry.endTime != null ? "$endDate" : "")),
                    new TextSpan(
                        text: ((entry.description ?? "").trim().isNotEmpty
                            ? "\nBeschreibung: \n"
                            : ""),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    new TextSpan(
                      text: ((entry.description ?? "").trim().isNotEmpty
                          ? "${entry.description}"
                          : ""),
                    ),
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
                        stateCallback(() {});
                      }),
                  FlatButton(
                      child: Text("Bearbeiten"),
                      onPressed: () {
                        Navigator.of(context).pop();
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
