import 'package:flutter/material.dart';


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

        body: Center(
          child: Switch(
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
                print(isSwitched);
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        )
      //child: FlatButton(
      // onPressed: () {
      // Navigator.pop(context);
      // },
      // child: Text('Zurück'),
      //),
      //),
    );
  }
}
