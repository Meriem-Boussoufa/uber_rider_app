import 'package:flutter/material.dart';
import '../models/address.dart';

class AppData extends ChangeNotifier {
  Address? pickUpLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }
}
