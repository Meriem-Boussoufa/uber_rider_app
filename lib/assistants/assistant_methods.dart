import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider_app/assistants/request_assistant.dart';
import 'package:uber_rider_app/data_handler/app_data.dart';
import 'package:uber_rider_app/models/address.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyA5uLRfE1Ea9ie7ei9PGHJT43VQVm-IQCM";

    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      //placeAddress = response["results"][0]["formatted_address"];

      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = "$st1 , $st2 , $st3 , $st4";

      Address userPickUpAdress = Address();
      userPickUpAdress.longtitude = position.longitude;
      userPickUpAdress.latitude = position.latitude;
      userPickUpAdress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAdress);
    }
    return placeAddress;
  }
}