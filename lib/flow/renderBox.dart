import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TwoCardFlowRenderObjectWidget extends MultiChildRenderObjectWidget {
  TwoCardFlowRenderObjectWidget({Key? key, required List<Widget> children})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTwoCardFlow();
  }
}

class TwoCardFlowParentData extends ContainerBoxParentData<RenderBox> {}

class RenderTwoCardFlow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TwoCardFlowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TwoCardFlowParentData> {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TwoCardFlowParentData) {
      child.parentData = TwoCardFlowParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    double childMaxWidth = constraints.maxWidth / 2;

    double height = 0;
    Offset nextLeftOffset = const Offset(0, 0);
    Offset nextRightOffset = Offset(childMaxWidth, 0);
    RenderBox? child = firstChild;
    while (child != null) {
      TwoCardFlowParentData parentData =
          child.parentData as TwoCardFlowParentData;
      if (nextRightOffset.dy < nextLeftOffset.dy) {
        parentData.offset = Offset(nextRightOffset.dx, nextRightOffset.dy);
        child.layout(constraints.copyWith(maxWidth: childMaxWidth, minWidth: 0),
            parentUsesSize: true);
        nextRightOffset =
            Offset(nextRightOffset.dx, nextRightOffset.dy + child.size.height);
      } else {
        parentData.offset = Offset(nextLeftOffset.dx, nextLeftOffset.dy);
        child.layout(constraints.copyWith(maxWidth: childMaxWidth, minWidth: 0),
            parentUsesSize: true);
        nextLeftOffset =
            Offset(nextLeftOffset.dx, nextLeftOffset.dy + child.size.height);
      }
      height = math.max(nextRightOffset.dy, nextLeftOffset.dy);
      child = parentData.nextSibling;
    }

    size = Size(constraints.maxWidth, height);
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
