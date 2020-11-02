import 'package:location/location.dart';

Location location = new Location();
bool _initiated = false;

void initLocation() async {
  if (_initiated || location == null) return;

  var serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) serviceEnabled = await location.requestService();
  if (!serviceEnabled) {
    location = null;
    return;
  }

  var permissionStatus = await location.hasPermission();
  if (permissionStatus == PermissionStatus.denied)
    permissionStatus = await location.requestPermission();
  if (permissionStatus != PermissionStatus.granted) {
    location = null;
    return;
  }

  _initiated = true;
}
