import 'package:corona_diary/api/address.dart';
import 'package:corona_diary/api/poi.dart';
import 'package:corona_diary/models/entry.dart';
import 'package:corona_diary/util/store.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entries.g.dart';

@JsonSerializable()
class Entries {
  int highestId;
  List<Entry> entryList;

  Entries(this.highestId, this.entryList);

  factory Entries.fromJson(Map<String, dynamic> json) =>
      _$EntriesFromJson(json);

  Map<String, dynamic> toJson() => _$EntriesToJson(this);
}

Future<Entries> getAllEntries() async {
  var json = await jsonStore.getItem("entries");
  if (json == null) {
    json = {"highestId": -1, "entryList": []};
  }
  return Entries.fromJson(json);
}

void addEntryByAddress(String name, Address address, String description,
    int startTime, int endTime) async {
  Entries entries = await getAllEntries();

  var newID = entries.highestId + 1;
  entries.entryList.add(Entry(
      newID,
      name,
      address?.street,
      address?.houseNumber,
      address?.postCode,
      address?.city,
      address?.subUrb,
      address?.borough,
      address?.country,
      address?.latitude,
      address?.longitude,
      description,
      startTime,
      endTime));
  entries.highestId = newID;

  await jsonStore.setItem("entries", entries.toJson());
}

void addEntryByPOI(String name, POI poi, String description, int startTime,
    int endTime) async {
  Entries entries = await getAllEntries();

  var newID = entries.highestId + 1;
  entries.entryList.add(Entry(
      newID,
      name,
      poi.street,
      poi.houseNumber,
      poi.postCode,
      poi.city,
      poi.subUrb,
      null,
      poi.country,
      poi.latitude,
      poi.longitude,
      description,
      startTime,
      endTime));
  entries.highestId = newID;

  await jsonStore.setItem("entries", entries.toJson());
}

void updateEntry(Entry entry) async {
  Entries entries = await getAllEntries();
  entries.entryList[entry.id] = entry;
  await jsonStore.setItem("entries", entries.toJson());
}

void removeEntryById(int id) async {
  List<Entry> tempList = [];
  Entries entries = await getAllEntries();

  if (entries.highestId < id) return;

  entries.entryList
      .where((element) => element.id != id)
      .forEach((element) => tempList.add(element));
  entries.highestId -= 1;
  for (int i = id; i <= entries.highestId; i++) {
    final tempEntry = tempList[i];
    tempEntry.id = i;
    tempList[i] = tempEntry;
  }

  entries.entryList = tempList;
  await jsonStore.setItem("entries", entries.toJson());
}

void removeEntriesOlderThen(int days) async {
  List<Entry> tempList = [];
  Entries entries = await getAllEntries();

  entries.entryList.where((element) {
    final entryDate = DateTime.fromMillisecondsSinceEpoch(element.startTime);
    final currentDate = DateTime.now();

    if (entryDate.millisecondsSinceEpoch > currentDate.millisecondsSinceEpoch)
      return true;

    return entryDate.difference(currentDate).abs().inDays < days;
  }).forEach((element) => tempList.add(element));

  entries.entryList = tempList;
  entries.highestId = tempList.length - 1;
  await jsonStore.setItem("entries", entries.toJson());
}
