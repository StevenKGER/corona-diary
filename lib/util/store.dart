import 'package:corona_diary/models/entries.dart';
import 'package:corona_diary/models/settings.dart';
import 'package:json_store/json_store.dart';

JsonStore jsonStore = JsonStore(dbName: 'corona_diary');

void initJsonStore() async {
  if (await jsonStore.getItem("settings") == null) {
    saveSettings(Settings(defaultDarkMode, defaultDaysUntilRemoval));
  }

  if (await jsonStore.getItem("entries") == null) {
    await jsonStore.setItem("entries", Entries(-1, []).toJson());
  }
}
