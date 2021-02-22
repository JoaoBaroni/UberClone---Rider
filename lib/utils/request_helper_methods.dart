import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider/constants/constants.dart';
import 'package:rider/model/address.dart';
import 'package:rider/provider/app_data.dart';
import 'package:rider/utils/request_helper.dart';
import 'package:sprintf/sprintf.dart';

class HelperMethods{

  static Future<String> findCordinateAddress(Position position, BuildContext context) async {
    String placeAddress = '';
    final String urlGoogleMaps = sprintf('https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=%s', [API_KEY]);

    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult !=  ConnectivityResult.wifi){
      return placeAddress;
    }

    var response = await RequestHelper.getRequest(urlGoogleMaps);

    if(response != 'failed'){
      placeAddress = response['results'][0]['formatted_address'];

      Address findedAddress = new Address();
      findedAddress.placeID               = response['results'][0]['place_id'];
      findedAddress.placeFormattedAddress = placeAddress;
      findedAddress.latitude              = position.latitude;
      findedAddress.longitude             = position.longitude;
      findedAddress.placeName             = 'Teste';//

      Provider.of<AppData>(context, listen: false).updatePickupAddress(findedAddress);

    }
    return placeAddress;

  }
}