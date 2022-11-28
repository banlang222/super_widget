import 'package:flutter/material.dart';
import 'render_box.dart';

class TwoCardFlow extends StatelessWidget {
  const TwoCardFlow(
      {Key? key, required this.children, this.margin, this.padding})
      : super(key: key);
  final List<Widget> children;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: TwoCardFlowRenderObjectWidget(children: children),
    );
  }
}
