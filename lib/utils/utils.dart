import 'package:flutter/material.dart';

class Utils {
  static void showSnackBar(String contentValue, GlobalKey<ScaffoldState> key){
    final snackBar = SnackBar(
        content: Text(contentValue,
            textAlign: TextAlign.center, style: TextStyle(fontSize: 15)));
    key.currentState.showSnackBar(snackBar);
  }

}