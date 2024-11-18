import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ContainerSize {
  max(1.0),
  big(.8),
  medium(.5),
  small(.3);

  final double value;
  const ContainerSize(this.value);
}

///expanded content是否占用尽可能大的区域，默认为true, expanded = true时将显示全屏按钮
///header仅控制内容
class BottomSheetContainer extends StatefulWidget {
  const BottomSheetContainer(
      {Key? key,
      this.header,
      required this.content,
      this.footer,
      this.containerSize = ContainerSize.medium,
      this.expanded = true,
      this.radius = 30,
      this.backGroundColor})
      : super(key: key);

  final Widget? header;
  final Widget content;
  final Widget? footer;
  final double radius;

  /// 需要配合isScrollControlled=true 使用
  final ContainerSize containerSize;

  ///
  final bool expanded;
  final Color? backGroundColor;

  @override
  State<StatefulWidget> createState() {
    return _BottomSheetContainerState();
  }
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  bool _fullScreen = false;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    if (widget.containerSize == ContainerSize.max) {
      _fullScreen = true;
    }
    if (widget.expanded) {
      return ClipRRect(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(widget.radius)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: _fullScreen
                ? Get.height - (_fullScreen ? 40 : 0)
                : Get.height * widget.containerSize.value,
          ),
          child: Scaffold(
            backgroundColor: widget.backGroundColor ??
                themeData.bottomSheetTheme.modalBackgroundColor,
            appBar: PreferredSize(
                preferredSize: const Size(double.infinity, 60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.header != null)
                        Expanded(child: widget.header!),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _fullScreen = _fullScreen ? false : true;
                          });
                        },
                        icon: Icon(
                          _fullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                        ),
                      )
                    ],
                  ),
                )),
            body: widget.content,
            bottomNavigationBar: SizedBox(
              height: 80,
              child: widget.footer,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: widget.backGroundColor ??
              themeData.bottomSheetTheme.modalBackgroundColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(widget.radius))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                color: widget.backGroundColor ??
                    themeData.bottomSheetTheme.modalBackgroundColor),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: widget.header,
          ),
          widget.content,
          if (widget.footer != null)
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: widget.footer,
            ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
