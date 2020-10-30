import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:developer';

var address;
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

  BasicDateTimeField(bool showCurrentTime, String text){
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
        initialValue: currentTime,
        onChanged: (currentValue) {
          if (this.text == "Startzeit") {
            startTime = currentValue;
          } else {
            endTime = currentValue;
          }
          // save value
          //print(currentValue);
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
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BasicDateTimeField(true, "Startzeit"),
          BasicDateTimeField(false, "Endzeit"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              onChanged: (value) {
                description = value;
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
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    print("Start: $startTime");
                    print("End: $endTime");
                    print("des: $description");
                    address = null;
                    startTime = null;
                    endTime = null;
                    description = null;
                    //if (_formKey.currentState.validate()) {
                      // Process data.
                    //}
                  },
                  child: Text('Submit'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

