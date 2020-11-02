// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) {
  return Settings(
    json['darkMode'] as bool,
    json['daysUntilRemoval'] as int,
  );
}

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'darkMode': instance.darkMode,
      'daysUntilRemoval': instance.daysUntilRemoval,
    };
