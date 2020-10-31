import 'package:osm_nominatim/osm_nominatim.dart';

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

Future<Address> getAddressOfLocation(double lat, double lon) async {
  Place place = await Nominatim.reverseSearch(
      lat: lat, lon: lon, addressDetails: true, zoom: 2);

  return Address.fromNominatimPlace(place.address, place.lat, place.lon);
}

Future<List<Address>> searchAddress(
    String street, String postCode, String city) async {
  List<Address> addresses = List<Address>();

  final places = await Nominatim.searchByName(
      street: street, postalCode: postCode, city: city);

  for (var place in places) {
    addresses
        .add(Address.fromNominatimPlace(place.address, place.lat, place.lon));
  }

  return addresses;
}
