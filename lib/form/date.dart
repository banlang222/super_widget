import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:extension/extension.dart';
import 'super_form_field.dart';
import 'utils.dart';

class DateMode {
  const DateMode._(this.name, this.value, this.text);
  final String name;
  final int value;
  final String text;

  static const DateMode date = DateMode._('date', 0, '日期');
  static const DateMode time = DateMode._('time', 1, '时间');
  static const DateMode dateTime = DateMode._('dateTime', 2, '日期时间');

  static DateMode? fromValue(int? value) {
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
      this.readonly = false,
      this.editMode = true}) {
    // defaultValue ??= DateTime.now();
    // _value.value = defaultValue;
  }

  DateField.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    text = map['text'];
    defaultValue = map['defaultValue'];
    dateMode = DateMode.fromValue(map['dateMode']) ?? DateMode.date;
    helperText = map['helperText'];
    isRequired = map['isRequired'] ?? false;
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
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
  late bool editMode;

  @override
  String? text;

  @override
  FieldType? type = FieldType.date;

  late DateMode dateMode;

  @override
  DateTime? get value {
    return _value.value;
  }

  @override
  set value(dynamic v) {
    DateTime? _v;
    if (v is DateTime) {
      _v = v;
    } else if (v is String) {
      _v = v.toDateTime();
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
        editMode: editMode,
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
      'editMode': editMode,
      'defaultValue': defaultValue,
      'dateMode': dateMode.value,
      'isRequired': isRequired,
      'helperText': helperText
    };
  }

  @override
  Widget toWidget([BuildContext? context]) {
    if (dateMode == DateMode.date) {
      return buildDateWidget(context);
    } else if (dateMode == DateMode.time) {
      return buildTimeWidget(context);
    } else {
      return Column(
        children: [buildDateWidget(), buildTimeWidget()],
      );
    }
  }

  Widget buildDateWidget([BuildContext? context]) {
    return Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Obx(() => InputDecorator(
              decoration: InputDecoration(
                  labelText: '$text（日期）',
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 8, 5, 3),
                  helperText: '${isRequired ? ' * ' : ''}${helperText ?? ''}',
                  errorText: _errorText['error']),
              isFocused: false,
              isEmpty: false,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              GestureDetector(
              onTap: (readonly || !editMode) ? null : () async {
                if (GetPlatform.isDesktop || kIsWeb) {
                  final dates = await showCalendarDatePicker2Dialog(
                      context: context ?? Get.context!,
                      config: CalendarDatePicker2WithActionButtonsConfig(),
                      dialogSize: const Size(400, 400));
                  if (dates != null && dates.isNotEmpty) {
                    _value.value = DateTime(
                        dates.first!.year,
                        dates.first!.month,
                        dates.first!.day,
                        (_value.value ?? DateTime.now()).hour,
                        (_value.value ?? DateTime.now()).minute,
                        (_value.value ?? DateTime.now()).second);
                    _errorText.clear();
                  }
                } else {
                  DatePicker.showDatePicker(Get.context!,
                      initialDateTime: _value.value,
                      locale: DateTimePickerLocale.zh_cn,
                      pickerMode: DateTimePickerMode.date,
                      pickerTheme: DateTimePickerTheme(
                          backgroundColor: context?.theme.cardColor ??
                              DateTimePickerTheme.Default.backgroundColor,
                          confirmTextStyle: context?.textTheme.bodyMedium,
                          itemTextStyle: DateTimePickerTheme
                              .Default.itemTextStyle
                              .copyWith(
                              color: context?.theme.brightness ==
                                  Brightness.dark
                                  ? Colors.white
                                  : Colors.black87)),
                      onConfirm: (DateTime date, List<int> selected) {
                        _value.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            (_value.value ?? DateTime.now()).hour,
                            (_value.value ?? DateTime.now()).minute,
                            (_value.value ?? DateTime.now()).second);
                        _errorText.clear();
                      });
                }
              },
          child: MouseRegion(cursor: (readonly || !editMode) ? MouseCursor.defer : MaterialStateMouseCursor.clickable,
              child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              if(!(readonly || !editMode))
                  Icon(Icons.date_range),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child:
                Obx(() => Text('${Utils.dateFormat(_value.value, true)}')),
              ),
            ],)),),
                    if(!(readonly || !editMode))
                    IconButton(onPressed: (){
                      _value.value = null;
                    }, icon: Icon(Icons.close))

                  ],
                ),
              ),
            ));
  }

  Widget buildTimeWidget([BuildContext? context]) {
    return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Obx(() => InputDecorator(
              decoration: InputDecoration(
                  labelText: '$text（时间）',
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 5, 5, 3),
                  helperText: '${isRequired ? ' * ' : ''}${helperText ?? ''}',
                  errorText: _errorText['error']),
              isFocused: false,
              isEmpty: false,
              child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  GestureDetector(
                  onTap: () async {
        DatePicker.showDatePicker(Get.context!,
        initialDateTime: _value.value ?? DateTime.now(),
        locale: DateTimePickerLocale.zh_cn,
        pickerMode: DateTimePickerMode.time,
        pickerTheme: DateTimePickerTheme(
        backgroundColor:
        context?.theme.cardColor ?? Colors.white),
        onConfirm: (DateTime date, List<int> selected) {
        _value.value = DateTime(
        (_value.value ?? DateTime.now()).year,
        (_value.value ?? DateTime.now()).month,
        (_value.value ?? DateTime.now()).day,
        date.hour,
        date.minute,
        date.second);
        _errorText.clear();
        });
        },
          child:MouseRegion(cursor: MaterialStateMouseCursor.clickable,child: Wrap(crossAxisAlignment: WrapCrossAlignment.center,spacing: 10,children: [
            if(!(readonly || !editMode))
              const Icon(Icons.access_time),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Text(Utils.timeFormat(_value.value)),
            ),
          ],),)),
                    if(!(readonly || !editMode))
                      IconButton(onPressed: (){
                      _value.value = null;
                    }, icon: Icon(Icons.close))

                  ],
                ),
              ),
            ));
  }
}
