import 'package:corona_diary/listener/gps.dart';
import 'package:corona_diary/pages/entry_management_page.dart';
import 'package:corona_diary/pages/overview_page.dart';
import 'package:corona_diary/util/http_override.dart';
import 'package:corona_diary/util/location.dart';
import 'package:corona_diary/util/notification.dart';
import 'package:corona_diary/util/store.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'pages/settings_menu.dart';

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
            home: new MainPage(),
          );
        });
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

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
    initHttpClient();
    startListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Corona-Tagebuch"),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
                child: Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: OverviewPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => EntryManagementPage())),
        tooltip: 'Eintrag hinzufügen',
        child: Icon(Icons.add),
      ),
    );
  }
}
