import 'package:corona_diary/models/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'privacy_policy_page.dart';

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
            _currentSliderValue = settings.daysUntilRemoval.toDouble();
            isDarkMode = settings.darkMode;
            return Column(children: [
              DarkMode(settings: settings),
              Text("Tage bis zur Löschung eines Eintrags"),
              AutomaticDeletion(settings: settings),
              FlatButton(
                child: Text("Datenschutzerklärung"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivacyPolicyPage()));
                },
              ),
              FlatButton(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('Lizenzen'),
                  ),
                  onPressed: () {
                    showAboutDialog(context: context, children: <Widget>[
                      Text("Made by Alp, Nika, Liadan and Steven with ♥ in"
                          " Berlin"),
                    ]);
                  }),
            ]);
          },
        ));
  }
}

class DarkMode extends StatefulWidget {
  DarkMode({Key key, this.settings}) : super(key: key);
  Settings settings;

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
          widget.settings.darkMode = isDarkMode;
          saveSettings(widget.settings);
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
  AutomaticDeletion({Key key, this.settings}) : super(key: key);
  Settings settings;

  @override
  _AutomaticDeletion createState() => _AutomaticDeletion();
}

class _AutomaticDeletion extends State<AutomaticDeletion> {
  bool warn = false;

  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: 10,
      max: 25,
      divisions: 15,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          //_currentSliderValue = value;
          if (value < 14 && !warn) {
            showDialog(
              context: context,
              builder: (_) => CupertinoAlertDialog(
                content: Text(
                    'Automatisches löschen unter 14 Tagen kann Probleme verursachen, sind Sie sich sicher?'),
                actions: [
                  CupertinoDialogAction(
                      child: Text('Ja'),
                      onPressed: () {
                        warn = true;
                        setState(() {});
                        Navigator.pop(context);
                      }),
                  CupertinoDialogAction(
                      child: Text('Nein'),
                      onPressed: () {
                        _currentSliderValue = 14;
                        widget.settings.daysUntilRemoval =
                            _currentSliderValue.toInt();
                        saveSettings(widget.settings);
                        setState(() {});
                        Navigator.pop(context);
                      }),
                ],
              ),
            );
            widget.settings.daysUntilRemoval = _currentSliderValue.toInt();
            saveSettings(widget.settings);
          }
          if (value >= 14 || warn) {
            _currentSliderValue = value;
            widget.settings.daysUntilRemoval = _currentSliderValue.toInt();
            saveSettings(widget.settings);
            setState(() => {SettingsPage});
          }
        });
      },
    );
  }
}
