import 'package:flutter/material.dart';
import 'package:get/get.dart';

void alert(Icon icon, String title, String content, [VoidCallback? callback]) {
  Get.dialog(AlertDialog(
    title: Wrap(
      spacing: 10.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        icon,
        Text(title, style: const TextStyle(color: Colors.black54))
      ],
    ),
    content: Text(content),
    actions: <Widget>[
      TextButton(
        autofocus: true,
        child: const Text(
          '确定',
          style: TextStyle(fontSize: 16.0),
        ),
        onPressed: () {
          if (callback != null) {
            callback();
          } else {
            Get.back(result: true);
          }
        },
      )
    ],
  ));
}

///callback需要自己处理关闭弹窗
void errorAlert(String content, [VoidCallback? callback]) {
  alert(const Icon(Icons.warning), '错误提示', content, callback);
}

///callback需要自己处理关闭弹窗
void successAlert(String content, [VoidCallback? callback]) {
  alert(const Icon(Icons.info), '提示', content, callback);
}

///callback需要自己处理关闭弹窗
void confirm(String title, String content, VoidCallback onConfirm,
    {VoidCallback? onCancel, Widget? otherBtn}) async {
  Get.dialog(AlertDialog(
    title: Wrap(
      spacing: 10.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.info,
          color: Colors.amber,
        ),
        Text(title, style: const TextStyle(color: Colors.black54))
      ],
    ),
    content: Text(content),
    actions: <Widget>[
      TextButton(
        child: const Text(
          '确定',
          style: TextStyle(fontSize: 16.0),
        ),
        onPressed: () {
          onConfirm();
        },
      ),
      if (otherBtn != null) ...[
        const SizedBox(
          width: 20,
        ),
        otherBtn
      ],
      const SizedBox(
        width: 20,
      ),
      TextButton(
        child: const Text(
          '取消',
          style: TextStyle(fontSize: 16.0),
        ),
        onPressed: () {
          if (onCancel != null) {
            onCancel();
          } else {
            Get.back();
          }
        },
      )
    ],
  ));
}
