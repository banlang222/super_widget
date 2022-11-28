import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;
import 'package:get/get.dart';

import 'grid.dart';
import 'td.dart';
import 'tr.dart';
import 'place_holder.dart';
import 'renderBox.dart';

class HtmlTable extends StatelessWidget {
  HtmlTable(
      {Key? key,
      this.html,
      this.children = const <TR>[],
      this.showTools = true,
      this.margin = const EdgeInsets.all(0),
      this.decoration = const BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.black12, width: 0.5),
              bottom: BorderSide(color: Colors.black12, width: 0.5)),
          color: Colors.white),
      this.cellPadding = const EdgeInsets.all(5),
      this.cellDecoration = const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 0.5),
          bottom: BorderSide(color: Colors.black12, width: 0.5),
          left: BorderSide(color: Colors.black12, width: 0.5),
          right: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      this.evenRowDecoration = const BoxDecoration(
        color: Colors.black12,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 0.5),
          bottom: BorderSide(color: Colors.black12, width: 0.5),
          left: BorderSide(color: Colors.black12, width: 0.5),
          right: BorderSide(color: Colors.black12, width: 0.5),
        ),
      )})
      : assert(html != null || children.isNotEmpty),
        super(key: key);

  ///表格数据，htmlString or dom.Node
  final dynamic html;
  //直接由TR List构建的行数据
  final List<TR> children;
  //是否显示工具
  final bool showTools;
  //表格margin
  final EdgeInsets margin;
  //表格的decoration
  final BoxDecoration decoration;
  //单元格的padding
  final EdgeInsets cellPadding;
  //单元格的decoration
  final BoxDecoration cellDecoration;

  ///偶数行的decoration 从0行开始的行序号
  final BoxDecoration evenRowDecoration;

  //网格表，表格由网格实际构成，网格的cell填充实际的单元格Widget
  final List<Grid> _tableGrids = [];

  final RxDouble _width = RxDouble(0);

  int _totalRowSpan = 0; //网格总行数
  int _totalColSpan = 0; //网格总列数

  @override
  Widget build(BuildContext context) {
    calculateTableGrids();

    return Container(
      margin: margin,
      child: LayoutBuilder(builder: (_, c) {
        if (_width.value == 0 || _width.value < c.maxWidth) {
          _width.value = c.maxWidth;
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
                            _width.value = _width.value - 50 > c.maxWidth
                                ? _width.value - 50
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
                            _width.value += 50;
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
              physics:
                  const BouncingScrollPhysics(), //目前仅可用这个，当SingleChildScrollView嵌套在ListView中时，使用其他physics会导致pverscroll_indicator.dart _handleScrollNotification时assert(notification.metrics.axis == widget.axis);不成立
              child: Obx(() => Container(
                    constraints: BoxConstraints(maxWidth: _width.value),
                    child: HtmlTableRenderObjectWidget(
                      totalColSpan: _totalColSpan,
                      totalRowSpan: _totalRowSpan,
                      grids: _tableGrids,
                    ),
                    decoration: decoration,
                  )),
            )
          ],
        );
      }),
    );
  }

  //计算网格
  void calculateTableGrids() {
    if (html != null) {
      calculateTableGridsFromHtml();
    } else if (children.isNotEmpty) {
      calculateTableGridsFromChildren();
    } else {
      throw Exception('缺少表格数据');
    }
  }

  //使用children数据计算网格
  void calculateTableGridsFromChildren() {
    //计算基础网格的行列数量
    _totalRowSpan = children.length;
    List<int> trColSpanList = List.generate(_totalRowSpan, (index) => 0);
    _totalColSpan = 0;
    for (int i = 0; i < children.length; i++) {
      TR tr = children[i];
      for (var td in tr.children) {
        trColSpanList[i] += td.colSpan;
        if (td.rowSpan > 1) {
          for (int n = 1; n < td.rowSpan; n++) {
            trColSpanList[i + n] += 1;
          }
        }
      }
      //取colspan最大值，用于容错
      if (trColSpanList[i] > _totalColSpan) {
        _totalColSpan = trColSpanList[i];
      }
    }

    //构建整个基础网格表
    _tableGrids.clear();
    for (int y = 0; y < _totalRowSpan; y++) {
      for (int x = 0; x < _totalColSpan; x++) {
        _tableGrids.add(Grid(colIndex: x, rowIndex: y));
      }
    }

    //将实际单元格填充进基础网格表
    int y = 0;
    for (TR tr in children) {
      for (TD td in tr.children) {
        //print('td=${td.text}');
        //查找所属行的首个空位作为本位
        Grid self = _tableGrids
            .where((element) => element.rowIndex == y && element.cell == null)
            .first;
        td.padding = cellPadding;
        td.decoration = y.isEven ? evenRowDecoration : cellDecoration;
        //填充本位单元格
        self.cell = td;

        //多行占位，将被占的位置改为placeHolder
        if (td.rowSpan > 1) {
          List<int> yList = List.generate(
              td.rowSpan - 1, (index) => self.rowIndex + index + 1);
          //print('y多占${yList}');
          _tableGrids
              .where((element) =>
                  yList.contains(element.rowIndex) &&
                  element.colIndex == self.colIndex)
              .forEach((element) => element.cell = PlaceHolder());
        }
        //多列占位，将被占的位置改为placeHolder
        if (td.colSpan > 1) {
          List<int> xList = List.generate(
              td.colSpan - 1, (index) => self.colIndex + index + 1);
          //print('x多占${xList}');
          _tableGrids
              .where((element) =>
                  xList.contains(element.colIndex) &&
                  element.rowIndex == self.rowIndex)
              .forEach((element) => element.cell = PlaceHolder());
        }
      }
      y += 1;
    }

    //填充非法单元格
    _tableGrids.where((element) => element.cell == null).forEach((element) {
      element.cell = TD(
        padding: cellPadding,
        decoration: cellDecoration,
        text: '',
      );
    });
  }

  //使用html数据计算网格
  void calculateTableGridsFromHtml() {
    //提取tbody
    dom.Node tBody;
    if (html is String) {
      dom.Document document = dom.Document.html(html);
      dom.Node tableNode = document.body!.firstChild!;
      tBody = tableNode.children[0].localName == 'tbody'
          ? tableNode.children[0]
          : tableNode;
    } else {
      tBody = html.children[0]?.localName == 'tbody' ? html.children[0] : html;
    }
    //计算基础网格的行列数量
    _totalRowSpan = tBody.children.length;
    List<int> trColSpanList = List.generate(_totalRowSpan, (index) => 0);
    _totalColSpan = 0;
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
      if (trColSpanList[i] > _totalColSpan) {
        _totalColSpan = trColSpanList[i];
      }
    }

    //构建整个基础网格表
    _tableGrids.clear();
    for (int y = 0; y < _totalRowSpan; y++) {
      for (int x = 0; x < _totalColSpan; x++) {
        _tableGrids.add(Grid(colIndex: x, rowIndex: y));
      }
    }

    //将单元格填充进基础网格
    int y = 0;
    for (var tr in tBody.children) {
      for (var td in tr.children) {
        //print('td=${td.text}');
        //查找所属行的首个空位作为本位
        Grid self = _tableGrids
            .where((element) => element.rowIndex == y && element.cell == null)
            .first;
        int rowSpan = 1;
        int colSpan = 1;
        if (td.attributes.containsKey('rowspan')) {
          rowSpan = int.tryParse(td.attributes['rowspan']!) ?? 1;
        }
        if (td.attributes.containsKey('colspan')) {
          colSpan = int.tryParse(td.attributes['colspan']!) ?? 1;
        }
        //填充本位的单元格
        self.cell = TD(
          text: td.nodes, //td.text.replaceAll(RegExp(r'\s'), ''),
          padding: cellPadding,
          decoration: y.isEven ? evenRowDecoration : cellDecoration,
          rowSpan: rowSpan,
          colSpan: colSpan,
        );
        //多行占位，将被占的位置改为placeHolder
        if (rowSpan > 1) {
          List<int> yList =
              List.generate(rowSpan - 1, (index) => self.rowIndex + index + 1);
          //print('y多占${yList}');
          _tableGrids
              .where((element) =>
                  yList.contains(element.rowIndex) &&
                  element.colIndex == self.colIndex)
              .forEach((element) => element.cell = PlaceHolder());
        }
        //多列占位，将被占的位置改为placeHolder
        if (colSpan > 1) {
          List<int> xList =
              List.generate(colSpan - 1, (index) => self.colIndex + index + 1);
          //print('x多占${xList}');
          _tableGrids
              .where((element) =>
                  xList.contains(element.colIndex) &&
                  element.rowIndex == self.rowIndex)
              .forEach((element) => element.cell = PlaceHolder());
        }
      }
      y += 1;
    }
    //填充非法单元格
    _tableGrids.where((element) => element.cell == null).forEach((element) {
      element.cell = TD(
        padding: cellPadding,
        decoration: cellDecoration,
        text: '',
      );
    });
  }
}
