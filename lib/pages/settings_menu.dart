import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

bool prev = false;
double standard = 14;

class Settings extends StatefulWidget {
  Settings({Key key, this.title}) : super(key: key);
  final String title;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  double _currentSliderValue = standard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
        ),
        body: Column(children: [
          MyStatefulWidget(),
          Text("Automatisches löschen nach Tagen"),
          Slider(
            value: _currentSliderValue,
            min: 10,
            max: 25,
            divisions: 15,
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
                standard= value;
              });
            },
          ),
        ]));
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _DarkMode createState() => _DarkMode();
}

class _DarkMode extends State<MyStatefulWidget> {
  bool isSwitched = prev;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: isSwitched,
      onChanged: (bool value) {
        setState(() {
          isSwitched = value;
          changeBrightness();
          prev = value;
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