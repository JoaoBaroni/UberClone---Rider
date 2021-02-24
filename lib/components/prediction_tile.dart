import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:rider/model/prediction.dart';
import 'package:rider/utils/request_helper_methods.dart';
import '../brand_colors.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({this.prediction});


  void selectDestionationAddress(BuildContext context){
    HelperMethods.setDestionationDetails(prediction.placeID, context);
  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        selectDestionationAddress(context);
      },
      child: Column(children: [
        SizedBox(height: 8,),
        Row(
          children: [
            Icon(OMIcons.locationOn, color: BrandColors.colorDimText,),
            SizedBox(height: 12,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prediction.mainText, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 2,),
                  Text(prediction.secondaryText, style: TextStyle(fontSize: 12, color: BrandColors.colorDimText), overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 8,),
      ],),
    );
  }
}