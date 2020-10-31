import 'package:location/location.dart';

Location location = new Location();

void initLocation() async {
  var serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled)
    serviceEnabled = await location.requestService();
  if (!serviceEnabled)
    location = null;

  var permissionStatus = await location.hasPermission();
  if (permissionStatus == PermissionStatus.denied)
    permissionStatus = await location.requestPermission();
  if (permissionStatus != PermissionStatus.granted)
    location = null;
}

