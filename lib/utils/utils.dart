import 'package:flutter/material.dart';

class Utils {
  static void showSnackBar(String contentValue, GlobalKey<ScaffoldState> key){
    final snackBar = SnackBar(
        content: Text(contentValue,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 15)));
    key.currentState.showSnackBar(snackBar);
  }

  static double screenHeigthValue(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static double screenWidthValue(BuildContext context){
    return MediaQuery.of(context).size.width;
  }

}