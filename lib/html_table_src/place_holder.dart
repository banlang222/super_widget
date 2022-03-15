import 'package:flutter/material.dart';
import 'html_cell.dart';

class PlaceHolder extends HtmlCell {
  PlaceHolder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
    );
  }
}
