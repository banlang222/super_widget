import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:extension/extension.dart';
import 'super_form_field.dart';
import 'utils.dart';
import 'bottom_sheet_container.dart';

class DateMode {
  const DateMode._(this.name, this.value, this.text);
  final String name;
  final int value;
  final String text;

  static const DateMode date = DateMode._('date', 0, '日期');
  static const DateMode time = DateMode._('time', 1, '时间');
  static const DateMode dateTime = DateMode._('dateTime', 2, '日期时间');

  static DateMode? fromValue(int value) {
    switch (value) {
      case 0:
        return date;
      case 1:
        return time;
      case 2:
        return dateTime;
    }
    return null;
  }
}

class DateField implements SuperFormField<DateTime> {
  DateField(
      {required this.name,
      this.text,
      this.defaultValue,
      this.dateMode = DateMode.date,
      this.helperText,
      this.isRequired = false,
      this.readonly = false}) {
    defaultValue ??= DateTime.now();
    _value.value = defaultValue;
  }

  DateField.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    text = map['text'];
    defaultValue =
        (map['defaultValue'] as String).toDateTime() ?? DateTime.now();
    dateMode = DateMode.fromValue(map['dateMode']) ?? DateMode.date;
    helperText = map['helperText'];
    isRequired = map['isRequired'] ?? false;
    readonly = map['readonly'] ?? false;
    _value.value = defaultValue;
  }

  @override
  DateTime? defaultValue;

  @override
  String? helperText;

  @override
  late bool isRequired;

  @override
  late String name;

  @override
  late bool readonly;

  @override
  String? text;

  @override
  FieldType? type = FieldType.date;

  late DateMode dateMode;

  @override
  DateTime get value {
    return _value.value!;
  }

  @override
  set value(dynamic v) {
    DateTime _v;
    if (v is DateTime) {
      _v = v;
    } else if (v is String) {
      _v = v.toDateTime() ?? DateTime.now();
    } else {
      _v = DateTime.now();
    }
    _value.value = _v;
    if (readonly) defaultValue = _v;
  }

  final _value = Rx<DateTime?>(null);

  final _errorText = {}.obs;

  @override
  bool check() {
    return _check();
  }

  bool _check() {
    if (isRequired && _value.value == null) {
      _errorText['error'] = isRequired ? '必须填写' : '';
      return false;
    }
    _errorText.clear();
    return true;
  }

  @override
  SuperFormField clone() {
    return DateField(
        name: name,
        text: text,
        readonly: readonly,
        defaultValue: defaultValue,
        dateMode: dateMode,
        isRequired: isRequired,
        helperText: helperText);
  }

  @override
  Widget toFilterWidget() {
    return toWidget();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'type': type?.name,
      'readonly': readonly,
      'defaultValue': defaultValue,
      'dateMode': dateMode.value,
      'isRequired': isRequired,
      'helperText': helperText
    };
  }

  @override
  Widget toWidget() {
    if (dateMode == DateMode.date) {
      return buildDateWidget();
    } else if (dateMode == DateMode.time) {
      return buildTimeWidget();
    } else {
      return Column(
        children: [buildDateWidget(), buildTimeWidget()],
      );
    }
  }

  Widget buildDateWidget() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Obx(() => InputDecorator(
              decoration: InputDecoration(
                  labelText: '$text（日期）',
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 5, 15, 3),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  helperText: '${isRequired ? ' * ' : ''}${helperText ?? ''}',
                  errorText: _errorText['error']),
              isFocused: false,
              isEmpty: false,
              child: InkWell(
                onTap: () async {
                  Get.bottomSheet(BottomSheetContainer(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              Get.back();
                            },
                            label: const Text('取消'),
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                            )),
                        const Text('请选择日期'),
                        TextButton.icon(
                            onPressed: () {
                              _errorText.clear();
                              //dateKey.currentState.setState(() {});
                              Get.back();
                            },
                            label: const Text('确定'),
                            icon: const Icon(
                              Icons.check,
                              size: 20,
                            ))
                      ],
                    ),
                    content: Container(
                      height: 150,
                      color: Colors.white,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: _value.value,
                        onDateTimeChanged: (DateTime date) {
                          _value.value = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              _value.value!.hour,
                              _value.value!.minute,
                              _value.value!.second);
                          _errorText.clear();
                          //dateKey.currentState.setState(() {});
                        },
                      ),
                    ),
                  ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Obx(
                          () => Text(Utils.dateFormat(_value.value!, true))),
                    ),
                    readonly ? Container() : const Icon(Icons.date_range)
                  ],
                ),
              ),
            )));
  }

  Widget buildTimeWidget() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Obx(() => InputDecorator(
              decoration: InputDecoration(
                  labelText: '$text（时间）',
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 5, 15, 3),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  helperText: '${isRequired ? ' * ' : ''}${helperText ?? ''}',
                  errorText: _errorText['error']),
              isFocused: false,
              isEmpty: false,
              child: InkWell(
                onTap: () async {
                  Get.bottomSheet(BottomSheetContainer(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              Get.back();
                            },
                            label: const Text('取消'),
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                            )),
                        const Text('请选择时间'),
                        TextButton.icon(
                            onPressed: () {
                              _value.value ??= DateTime.now();
                              _errorText.clear();
                              Get.back();
                            },
                            label: const Text('确定'),
                            icon: const Icon(
                              Icons.check,
                              size: 20,
                            ))
                      ],
                    ),
                    content: Container(
                      height: 150,
                      color: Colors.white,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: _value.value ?? DateTime.now(),
                        onDateTimeChanged: (DateTime date) {
                          _value.value = DateTime(
                              _value.value!.year,
                              _value.value!.month,
                              _value.value!.day,
                              date.hour,
                              date.minute,
                              date.second);
                          _errorText.clear();
                          //timeKey.currentState.setState(() {});
                        },
                      ),
                    ),
                  ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(Utils.timeFormat(_value.value!)),
                    ),
                    readonly ? Container() : const Icon(Icons.date_range)
                  ],
                ),
              ),
            )));
  }
}
