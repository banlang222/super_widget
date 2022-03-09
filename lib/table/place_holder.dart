import 'package:flutter/material.dart';
import 'super_cell.dart';

class PlaceHolder extends SuperCell {
  PlaceHolder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
    );
  }
}
