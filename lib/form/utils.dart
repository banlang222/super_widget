import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:extension/extension.dart';

class Utils {
  static void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    //BotToast.showText(text: '复制成功');
    Get.snackbar('提示', '复制成功',
        backgroundColor: Colors.black45,
        colorText: Colors.white,
        duration: Duration(milliseconds: 800),
        animationDuration: Duration(milliseconds: 500));
  }

  ///日期显示为yymmdd格式，isFullYear时yyyymmdd格式
  static String dateFormat(DateTime dateTime, [isFullYear = false]) {
    print('dateTime=$dateTime');
    if (dateTime == null) return '';
    return '${isFullYear ? dateTime.year : dateTime.year.toString().substring(2)}.${dateTime.month.toTwoDigits}.${dateTime.day.toTwoDigits}';
  }

  static String timeFormat(DateTime dateTime) {
    if(dateTime == null) return '';
    return '${dateTime.hour.toTwoDigits}:${dateTime.minute.toTwoDigits}:${dateTime.second.toTwoDigits}';
  }
}
