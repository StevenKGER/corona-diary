import 'dart:collection';

import 'package:osm_nominatim/osm_nominatim.dart';

final Map<Map<double, double>, CachedAddress> _cache = HashMap();
final _ttl = new Duration(minutes: 10);

class Address {
  String street;
  String houseNumber;
  String postCode;
  String city;
  String subUrb;
  String borough;
  String country;
  double latitude;
  double longitude;

  Address(this.street, this.houseNumber, this.postCode, this.city, this.subUrb,
      this.borough, this.country, this.latitude, this.longitude);

  factory Address.fromNominatimPlace(
      Map<String, dynamic> map, double lat, double lon) {
    return Address(
        map["road"] as String ?? "",
        map["house_number"] as String ?? "",
        map["postcode"] as String ?? "",
        map["city"] as String ?? "",
        map["suburb"] as String ?? "",
        map["borough"] as String ?? "",
        map["country"] as String ?? "",
        lat,
        lon);
  }

  @override
  String toString() {
    final addressArray = {
      "${this.street} ${this.houseNumber}",
      "${this.postCode} ${this.city}",
      this.subUrb,
      this.borough,
      this.country
    };

    return addressArray
        .where((element) => element.trim().length != 0)
        .join(", ");
  }
}

class CachedAddress {
  Address address;
  int expiringDate;

  CachedAddress(this.address, this.expiringDate);
}

Future<Address> getAddressOfLocation(double lat, double lon) async {
  final cachedEntry = _cache[{lat: lon}];
  if (cachedEntry != null &&
      cachedEntry.expiringDate <
          DateTime.now().add(_ttl).millisecondsSinceEpoch) {
    return cachedEntry.address;
  }

  Place place = await Nominatim.reverseSearch(
      lat: lat, lon: lon, addressDetails: true, zoom: 18);

  final address =
      Address.fromNominatimPlace(place.address, place.lat, place.lon);
  _cache[{lat: lon}] =
      CachedAddress(address, DateTime.now().add(_ttl).millisecondsSinceEpoch);

  return address;
}

Future<List<Address>> searchAddress(
    String street, String postCode, String city) async {
  List<Address> addresses = List<Address>();

  final places = await Nominatim.searchByName(
      street: street, postalCode: postCode, city: city, addressDetails: true);

  for (var place in places) {
    addresses
        .add(Address.fromNominatimPlace(place.address, place.lat, place.lon));
  }

  return addresses;
}
