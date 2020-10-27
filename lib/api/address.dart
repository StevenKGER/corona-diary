import 'package:osm_nominatim/osm_nominatim.dart';

class Address {
  String street;
  String houseNumber;
  String postCode;
  String city;
  String subUrb;
  String borough;
  String country;

  Address(this.street, this.houseNumber, this.postCode, this.city, this.subUrb,
      this.borough, this.country);

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
        map["road"] as String ?? "",
        map["house_number"] as String ?? "",
        map["postcode"] as String ?? "",
        map["city"] as String ?? "",
        map["suburb"] as String ?? "",
        map["borough"] as String ?? "",
        map["country"] as String ?? ""
    );
  }

  @override
  String toString() {
    var addressArray = List.of({
      "${this.street} ${this.houseNumber}",
      "${this.postCode} ${this.city}",
      this.subUrb,
      this.borough,
      this.country
    });

    return addressArray
        .where((element) => element.trim().length != 0)
        .join(", ");
  }
}

Future<Address> getAddressOfLocation(double lat, double lon) async {
  Place place = await Nominatim.reverseSearch(
      lat: lat, lon: lon, addressDetails: true, zoom: 2);

  return Address.fromMap(place.address);
}
