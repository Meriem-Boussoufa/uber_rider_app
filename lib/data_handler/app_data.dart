import 'package:flutter/material.dart';
import '../models/address.dart';

class AppData extends ChangeNotifier {
  Address? pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffLocation) {
    dropOffLocation = dropOffLocation;
    notifyListeners();
  }
}
