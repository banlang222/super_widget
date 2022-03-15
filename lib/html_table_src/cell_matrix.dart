import 'package:flutter/material.dart';
import 'html_cell.dart';
import 'place_holder.dart';

class CellMatrix extends StatelessWidget {
  CellMatrix(
      {Key? key,
      required this.colIndex,
      required this.rowIndex,
      this.cell,
      this.height,
      this.width})
      : super(key: key);

  final int colIndex;
  final int rowIndex;
  HtmlCell? cell;
  double? height;
  double? width;

  Map<String, dynamic> toMap() {
    return {
      'colIndex': colIndex,
      'rowIndex': rowIndex,
      'isCell': cell is! PlaceHolder
    };
  }

  @override
  Widget build(BuildContext context) {
    return cell ?? PlaceHolder();
  }
}
