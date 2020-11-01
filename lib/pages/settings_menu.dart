import 'package:corona_diary/models/settings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'privacy_policy_page.dart';

bool isDarkMode;

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

            isDarkMode = settings.darkMode;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
  int days;

  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController(
        text: widget.settings.daysUntilRemoval.toString());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            width: 25.0,
            child: TextFormField(
              onFieldSubmitted: (text) {
                days = int.parse(_controller.text);
                if (days >= 10 && days < 100) {
                  widget.settings.daysUntilRemoval =
                      int.parse(_controller.text);
                  saveSettings(widget.settings);
                }
                if (days < 10 || days > 100) {
                  showDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      content: Text('Probleme und so blabla?'),
                      actions: [
                        CupertinoDialogAction(
                            child: Text('Ok'),
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  );
                }
              },
              //textAlign: TextAlign.center,
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              minWidth: 5.0,
              child: Icon(Icons.arrow_drop_up),
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                setState(() {
                  currentValue++;
                  _controller.text =
                      (currentValue).toString(); // incrementing value
                });
                days = int.parse(_controller.text);
                if (days >= 10 && days < 100) {
                  widget.settings.daysUntilRemoval =
                      int.parse(_controller.text);
                  saveSettings(widget.settings);
                }
                if (days < 10 || days >= 100) {
                  showDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      content: Text('Probleme und so blabla?'),
                      actions: [
                        CupertinoDialogAction(
                            child: Text('Ok'),
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  );
                }
              },
            ),
            MaterialButton(
              minWidth: 5.0,
              child: Icon(Icons.arrow_drop_down),
              onPressed: () {
                int currentValue = int.parse(_controller.text);
                setState(() {
                  print("Setting state");
                  currentValue--;
                  _controller.text =
                      (currentValue).toString(); // decrementing value
                });
                days = int.parse(_controller.text);
                if (days >= 10 && days < 100) {
                  widget.settings.daysUntilRemoval =
                      int.parse(_controller.text);
                  saveSettings(widget.settings);
                }
                if (days < 10 || days >= 100) {
                  showDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      content: Text('Probleme und so blabla?'),
                      actions: [
                        CupertinoDialogAction(
                            child: Text('Ok'),
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
