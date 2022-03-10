import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'cell_matrix.dart';
import 'place_holder.dart';

class HtmlTableRenderObjectWidget extends MultiChildRenderObjectWidget {
  HtmlTableRenderObjectWidget(
      {Key? key,
      required this.totalRowSpan,
      required this.totalColSpan,
      required this.cells})
      : super(key: key, children: cells);

  final int totalRowSpan;
  final int totalColSpan;
  final List<CellMatrix> cells;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHtmlTable(
        totalRowSpan: totalRowSpan, totalColSpan: totalColSpan, cells: cells);
  }
}

class SuperCellParentData extends ContainerBoxParentData<RenderBox> {}

class RenderHtmlTable extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SuperCellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SuperCellParentData> {
  RenderHtmlTable(
      {required this.totalRowSpan,
      required this.totalColSpan,
      required this.cells});

  int totalRowSpan;
  int totalColSpan;
  List<CellMatrix> cells;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SuperCellParentData) {
      child.parentData = SuperCellParentData();
    }
  }

  @override
  void performLayout() {
    BoxConstraints constraints = this.constraints;

    RenderBox? child = firstChild;
    int i = 0;
    //计算单元格最小宽度，跨行的除以行数
    while (child != null) {
      SuperCellParentData parentData = child.parentData as SuperCellParentData;
      if (cells[i].cell != null && cells[i].cell is! PlaceHolder) {
        cells[i].width = (child.getMinIntrinsicWidth(0) +
                (cells[i].cell?.padding?.horizontal ?? 0)) /
            cells[i].cell!.rowSpan;
      }
      child = parentData.nextSibling;
      i += 1;
    }
    //统计每列最大宽度
    List<double> colWidthList = List.generate(totalColSpan, (index) => 0.0);
    //处理不跨列的单元格
    cells
        .where((element) =>
            element.cell is! PlaceHolder && element.cell!.colSpan == 1)
        .forEach((element) {
      colWidthList[element.colIndex] =
          math.max(colWidthList[element.colIndex], element.width!);
    });
    //处理跨列的单元格
    cells
        .where((element) =>
            element.cell is! PlaceHolder && element.cell!.colSpan > 1)
        .forEach((element) {
      Iterable<double> range = colWidthList.getRange(
          element.colIndex, element.colIndex + element.cell!.colSpan);
      if (range.contains(0)) {
        Iterable<double> vList = range.where((element) => element > 0); //已经有值的列
        //全都没有值，直接均分
        if (vList.isEmpty) {
          double add = element.width! / element.cell!.colSpan;
        } else {
          double v = vList.reduce((value, element) => value + element); //已有宽度
          //已有宽度不够用，将不够用的部分均分给无值的列
          if (v < element.width!) {
            double add = (element.width! - v) / range.length - vList.length;
          }
        }
      } else {
        double sum = range.reduce((value, element) => value + element);
        if (element.width! > sum) {
          colWidthList[element.colIndex] +=
              (element.width! - sum) / element.cell!.colSpan;
        }
      }
    });
    //计算列宽总和
    double colWidthSum =
        colWidthList.reduce((value, element) => value + element);

    //根据宽占比分配各列宽
    List<double> colWidthFinalList = colWidthList
        .map((e) => e / colWidthSum * constraints.maxWidth)
        .toList();

    //根据各列宽计算高度
    child = firstChild;
    i = 0;
    //按照列均分宽度计算高度
    while (child != null) {
      SuperCellParentData parentData = child.parentData as SuperCellParentData;
      if (cells[i].cell != null && cells[i].cell is! PlaceHolder) {
        cells[i].height =
            child.getMinIntrinsicHeight(colWidthFinalList[cells[i].colIndex]);
      }
      child = parentData.nextSibling;
      i += 1;
    }

    //统计每行最大高度，初始值为0
    List<double> rowHeightList = List.generate(totalRowSpan, (index) => 0.0);
    //处理不跨行的单元格
    cells
        .where((element) =>
            element.cell is! PlaceHolder && element.cell!.rowSpan == 1)
        .forEach((element) {
      rowHeightList[element.rowIndex] =
          math.max(rowHeightList[element.rowIndex], element.height!);
    });
    //处理跨行的单元格
    cells
        .where((element) =>
            element.cell is! PlaceHolder && element.cell!.rowSpan > 1)
        .forEach((element) {
      double sum = 0;
      for (int i = element.rowIndex;
          i < element.rowIndex + element.cell!.rowSpan;
          i++) {
        sum += rowHeightList[i];
      }
      //如果跨行的内容高度超过所跨的行高总和，则将多出的部分均分给各行
      if (element.height! > sum) {
        for (int i = element.rowIndex;
            i < element.rowIndex + element.cell!.rowSpan;
            i++) {
          rowHeightList[i] += (element.height! - sum) / element.cell!.rowSpan;
        }
      }
    });

    //有了列宽和行高了，重新布局并分配位置
    child = firstChild;
    i = 0;
    int rowIndex = 0;
    double dy = 0;
    while (child != null) {
      SuperCellParentData parentData = child.parentData as SuperCellParentData;
      //cells[i].cell已经填充过，没有null值
      //更新到下一行
      if (cells[i].rowIndex != rowIndex) {
        rowIndex = cells[i].rowIndex;
        dy = rowHeightList
            .getRange(0, rowIndex)
            .reduce((value, element) => value + element);
      }
      int colIndex = cells[i].colIndex;
      double dx = colIndex == 0
          ? 0
          : colWidthFinalList
              .getRange(0, colIndex)
              .reduce((value, element) => value + element);
      parentData.offset = Offset(dx, dy);

      double w = cells[i].cell!.colSpan == 1
          ? colWidthFinalList[colIndex]
          : colWidthFinalList
              .getRange(colIndex, colIndex + cells[i].cell!.colSpan)
              .reduce((value, element) => value + element);
      double h = cells[i].cell!.rowSpan == 1
          ? rowHeightList[rowIndex]
          : rowHeightList
              .getRange(rowIndex, rowIndex + cells[i].cell!.rowSpan)
              .reduce((value, element) => value + element);
      //PlaceHolder，不显示
      if (cells[i].cell is PlaceHolder) {
        child.layout(constraints.copyWith(maxWidth: 0, maxHeight: 0),
            parentUsesSize: false);
      } else {
        child.layout(
            constraints.copyWith(
                maxWidth: w, minWidth: 0, maxHeight: h, minHeight: h),
            parentUsesSize: true);
      }

      child = parentData.nextSibling;
      i += 1;
    }

    size = Size(constraints.maxWidth,
        rowHeightList.reduce((value, element) => value + element));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
