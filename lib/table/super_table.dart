import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;
import 'package:get/get.dart';

import 'cell_matrix.dart';
import 'super_cell.dart';
import 'place_holder.dart';
import 'renderBox.dart';

class SuperTable extends StatelessWidget {
  SuperTable(
      {Key? key,
      required this.table,
      this.showTools = true,
      this.margin = const EdgeInsets.all(0),
      this.decoration,
      this.cellPadding = const EdgeInsets.all(5),
      this.cellDecoration,
      this.evenRowDecoration})
      : assert(table != null),
        super(key: key) {
    decoration ??= const BoxDecoration(
        border: Border(
            top: BorderSide(color: Colors.black12, width: 0.5),
            bottom: BorderSide(color: Colors.black12, width: 0.5)),
        color: Colors.white);
    cellDecoration ??= const BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.black12, width: 0.5),
        bottom: BorderSide(color: Colors.black12, width: 0.5),
        left: BorderSide(color: Colors.black12, width: 0.5),
        right: BorderSide(color: Colors.black12, width: 0.5),
      ),
    );
    evenRowDecoration ??= BoxDecoration(
      color: Colors.grey[100],
      border: const Border(
        top: BorderSide(color: Colors.black12, width: 0.5),
        bottom: BorderSide(color: Colors.black12, width: 0.5),
        left: BorderSide(color: Colors.black12, width: 0.5),
        right: BorderSide(color: Colors.black12, width: 0.5),
      ),
    );
  }

  dynamic table; //String or dom.Document
  bool showTools;
  EdgeInsets margin;
  BoxDecoration? decoration;
  EdgeInsets? cellPadding;
  BoxDecoration? cellDecoration;

  ///行序号偶数，从0行开始
  BoxDecoration? evenRowDecoration;

  late dom.Node tBody;

  List<CellMatrix> tableMatrix = [];
  int totalRowSpan = 0; //矩阵总行数
  int totalColSpan = 0; //矩阵总列数

  RxDouble width = RxDouble(0);

  @override
  Widget build(BuildContext context) {
    getTBody();
    caclMatrix();
    fillTableMatrix();

    return Container(
      margin: margin,
      child: LayoutBuilder(builder: (_, c) {
        if (width.value == 0 || width.value < c.maxWidth) {
          width.value = c.maxWidth;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            showTools
                ? Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black12)),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            width.value = width.value - 50 > c.maxWidth
                                ? width.value - 50
                                : c.maxWidth;
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 20,
                        ),
                        const Text(
                          '表格缩放',
                        ),
                        IconButton(
                          onPressed: () {
                            width.value += 50;
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  )
                : Container(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: ScrollController(),
              child: Obx(() => Container(
                    constraints: BoxConstraints(maxWidth: width.value),
                    child: SuperTableRenderObjectWidget(
                      totalColSpan: totalColSpan,
                      totalRowSpan: totalRowSpan,
                      cells: tableMatrix,
                    ),
                    decoration: decoration,
                  )),
            )
          ],
        );
      }),
    );
  }

  //拆出tbody
  void getTBody() {
    if (table is String) {
      dom.Document document = dom.Document.html(table);
      dom.Node tableNode = document.body!.firstChild!;
      tBody = tableNode.children[0].localName == 'tbody'
          ? tableNode.children[0]
          : tableNode;
    } else {
      tBody =
          table.children[0]?.localName == 'tbody' ? table.children[0] : table;
    }
  }

  //计算矩阵
  void caclMatrix() {
    totalRowSpan = tBody.children.length;
    List<int> trColSpanList = List.generate(totalRowSpan, (index) => 0);
    totalColSpan = 0;
    for (int i = 0; i < tBody.children.length; i++) {
      dom.Element tr = tBody.children[i];
      for (var td in tr.children) {
        int colSpan = 1;
        if (td.attributes.containsKey('colspan')) {
          colSpan = int.tryParse(td.attributes['colspan']!) ?? 1;
        }
        trColSpanList[i] += colSpan;

        if (td.attributes.containsKey('rowspan')) {
          int rowSpan = int.tryParse(td.attributes['rowspan']!) ?? 1;
          if (rowSpan > 1) {
            for (int n = 1; n < rowSpan; n++) {
              trColSpanList[i + n] += 1;
            }
          }
        }
      }
      //取colspan最大值，用于容错
      if (trColSpanList[i] > totalColSpan) {
        totalColSpan = trColSpanList[i];
      }
    }
  }

  //将单元格填充进tableMatrix
  void fillTableMatrix() {
    tableMatrix = [];
    for (int y = 0; y < totalRowSpan; y++) {
      for (int x = 0; x < totalColSpan; x++) {
        tableMatrix.add(CellMatrix(colIndex: x, rowIndex: y));
      }
    }

    int y = 0;
    for (var tr in tBody.children) {
      for (var td in tr.children) {
        //print('td=${td.text}');
        //本位，查找所属行的空位
        CellMatrix self = tableMatrix
            .where((element) => element.rowIndex == y && element.cell == null)
            .first;
        int rowSpan = 1;
        int colSpan = 1;
        //填充本位
        self.cell = SuperCell(
          text: td.nodes, //td.text.replaceAll(RegExp(r'\s'), ''),
          padding: cellPadding,
          decoration: y.isEven ? evenRowDecoration : cellDecoration,
        );
        //print('填充${self.x}, ${self.y}');
        if (td.attributes.containsKey('rowspan')) {
          rowSpan = int.tryParse(td.attributes['rowspan']!) ?? 1;
        }
        if (td.attributes.containsKey('colspan')) {
          colSpan = int.tryParse(td.attributes['colspan']!) ?? 1;
        }
        self.cell!.rowSpan = rowSpan;
        self.cell!.colSpan = colSpan;
        //多行占位
        if (rowSpan > 1) {
          List<int> yList =
              List.generate(rowSpan - 1, (index) => self.rowIndex + index + 1);
          //print('y多占${yList}');
          tableMatrix
              .where((element) =>
                  yList.contains(element.rowIndex) &&
                  element.colIndex == self.colIndex)
              .forEach((element) => element.cell = PlaceHolder());
        }
        //多列占位
        if (colSpan > 1) {
          List<int> xList =
              List.generate(colSpan - 1, (index) => self.colIndex + index + 1);
          //print('x多占${xList}');
          tableMatrix
              .where((element) =>
                  xList.contains(element.colIndex) &&
                  element.rowIndex == self.rowIndex)
              .forEach((element) => element.cell = PlaceHolder());
        }
      }
      y += 1;
    }
    //填充非法单元格
    tableMatrix.where((element) => element.cell == null).forEach((element) {
      element.cell = SuperCell(
        padding: cellPadding,
        decoration: cellDecoration,
        text: '',
      );
    });
  }
}
