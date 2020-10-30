import 'package:corona_diary/api/address.dart';
import 'package:corona_diary/api/gps.dart';
import 'package:corona_diary/api/map.dart';
import 'package:corona_diary/api/poi.dart';
import 'package:corona_diary/listener/gps.dart';
import 'package:corona_diary/util/location.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class ExamplePage extends StatefulWidget {
  ExamplePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  void initState() {
    super.initState();

    initLocation();
    startListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example"),
      ),
      body: FutureBuilder<LocationData>(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot<LocationData> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final locationData = snapshot.data;
          return Column(
            children: [
              Container(
                child: renderMap(
                    context, locationData.latitude, locationData.longitude),
                width: 250.0,
                height: 250.0,
              ),
              SizedBox(height: 10),
              Container(
                  child: Text(
                      "${locationData.latitude}, ${locationData.longitude}")),
              SizedBox(height: 10),
              Container(
                child: FutureBuilder<List<POI>>(
                  future: getPOIsNearBy(
                      locationData.latitude, locationData.longitude),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<POI>> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return Text(snapshot.data.join("\n"));
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                  child: FutureBuilder<Address>(
                future: getAddressOfLocation(
                    locationData.latitude, locationData.longitude),
                builder:
                    (BuildContext context, AsyncSnapshot<Address> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return Text(snapshot.data.toString());
                },
              ))
            ],
          );
        },
      ),
    );
  }
}
