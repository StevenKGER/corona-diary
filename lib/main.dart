import 'package:corona_diary/api/map.dart';
import 'package:corona_diary/models/entries.dart';
import 'package:corona_diary/util/location.dart';
import 'package:corona_diary/util/notification.dart';
import 'package:corona_diary/util/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pages/settings_menu.dart';

import 'package:dynamic_theme/dynamic_theme.dart';


void main() {
  runApp(CoronaDiaryApp());
}

class CoronaDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.blue,
        brightness: brightness,
      ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Corona-Tagebuch',
            theme: theme,
            home: new MainPage(title: 'Corona-Tagebuch'),
          );
        }
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    initJsonStore();
    initLocation();
    initNotifications();
  }

  void setStateRemote(Function function) {
    setState(function);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                },
                child: Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              )
          ),
        ],
      ),
      body: FutureBuilder<List<Widget>>(
        future: generateOverview(context, this.setStateRemote),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<List<Widget>> generateOverview(
    BuildContext context, Function stateCallback) async {
  //addEntryByAddress('Test', await getAddressOfLocation(52.509171, 13.375490),
  //'testdes', DateTime
  //.now()
  //.millisecondsSinceEpoch, null);
  List<Widget> widgets = [];
  Entries entries = await getAllEntries();
  entries.entryList.forEach((entry) {
    String date =
        DateTime.fromMillisecondsSinceEpoch(entry.startTime).toString();
    String yearMonthDay = date.substring(0, 10);
    String year = yearMonthDay.substring(0, 4);
    String month = yearMonthDay.substring(5, 7);
    String day = yearMonthDay.substring(8, 10);
    yearMonthDay = day + "." + month + "." + year;
    String time = date.substring(11, 16);
    var container = GestureDetector(
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
                    new TextSpan(text: yearMonthDay + "   " + time),
                    new TextSpan(
                        text: (entry.endTime != null ? "\nEndzeit:" : ""),
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    new TextSpan(
                        text:
                            (entry.endTime != null ? "${entry.endTime}" : "")),
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
                      onPressed: () => Navigator.of(context).pop()),
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
  if (entries.entryList.isEmpty) {
    var infoText = Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
    widgets.add(infoText);
  }
  return widgets;
}
