import 'package:corona_diary/api/address.dart';
import 'package:corona_diary/api/gps.dart';
import 'package:corona_diary/api/poi.dart';
import 'package:corona_diary/listener/gps.dart';
import 'package:corona_diary/models/entries.dart';
import 'package:corona_diary/models/entry.dart';
import 'package:corona_diary/util/http_override.dart';
import 'package:corona_diary/util/location.dart';
import 'package:corona_diary/util/store.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

DateTime startTime;
DateTime endTime;
Address selectedAddress;
POI selectedPOI;

class EntryManagementPage extends StatelessWidget {
  EntryManagementPage({Key key, this.entry}) : super(key: key);

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text("Eintrag hinzufügen"),
      ),
      body: EntryForm(entry: entry),
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
      this.currentTime = DateTime.now();
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

          if (this.text == "Startzeit" &&
              endTime != null &&
              startTime.isAfter(endTime)) {
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
  EntryForm({Key key, this.entry}) : super(key: key);

  final Entry entry;

  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  TextEditingController _controllerAddress;
  TextEditingController _controllerName;
  TextEditingController _controllerDescription;
  TextEditingController _controllerStreet;
  String _textStreet = "";
  TextEditingController _controllerNumber;
  String _textNumber = "";
  TextEditingController _controllerPostCode;
  String _textPostCode = "";
  TextEditingController _controllerCity;
  String _textCity = "";

  @override
  void initState() {
    super.initState();
    _controllerAddress = new TextEditingController();
    _controllerName = new TextEditingController();
    _controllerDescription = new TextEditingController();
    _controllerStreet = new TextEditingController();
    _controllerNumber = new TextEditingController();
    _controllerPostCode = new TextEditingController();
    _controllerCity = new TextEditingController();

    if (widget.entry != null) {
      _controllerAddress.text = widget.entry.toAddressString();
      _controllerName.text = widget.entry.name;
      _controllerDescription.text = widget.entry.description;
      _controllerStreet.text = widget.entry.street;
      _controllerNumber.text = widget.entry.houseNumber;
      _controllerPostCode.text = widget.entry.postCode;
      _controllerCity.text = widget.entry.city;
      startTime = DateTime.fromMillisecondsSinceEpoch(widget.entry.startTime);
      endTime = DateTime.fromMillisecondsSinceEpoch(widget.entry.endTime);
    }

    initLocation();
    initJsonStore();
    startListener();
    initHttpClient();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeys[0],
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              enabled: false,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Bitte wähle einen Ort aus oder gib einen ein.';
                }
                return null;
              },
              controller: _controllerAddress,
              decoration: InputDecoration(
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

                return (widget.entry == null
                    ? Column(
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Row(children: [
                                    Icon(Icons.room),
                                    FlatButton(
                                      textColor: Colors.blueGrey,
                                      onPressed: () {
                                        selectedAddress = snapshot.data;
                                        selectedPOI = null;
                                        _controllerAddress.text =
                                            "${snapshot.data.toString()}";
                                      },
                                      child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
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
                              future: getPOIsNearBy(locationData.latitude,
                                  locationData.longitude),
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
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        height: 40,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedPOI = snapshot.data.keys
                                                    .elementAt(index);
                                                selectedAddress = null;
                                                _controllerAddress.text =
                                                    "$selectedPOI";
                                                _controllerName.text =
                                                    selectedPOI.name;
                                              });
                                            },
                                            child: RichText(
                                                text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text:
                                                        "${snapshot.data.keys.elementAt(index).name}\n",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                          RaisedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Stack(
                                        overflow: Overflow.visible,
                                        children: <Widget>[
                                          Positioned(
                                            right: -40,
                                            top: -40,
                                            child: InkResponse(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: CircleAvatar(
                                                child: Icon(Icons.close),
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ),
                                          Form(
                                            key: _formKeys[1],
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Bitte gib eine Straße ein.";
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (v) =>
                                                          {_textStreet = v},
                                                      controller:
                                                          _controllerStreet,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: 'Straße',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Bitte gib eine Hausnummer ein.";
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (v) =>
                                                          {_textNumber = v},
                                                      controller:
                                                          _controllerNumber,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: 'Hausnummer',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (_controllerPostCode
                                                            .text.isEmpty) {
                                                          return "Bitte gib eine Postleitzahl ein.";
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (v) =>
                                                          {_textPostCode = v},
                                                      controller:
                                                          _controllerPostCode,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            'Postleitzahl',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return "Bitte gib eine Stadt ein.";
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (v) =>
                                                          {_textCity = v},
                                                      controller:
                                                          _controllerCity,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: 'Stadt',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: RaisedButton(
                                                      child: Text("Hinzufügen"),
                                                      onPressed: () async {
                                                        if (_formKeys[1]
                                                            .currentState
                                                            .validate()) {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return WillPopScope(
                                                                    child:
                                                                        Dialog(
                                                                            child:
                                                                                Center(
                                                                      child:
                                                                          SizedBox(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                      ),
                                                                    )),
                                                                    onWillPop:
                                                                        () async =>
                                                                            false);
                                                              });

                                                          var addresses =
                                                              await searchAddress(
                                                                  "$_textStreet $_textNumber",
                                                                  _textPostCode,
                                                                  _textCity);

                                                          if (addresses
                                                                  .length ==
                                                              0) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                      actions: <
                                                                          Widget>[
                                                                        FlatButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Text("Ok"),
                                                                        )
                                                                      ],
                                                                      content: Text(
                                                                          "Die eingegebene Adresse ist ungültig."));
                                                                });
                                                          } else if (addresses
                                                                  .length ==
                                                              1) {
                                                            _controllerAddress
                                                                    .text =
                                                                addresses[0]
                                                                    .toString();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            selectedAddress =
                                                                addresses[0];
                                                            selectedPOI = null;
                                                            _controllerStreet
                                                                .text = "";
                                                            _controllerNumber
                                                                .text = "";
                                                            _controllerPostCode
                                                                .text = "";
                                                            _controllerCity
                                                                .text = "";
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } else {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return SimpleDialog(
                                                                      children: [
                                                                        ListView.builder(
                                                                            scrollDirection: Axis.vertical,
                                                                            shrinkWrap: true,
                                                                            itemCount: addresses.length,
                                                                            itemBuilder: (BuildContext context, int index) {
                                                                              return GestureDetector(
                                                                                  onTap: () {
                                                                                    selectedAddress = addresses[index];
                                                                                    selectedPOI = null;
                                                                                    _controllerAddress.text = addresses[index].toString();
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Text("${addresses[index]}\n"));
                                                                            })
                                                                      ]);
                                                                });
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Text("Eigene Adresse hinzufügen"),
                          ),
                        ],
                      )
                    : Text(""));
              }),
          BasicDateTimeField(true, "Startzeit"),
          BasicDateTimeField(false, "Endzeit"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _controllerName,
              validator: (value) {
                if (value.isEmpty) {
                  return "Bitte trage einen Namen ein";
                }
                return null;
              },
              onChanged: (value) => {_controllerName.text = value},
              decoration: const InputDecoration(
                hintText: 'Name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              onChanged: (value) => {_controllerDescription.text = value},
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
                  if (_formKeys[0].currentState.validate()) {
                    if (selectedPOI != null) {
                      addEntryByPOI(
                          _controllerName.text,
                          selectedPOI,
                          _controllerDescription.text,
                          startTime?.millisecondsSinceEpoch,
                          endTime?.millisecondsSinceEpoch);
                    } else if (selectedAddress != null) {
                      addEntryByAddress(
                          _controllerName.text,
                          selectedAddress,
                          _controllerDescription.text,
                          startTime?.millisecondsSinceEpoch,
                          endTime?.millisecondsSinceEpoch);
                    }

                    if (widget.entry != null) {
                      updateEntry(widget.entry);
                    }

                    Navigator.of(context).pop();
                    Fluttertoast.showToast(msg: "Eintrag gespeichert.");
                  }
                },
                child: Text((widget.entry == null
                    ? 'Eintrag erstellen'
                    : 'Eintrag bearbeiten')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
