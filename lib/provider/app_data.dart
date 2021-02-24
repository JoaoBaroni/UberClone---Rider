import 'package:flutter/cupertino.dart';
import 'package:rider/model/address.dart';

class AppData extends ChangeNotifier{
  Address pickupAddress;
  Address destinationAddress;

  void updatePickupAddress(Address pickup){
    pickupAddress = pickup;
    notifyListeners(); //To notify all widget tree; :)
  }

  void updateDestinationAddres(Address destination){
    destinationAddress = destination;
    notifyListeners();
  }

}