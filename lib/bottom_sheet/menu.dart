import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BSMenuItem {
  BSMenuItem(
      {this.leading,
      required this.text,
      required this.onTap,
      this.selected = false});

  final Widget? leading;
  final String text;
  final VoidCallback onTap;
  final bool selected;
}

///bottomSheetMenu按钮点击后自动关闭，无需再处理关闭动作
class BottomSheetMenu extends StatelessWidget {
  const BottomSheetMenu({Key? key, required this.items, this.backgroundColor})
      : super(key: key);
  final List<BSMenuItem> items;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: backgroundColor ?? Colors.white),
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  return ListTile(
                    tileColor: Colors.transparent,
                    leading: items[index].leading,
                    onTap: () {
                      items[index].onTap();
                      Get.back();
                    },
                    title: Center(
                      child: Text(
                        items[index].text,
                        style: TextStyle(
                            color: items[index].selected ? Colors.green : null),
                      ),
                    ),
                    trailing: items[index].selected
                        ? const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : const SizedBox(
                            width: 25,
                          ),
                  );
                },
                separatorBuilder: (context, int index) {
                  return const Divider(
                    height: 1,
                  );
                },
                itemCount: items.length),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            width: double.infinity,
            alignment: Alignment.center,
            child: ListTile(
              tileColor: Colors.transparent,
              title: const Center(
                child: Text('取消'),
              ),
              onTap: () {
                Get.back();
              },
            ),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: backgroundColor ?? Colors.white),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
