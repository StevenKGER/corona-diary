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
  return Entries.fromJson(await jsonStore.getItem("entries"));
}

void addEntryByAddress(
    Address address, String description, int startTime, int endTime) async {
  Entries entries = await getAllEntries();

  var newID = entries.highestId + 1;
  entries.entryList.add(Entry(
      newID,
      address.street,
      address.houseNumber,
      address.postCode,
      address.city,
      address.subUrb,
      address.borough,
      address.country,
      address.latitude,
      address.longitude,
      description,
      startTime,
      endTime));
  entries.highestId = newID;

  await jsonStore.setItem("entries", entries.toJson());
}

void addEntryByPOI(
    POI poi, String description, int startTime, int endTime) async {
  Entries entries = await getAllEntries();

  var newID = entries.highestId + 1;
  entries.entryList.add(Entry(
      newID,
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

  if (entries.highestId < id)
    return;

  entries.entryList
      .where((element) => element.id != id)
      .forEach((element) => tempList.add(element));
  entries.highestId -= 1;
  for (int i = id - 1; i < entries.highestId; i++) {
    final tempEntry = tempList[i];
    tempEntry.id = i;
    tempList[i] = tempEntry;
  }

  entries.entryList = tempList;
  await jsonStore.setItem("entries", entries.toJson());
}
