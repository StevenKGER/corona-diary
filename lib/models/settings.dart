import 'package:corona_diary/util/store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

final defaultDarkMode = true;
final defaultDaysUntilRemoval = 14;

@JsonSerializable()
class Settings {
  bool darkMode;
  int daysUntilRemoval;

  Settings(this.darkMode, this.daysUntilRemoval);

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}

Future<Settings> getSettings() async {
  Map<String, dynamic> json = await jsonStore.getItem("settings");

  if (json == null) {
    json = Settings(defaultDarkMode, defaultDaysUntilRemoval).toJson();
  }

  return Settings.fromJson(json);
}

void saveSettings(Settings settings) async {
  await jsonStore.setItem("settings", settings.toJson(),
      timeToLive: new Duration(days: 365 * 50));
}
