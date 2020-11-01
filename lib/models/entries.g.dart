// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entries _$EntriesFromJson(Map<String, dynamic> json) {
  return Entries(
    json['highestId'] as int,
    (json['entryList'] as List)
        ?.map(
            (e) => e == null ? null : Entry.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$EntriesToJson(Entries instance) => <String, dynamic>{
      'highestId': instance.highestId,
      'entryList': instance.entryList,
    };
