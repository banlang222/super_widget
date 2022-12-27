import 'package:flutter/material.dart';
import 'package:get/get.dart';

///expanded content是否占用尽可能大的区域，默认为true, expanded = true时将显示全屏按钮
///header仅控制内容
class BottomSheetContainer extends StatelessWidget {
  BottomSheetContainer(
      {Key? key,
      this.header,
      required this.content,
      this.footer,
      this.isFullScreen = false,
      this.expanded = true, this.backGroundColor})
      : super(key: key);

  final Widget? header;
  final Widget content;
  final Widget? footer;
  final bool isFullScreen;
  final bool expanded;
  final Color? backGroundColor;

  final RxBool _fullScreen = RxBool(false);

  @override
  Widget build(BuildContext context) {
    _fullScreen.value = isFullScreen;
    return Obx(() => Container(
          constraints: BoxConstraints(
            maxHeight: _fullScreen.value ? Get.height : Get.height * .4,
          ),
          decoration: BoxDecoration(
              color: backGroundColor ?? Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.withAlpha(50),
                          (backGroundColor ?? Colors.white).withAlpha(100),
                          Colors.grey!.withAlpha(1),
                        ],
                        stops: const [
                          0,
                          .3,
                          1,
                        ])),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: header ?? Container(),
                    ),
                    expanded
                        ? IconButton(
                            onPressed: () {
                              _fullScreen.value =
                                  _fullScreen.value ? false : true;
                            },
                            icon: Icon(
                              _fullScreen.value
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
              expanded
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: content,
                      ),
                    )
                  : content,
              Container(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: footer,
              )
            ],
          ),
        ));
  }
}
