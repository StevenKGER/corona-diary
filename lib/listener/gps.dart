import 'package:corona_diary/util/location.dart';
import 'package:corona_diary/util/notification.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

LocationData _oldLocation;
int timeOfNotification = DateTime.now().millisecondsSinceEpoch;

void startListener() {
  location.onLocationChanged.listen((LocationData currentLocation) {
    if (_oldLocation == null) {
      _oldLocation = currentLocation;
      return;
    }

    if (currentLocation.time - timeOfNotification >= 1000 * 60 * 60) {
      final distance = new Distance();
      final int metersMoved = distance(
          new LatLng(_oldLocation.latitude, _oldLocation.longitude),
          new LatLng(currentLocation.latitude, currentLocation.longitude));

      if (metersMoved >= 20) {
        showNotification(
            "Bewegung erkannt", "Denke daran, Dein Corona-Tagebuch zu führen.");
        timeOfNotification = currentLocation.time.toInt();
        _oldLocation = currentLocation;
      }
    }
  });
}
