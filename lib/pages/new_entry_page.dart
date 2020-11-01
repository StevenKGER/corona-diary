import 'package:corona_diary/api/address.dart';
import 'package:corona_diary/api/gps.dart';
import 'package:corona_diary/api/poi.dart';
import 'package:corona_diary/listener/gps.dart';
import 'package:corona_diary/util/location.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

var startTime;
var endTime;
var description;

class NewEntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text("Eintrag hinzufügen"),
      ),
      body: EntryForm(),
    );
  }
}

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("dd.MM.yyyy, HH:mm");
  var currentValue;
  var currentTime;
  var text;

  BasicDateTimeField(bool showCurrentTime, String text) {
    if (showCurrentTime) {
      currentTime = DateTime.now();
      startTime = currentTime;
    }
    this.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        decoration: InputDecoration(
          helperText: this.text,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (this.text == "Startzeit" && value == null) {
            return "Bitte gib eine Startzeit an.";
          }

          if (this.text == "Startzeit" && (startTime.isAfter(endTime))) {
            return "Die Startzeit muss vor der Endzeit liegen.";
          }
          return null;
        },
        initialValue: currentTime,
        onChanged: (currentValue) {
          if (this.text == "Startzeit") {
            startTime = currentValue;
          } else {
            endTime = currentValue;
          }
        },
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime.now().add(new Duration(days: 2)));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            this.currentValue = currentValue;
            return currentValue;
          }
        },
      ),
    ]);
  }
}

class EntryForm extends StatefulWidget {
  EntryForm({Key key}) : super(key: key);

  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerAddress;
  String _textAddress = "";
  TextEditingController _controllerDescription;
  String _textDescription = "";

  @override
  void initState() {
    super.initState();
    _controllerAddress = new TextEditingController();
    _controllerDescription = new TextEditingController();

    initLocation();
    startListener();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Bitte wähle einen Ort aus oder gib einen ein.';
                }
                return null;
              },
              onChanged: (v) => setState(() {
                _textAddress = v;
              }),
              controller: _controllerAddress,
              decoration: const InputDecoration(
                hintText: 'Ort',
              ),
            ),
          ),
          FutureBuilder<LocationData>(
              future: getLocation(),
              builder:
                  (BuildContext context, AsyncSnapshot<LocationData> snapshot) {
                if (!snapshot.hasData)
                  return Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 130),
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      width: 40,
                      height: 40,
                    ),
                  ));
                final locationData = snapshot.data;
                return Column(
                  children: [
                    FutureBuilder<Address>(
                      future: getAddressOfLocation(
                          locationData.latitude, locationData.longitude),
                      builder: (BuildContext context,
                          AsyncSnapshot<Address> snapshot) {
                        if (!snapshot.hasData)
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 7.5),
                            child: Container(
                              child: CircularProgressIndicator(),
                              height: 35,
                              width: 35,
                            ),
                          );
                        return Container(
                          height: 50,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(children: [
                              Icon(Icons.room),
                              FlatButton(
                                textColor: Colors.blueGrey,
                                onPressed: () {
                                  setState(() {
                                    _controllerAddress.text =
                                        "${snapshot.data.toString()}";
                                  });
                                },
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(snapshot.data.toString(),
                                        overflow: TextOverflow.visible)),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 250,
                      child: FutureBuilder<Map<POI, int>>(
                        future: getPOIsNearBy(
                            locationData.latitude, locationData.longitude),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<POI, int>> snapshot) {
                          if (!snapshot.hasData)
                            return Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                width: 40,
                                height: 40,
                              ),
                            );
                          return ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  height: 40,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          _controllerAddress.text =
                                              "${snapshot.data.keys.elementAt(index)}";
                                        });
                                      },
                                      child: RichText(
                                          text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  "${snapshot.data.keys.elementAt(index).name}\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  "${snapshot.data.keys.elementAt(index).toShortAddressString()}")
                                        ],
                                      )),
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  ],
                );
              }),
          BasicDateTimeField(true, "Startzeit"),
          BasicDateTimeField(false, "Endzeit"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  _controllerDescription.text = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Beschreibung (optional)',
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState.validate()) {
                    print("valid");
                  }
                  print(_controllerAddress.text);
                  print(_controllerDescription.text);
                  startTime = null;
                  endTime = null;
                },
                child: Text('Eintrag erstellen'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
