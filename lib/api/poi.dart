import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class POI {
  String name;
  String street;
  String houseNumber;
  String postCode;
  String city;
  String subUrb;
  String country;

  POI(
    this.name,
    this.street,
    this.houseNumber,
    this.postCode,
    this.city,
    this.subUrb,
    this.country,
  );

  factory POI.fromOverPassJson(dynamic json) {
    return POI(
      json["name"] as String ?? "",
      json["addr:street"] as String ?? "",
      json["addr:housenumber"] as String ?? "",
      json["addr:postcode"] as String ?? "",
      json["addr:city"] as String ?? "",
      json["addr:suburb"] as String ?? "",
      json["addr:country"] as String ?? "",
    );
  }

  @override
  String toString() {
    var addressArray = List.of({
      this.name,
      "${this.street} ${this.houseNumber}",
      "${this.postCode} ${this.city}",
      this.subUrb,
      this.country
    });

    return addressArray
        .where((element) => element.trim().length != 0)
        .join(", ");
  }
}

var url = "https://overpass-api.de/api/interpreter";

final query = '''<osm-script output="json" timeout="25">
  <query type="node">
    <has-kv k="amenity" regv="restaurant|pub"/>
    <around lat="%f" lon="%f" radius="15"/>
  </query>

  <print/>
</osm-script>''';

Future<List<POI>> getPOIsNearBy(double lat, double lon) async {
  var postBody = sprintf(query, [lat, lon]);
  var response = await http
      .post(url, body: postBody)
      .timeout(new Duration(seconds: 10), onTimeout: null);

  if (response == null || response.statusCode != 200)
    return null;

  List<POI> pois = new List();

  var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
  for (var element in jsonResponse["elements"]) {
    var node = element["tags"];

    POI poi = POI.fromOverPassJson(node);
    pois.add(poi);
  }

  return pois;
}
