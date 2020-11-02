import 'package:corona_diary/util/location.dart';
import 'package:location/location.dart';

Future<LocationData> getLocation() async {
  return await location?.getLocation();
}