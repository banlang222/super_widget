import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetContainer extends StatelessWidget {
  BottomSheetContainer(
      {Key? key,
      this.header,
      required this.content,
      this.footer,
      this.isFullScreen = false})
      : super(key: key);

  final Widget? header;
  final Widget content;
  final Widget? footer;
  final bool isFullScreen;

  final RxBool _fullScreen = RxBool(false);

  @override
  Widget build(BuildContext context) {
    _fullScreen.value = isFullScreen;
    return Obx(() => Container(
          constraints: BoxConstraints(
            maxHeight: _fullScreen.value ? Get.height : Get.height * .4,
          ),
          decoration: const BoxDecoration(
              color: Colors.white,
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
                          Colors.grey[300]!,
                          Colors.white70,
                          Colors.grey[100]!,
                          Colors.white
                        ],
                        stops: const [
                          0,
                          .1,
                          .7,
                          1
                        ])),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    header ?? Container(),
                    IconButton(
                      onPressed: () {
                        _fullScreen.value = _fullScreen.value ? false : true;
                      },
                      icon: Icon(
                        _fullScreen.value
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              content,
              Container(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: footer,
              )
            ],
          ),
        ));
  }
}
