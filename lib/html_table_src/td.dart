import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;

class TD extends StatelessWidget {
  TD(
      {Key? key,
      this.text,
      this.rowSpan = 1,
      this.colSpan = 1,
      this.alignment = Alignment.centerLeft,
      this.padding,
      this.decoration})
      : super(key: key);

  //String or dom.NodeList
  final dynamic text;
  int rowSpan;
  int colSpan;
  final Alignment alignment;
  EdgeInsets? padding;
  BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (text is String) {
      child = Text(text);
    }
    //text is dom.NodeList
    else {
      dom.NodeList nodes = text;
      List<Widget> children = [];
      List<TextSpan> spans = [];
      for (var node in nodes) {
        //p需要新起一行
        if (node is dom.Element && node.localName == 'p') {
          //将前一组添加进children
          if (spans.isNotEmpty) {
            children.add(RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: spans)));
          }
          //新起一行
          spans.clear();
          String _text = node.text.replaceAll(RegExp(r'\s+'), '');
          if (_text.isNotEmpty) {
            children.add(RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [TextSpan(text: _text)])));
          }
        }
        //非p，不换行，直接加入到spans中
        else {
          String _text = node.text!.replaceAll(RegExp(r'\s+'), '');
          if (_text.isNotEmpty) {
            spans.add(TextSpan(text: _text));
          }
        }
      }
      //将剩余spans加入children
      if (spans.isNotEmpty) {
        children.add(RichText(
            text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: spans)));
      }
      if (children.isEmpty) {
        child = const Text('');
      } else if (children.length > 1) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
        //以下注释掉是因为提示RenderShrinkWrappingViewport does not support returning intrinsic dimensions
        // child = ListView.builder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   itemBuilder: (BuildContext context, int index) {
        //     return children[index];
        //   },
        //   itemCount: children.length,
        // );
      } else {
        child = children.first;
      }
    }

    return Container(
      width: double.infinity,
      padding: padding,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );
  }
}
