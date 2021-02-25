import 'package:flutter/material.dart';
import 'package:rider/brand_colors.dart';

class DefaultButton extends StatelessWidget {
  final String valueName;
  final VoidCallback callback;
  final double customHeight;
  final double customWidth;

  DefaultButton({this.valueName, this.callback, this.customHeight, this.customWidth});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: callback,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25)),
      color: BrandColors.colorGreen,
      textColor: Colors.white,
      child: Container(
        height: customHeight,
        width: customWidth,
        child: Center(
            child: Text(
              '$valueName',
              style: TextStyle(
                  fontSize: 18, fontFamily: 'Brand-Bold'),
            )),
      ),
    );
  }
}