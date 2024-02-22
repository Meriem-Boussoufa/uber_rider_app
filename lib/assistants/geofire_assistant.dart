import 'package:uber_rider_app/models/nearby_available_drivers.dart';

class GeofireAssistant {
  static List<NearbyAvailableDrivers> nearbyAvailableDrivers = [];

  static void removeDriverFromList(String key) {
    int index =
        nearbyAvailableDrivers.indexWhere((element) => element.key == key);
    nearbyAvailableDrivers.removeAt(index);
  }

  static void updateDriverNearbybyLocation(NearbyAvailableDrivers driver) {
    int index = nearbyAvailableDrivers
        .indexWhere((element) => element.key == driver.key);
    nearbyAvailableDrivers[index].longtitude = driver.longtitude;
    nearbyAvailableDrivers[index].latitude = driver.latitude;
  }
}
