import 'package:flutter/material.dart';
import 'td.dart';
import 'place_holder.dart';

///基础网格，标记行列位置以及根据单元格计算出的实际高宽数据
class Grid extends StatelessWidget {
  Grid(
      {Key? key,
      required this.colIndex,
      required this.rowIndex,
      this.cell,
      this.height,
      this.width})
      : super(key: key);

  final int colIndex;
  final int rowIndex;
  TD? cell;
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
