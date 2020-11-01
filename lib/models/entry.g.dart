// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    json['id'] as int,
    json['street'] as String,
    json['houseNumber'] as String,
    json['postCode'] as String,
    json['city'] as String,
    json['subUrb'] as String,
    json['borough'] as String,
    json['country'] as String,
    (json['latitude'] as num)?.toDouble(),
    (json['longitude'] as num)?.toDouble(),
    json['description'] as String,
    json['startTime'] as int,
    json['endTime'] as int,
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'id': instance.id,
      'street': instance.street,
      'houseNumber': instance.houseNumber,
      'postCode': instance.postCode,
      'city': instance.city,
      'subUrb': instance.subUrb,
      'borough': instance.borough,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };
