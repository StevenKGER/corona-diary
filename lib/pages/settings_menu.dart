import 'package:corona_diary/models/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

bool isDarkMode;
double _currentSliderValue;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
        ),
        body: FutureBuilder<Settings>(
          future: getSettings(),
          builder: (BuildContext context, AsyncSnapshot<Settings> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            final settings = snapshot.data;
            if (_currentSliderValue != null){
              settings.daysUntilRemoval = _currentSliderValue.toInt();
              saveSettings(settings);
            }
            _currentSliderValue = settings.daysUntilRemoval.toDouble();
            if(isDarkMode != null){
              settings.darkMode = isDarkMode;
              saveSettings(settings);
            }
            isDarkMode = settings.darkMode;
            return Column(children: [
              DarkMode(),
              Text("Automatisches löschen nach Tagen"),
              AutomaticDeletion(),
              FlatButton(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('Lizenzen'),
                ),
                onPressed: () {
                  showAboutDialog(context: context);
                },
              )
            ]);
          },
        ));
  }
}

class DarkMode extends StatefulWidget {
  DarkMode({Key key}) : super(key: key);

  @override
  _DarkMode createState() => _DarkMode();
}

class _DarkMode extends State<DarkMode> {
  bool isSwitched = isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: isSwitched,
      onChanged: (bool value) {
        setState(() {
          isSwitched = value;
          changeBrightness();
          isDarkMode = value;
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

class AutomaticDeletion extends StatefulWidget {
  AutomaticDeletion({Key key}) : super(key: key);

  @override
  _AutomaticDeletion createState() => _AutomaticDeletion();
}

class _AutomaticDeletion extends State<AutomaticDeletion>{
  //double _currentSliderValue;
  bool warn = false;
  Widget build(BuildContext context){
    return Slider(
      value: _currentSliderValue,
      min: 10,
      max: 25,
      divisions: 15,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
          if (value < 14 && !warn) {
            showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                content: Text(
                    'Automatisches löschen unter 14 Tagen kann Probleme verursachen, sind Sie sich sicher?"'),
                actions: [
                  CupertinoDialogAction(
                      child: Text('Ja'),
                      onPressed: () {
                        //standard = value;
                        warn = true;
                        Navigator.pop(context);
                      }),
                  CupertinoDialogAction(
                      child: Text('Nein'),
                      onPressed: () {
                        //standard = 14;
                        _currentSliderValue = 14;
                        setState(() {});
                        Navigator.pop(context);
                      }),
                ],
              ),
            );
            _currentSliderValue = value;
          }
          if (value >= 14 || warn) {
            _currentSliderValue = value;
          }
        });
      },
    );
  }
}