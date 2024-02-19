import 'package:geolocator/geolocator.dart';
import 'package:uber_rider_app/assistants/request_assistant.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position) async {
    String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyA5uLRfE1Ea9ie7ei9PGHJT43VQVm-IQCM";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      placeAddress = response["results"][0]["formatted_address"];
    }
    return placeAddress;
  }
}
