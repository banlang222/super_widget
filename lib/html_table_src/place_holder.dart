import 'package:flutter/material.dart';
import 'td.dart';

class PlaceHolder extends TD {
  PlaceHolder({Key? key})
      : super(
            key: key,
            decoration: const BoxDecoration(),
            padding: EdgeInsets.zero);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
    );
  }
}
