import 'package:flutter/material.dart';

class CustomSizedBox {
 static Widget heigthSizedBox(double val) {
    return SizedBox(
      height: val,
    );
  }

 static Widget widthSizedBox(double val) {
    return SizedBox(
      width: val,
    );
  }
}
