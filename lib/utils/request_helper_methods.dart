import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider/components/progress_dialog.dart';
import 'package:rider/constants/constants.dart';
import 'package:rider/model/address.dart';
import 'package:rider/model/direction_details.dart';
import 'package:rider/model/prediction.dart';
import 'package:rider/provider/app_data.dart';
import 'package:rider/utils/request_helper.dart';
import 'package:sprintf/sprintf.dart';

class HelperMethods {

  static Future<String> findCordinateAddress(Position position, BuildContext context) async {
    String placeAddress = '';
    final String urlGoogleMaps = sprintf(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=%s',
        [API_KEY]);

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    var response = await RequestHelper.getRequest(urlGoogleMaps);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address findedAddress = new Address();
      findedAddress.placeID = response['results'][0]['place_id'];
      findedAddress.placeFormattedAddress = placeAddress;
      findedAddress.latitude = position.latitude;
      findedAddress.longitude = position.longitude;
      findedAddress.placeName = 'Teste'; //

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(findedAddress);
    }
    return placeAddress;
  }
  static Future<List<Prediction>> searchPlace(String placeName) async {
    if (placeName.length > 0) {
      List<Prediction> destinationList = [];
      final String urlGooglePlace =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${placeName}&key=${API_KEY}&sessiontoken=123254251&components=country:br';
      var response = await RequestHelper.getRequest(urlGooglePlace);

      if (response == 'error') {
        return [];
      }

      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        destinationList = thisList;
        return destinationList;
      }

      debugPrint(response);
    } else {
      return [];
    }
  }
  static void setDestionationDetails(String placeID, BuildContext context) async {

    //showDialog(context: context, builder: (context) => ProgressDialog(status: 'Please wait...',),);
    
    final String urlGoogleDetails = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeID}&key=${API_KEY}';
    var response = await RequestHelper.getRequest(urlGoogleDetails);

    if (response == 'error') {
      return;
    }

    if (response['status'] == 'OK') {
      Address detailedAddress = new Address();
      detailedAddress.placeName = response['result']['name'];
      detailedAddress.placeID = placeID;
      detailedAddress.latitude = response['result']['geometry']['location']['lat'];
      detailedAddress.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false).updateDestinationAddres(detailedAddress);
      debugPrint(detailedAddress.placeName);

      Navigator.pop(context, 'getDestination');
    }


  }


  static Future<DirectionDetails> getDirectionDetails(LatLng pickupPosition, LatLng destinationPosition) async{
    final String urlGoogleDirection = 'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupPosition.latitude},${pickupPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&mode=driving&key=${API_KEY}';
    var response = await RequestHelper.getRequest(urlGoogleDirection);

    if(response == 'error'){
      return null;
    }

    DirectionDetails details = DirectionDetails();
    details.durationText  = response['routes'][0]['legs'][0]['duration']['text'];
    details.durationValue = response['routes'][0]['legs'][0]['duration']['value'];
    details.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];
    details.distanceText  = response['routes'][0]['legs'][0]['distance']['text'];
    details.encodedPoints = response['routes'][0]['overview_polyline']['points'];
    return details;

  }

}
