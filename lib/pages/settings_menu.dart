import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';


class Settings extends StatefulWidget {
  Settings({Key key, this.title}) : super(key: key);
  final String title;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
        ),
        body: Container(
          child: MyStatefulWidget(),
        )
    );
  }

}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: isSwitched,
      onChanged: (bool value) {
        setState(() {
          isSwitched = value;
          if(isSwitched==true){
            changeBrightness();
          }
          if(isSwitched==false){
            changeBrightness();
          }
        });
      },
      activeTrackColor: Colors.lightBlueAccent,
      activeColor: Colors.lightBlue,
      secondary: const Icon(Icons.lightbulb_outline),
    );
  }
  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }
}