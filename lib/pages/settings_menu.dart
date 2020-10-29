import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';


class Settings extends StatefulWidget {
  Settings({Key key, this.title}) : super(key: key);
  final String title;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings>{

  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
        ),
        body: Container(
          child: Switch(
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
                print(isSwitched);
                if(value==true){
                  changeBrightness();
                }
                if(value==false){
                  changeBrightness();
                }
              });
            },
            activeTrackColor: Colors.black12,
            activeColor: Colors.black,
          ),
        )
    );
  }
  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }
}