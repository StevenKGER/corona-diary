import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

FlutterMap renderMap(BuildContext context, double lat, double lon) {
  return new FlutterMap(
    options: new MapOptions(
      interactive: false,
      center: new LatLng(lat, lon),
      zoom: 16.0,
    ),
    layers: [
      new TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c']),
      new MarkerLayerOptions(
        markers: [
          new Marker(
            width: 80.0,
            height: 80.0,
            point: new LatLng(lat, lon),
            builder: (ctx) => new Container(
              child: new Icon(Icons.room, color: Colors.green, size: 50.0),
            ),
          ),
        ],
      ),
    ],
  );
}
