import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:sprintf/sprintf.dart';

class POI {
  String name;
  String street;
  String houseNumber;
  String postCode;
  String city;
  String subUrb;
  String country;
  String type;
  double latitude;
  double longitude;

  POI(this.name, this.street, this.houseNumber, this.postCode, this.city,
      this.subUrb, this.country, this.type, this.latitude, this.longitude);

  factory POI.fromOverPassJson(dynamic json) {
    return POI(
        json["tags"]["name"] as String ?? "",
        json["tags"]["addr:street"] as String ?? "",
        json["tags"]["addr:housenumber"] as String ?? "",
        json["tags"]["addr:postcode"] as String ?? "",
        json["tags"]["addr:city"] as String ?? "",
        json["tags"]["addr:suburb"] as String ?? "",
        json["tags"]["addr:country"] as String ?? "",
        json["tags"]["amenity"] as String ??
            json["tags"]["leisure"] as String ??
            "",
        json["lat"] as double,
        json["lon"] as double);
  }

  @override
  String toString() {
    var addressArray = {
      this.name,
      "${this.street} ${this.houseNumber}",
      "${this.postCode} ${this.city}",
      this.subUrb,
      this.country
    };

    return addressArray
        .where((element) => element.trim().length != 0)
        .join(", ");
  }

  String toShortAddressString() {
    var addressArray = {
      "${this.street} ${this.houseNumber}",
      "${this.postCode} ${this.city}",
      this.subUrb
    };

    return addressArray
        .where((element) => element.trim().length != 0)
        .join(", ");
  }
}

var url = "https://overpass-api.de/api/interpreter";

final query = ''
    '[out:json][timeout:25];'
    'node[~"^(amenity|leisure)\$"~"^(restaurant|pub|place_of_worship|cafe|'
    'fast_food|bar|biergarten|cinema|nightclub|theatre|sports_centre|stadium|'
    'fitness_centre|water_park|dance|bowling_alley|sports_hall|escape_game)\$"]'
    '(around:15,%f,%f);'
    'out qt;';

Future<Map<POI, int>> getPOIsNearBy(double lat, double lon) async {
  final position = new LatLng(lat, lon);

  final postBody = sprintf(query, [lat, lon]);
  final response = await http
      .post(url, body: postBody)
      .timeout(new Duration(seconds: 10), onTimeout: null);

  if (response == null || response.statusCode != 200) return null;

  final Map<POI, int> points = LinkedHashMap();

  final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

  for (var element in jsonResponse["elements"]) {
    POI poi = POI.fromOverPassJson(element);
    points[poi] = new Distance()
        .distance(position, new LatLng(poi.latitude, poi.longitude)) // meters
        .toInt();
  }

  return SplayTreeMap.from(
      points, (key1, key2) => points[key1].compareTo(points[key2]));
}
