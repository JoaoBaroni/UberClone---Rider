import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rider/brand_colors.dart';
import 'package:rider/provider/app_data.dart';
import 'package:rider/utils/utils.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  static String id = 'searchPage';


  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double heightValue = Utils.screenHeigthValue(context);
    double widthValue = Utils.screenWidthValue(context);
    String currentAddress = Provider.of<AppData>(context).pickupAddress != null ? Provider.of<AppData>(context).pickupAddress.placeFormattedAddress : '';
    pickupController.text = currentAddress;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: heightValue * 0.25,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7))
            ]),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Column(
                children: [
                  SizedBox(height: heightValue * 0.05),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back)),
                      Center(
                        child: Text(
                          'Set Destination',
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: 'Brand-Bold'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: heightValue * 0.03),
                  Row(
                    children: [
                      Image.asset('images/pickicon.png', height: 16, width: 16),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorGreen,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextField(
                            controller: pickupController,
                            decoration: InputDecoration(
                                hintText: 'Pickup location',
                                filled: true,
                                fillColor: BrandColors.colorLightGrayFair,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 8, bottom: 8)),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: heightValue * 0.01),
                  Row(
                    children: [
                      Image.asset('images/desticon1.png',
                          height: 16, width: 16),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: BrandColors.colorGreen,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextField(
                            controller: destinationController,
                            decoration: InputDecoration(
                                hintText: 'Pickup location',
                                filled: true,
                                fillColor: BrandColors.colorLightGrayFair,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, top: 8, bottom: 8)),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
