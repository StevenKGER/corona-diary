import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

@JsonSerializable()
class Entry {
  int id;
  String name;
  String street;
  String houseNumber;
  String postCode;
  String city;
  String subUrb;
  String borough;
  String country;
  double latitude;
  double longitude;
  String description;
  int startTime;
  int endTime;

  Entry(
      this.id,
      this.name,
      this.street,
      this.houseNumber,
      this.postCode,
      this.city,
      this.subUrb,
      this.borough,
      this.country,
      this.latitude,
      this.longitude,
      this.description,
      this.startTime,
      this.endTime);

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  String toAddressString() {
    final addressArray = {
      "${this.street} ${this.houseNumber}",
      "${this.postCode} ${this.city}",
      this.subUrb,
      this.country
    };

    return addressArray
        .where((element) => element?.trim()?.length != 0)
        .join(", ");
  }
}
