import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_widget/form/utils.dart';

import 'select_option.dart';
import 'super_form_field.dart';

///select
class SelectField<T> implements SuperFormField<T> {
  SelectField(
      {required this.name,
      this.text,
      this.readonly = false,
      this.editMode = true,
      this.defaultValue,
      this.options = const [],
      this.isRequired = false,
      this.helperText,
      this.showCopyBtn = false,
      this.callback}) {
    if (defaultValue != null &&
        !options.map((e) => e.value).contains(defaultValue)) {
      defaultValue = null;
    }
    _value.value = defaultValue;
  }

  SelectField.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    text = map['text'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    options = List<Map<String, dynamic>>.from(map['options'])
        .map((e) => SelectOption.fromMap(e))
        .toList();
    defaultValue = map['defaultValue'];
    if (defaultValue != null &&
        !options.map((e) => e.value).contains(defaultValue)) {
      defaultValue = null;
    }
    isRequired = map['isRequired'] ?? false;
    helperText = map['helperText'];
    showCopyBtn = map['showCopyBtn'] ?? true;
    _value.value = defaultValue;
  }

  @override
  late String name;

  @override
  String? text;

  @override
  FieldType? type = FieldType.select;

  @override
  late bool readonly;

  @override
  late bool editMode;

  @override
  T? defaultValue;

  @override
  late bool isRequired;

  @override
  String? helperText;

  final _errorText = Rx<String?>(null);

  //联动回调
  Callback? callback;

  late List<SelectOption> options;

  late bool showCopyBtn;

  final _value = Rx<T?>(null);

  @override
  T? get value {
    return _value.value;
  }

  String? get valueText {
    if (_value.value == null) return null;
    return options.firstWhere((element) => element.value == _value.value).text;
  }

  @override
  set value(dynamic v) {
    if (options.map((e) => e.value).contains(v)) {
      _value.value = v;
    } else {
      _value.value = null;
    }
  }

  @override
  set errorText(String? v) {
    _errorText.value = v;
  }

  bool get hasValue {
    return options.map((e) => e.value).contains(_value.value);
  }

  @override
  bool check() {
    if (isRequired && (!hasValue || _value.value == null)) {
      _errorText.value = '必须选择';
      return false;
    }
    return true;
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
      'options': options.map((element) => element.toMap()).toList(),
      'isRequired': isRequired,
      'helperText': helperText,
      'showCopyBtn': showCopyBtn
    };
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  @override
  SuperFormField clone() {
    return SelectField(
        name: name,
        text: text,
        readonly: readonly,
        editMode: editMode,
        defaultValue: defaultValue,
        options: options,
        isRequired: isRequired,
        helperText: helperText,
        showCopyBtn: showCopyBtn);
  }

  @override
  Widget toWidget() {
    final ThemeData themeData = Theme.of(Get.context!);
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Obx(() => InputDecorator(
            decoration: InputDecoration(
                labelText: '$text',
                isDense: true,
                isCollapsed: true,
                enabledBorder: (readonly || !editMode)
                    ? themeData.inputDecorationTheme.disabledBorder
                    : themeData.inputDecorationTheme.border,
                contentPadding: const EdgeInsets.fromLTRB(
                    15, 14, 15, 10), //当高度不一致时关注theme中的字号
                errorText: _errorText.value,
                helperText:
                    isRequired ? '* ${helperText ?? ''}' : helperText ?? '',
                suffix: showCopyBtn
                    ? InkWell(
                        child: const Icon(
                          Icons.copy,
                          color: Colors.orangeAccent,
                          size: 20,
                        ),
                        onTap: () async {
                          if (value != null) {
                            Utils.copy(options
                                .firstWhere((element) => element.value == value)
                                .text);
                          }
                        },
                      )
                    : null),
            isFocused: false,
            isEmpty: !hasValue,
            child: Container(
              height: 32,
              padding: showCopyBtn
                  ? const EdgeInsets.only(right: 10)
                  : const EdgeInsets.all(0),
              child: (readonly || !editMode)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          child: Text(hasValue
                              ? options
                                  .firstWhere((element) =>
                                      element.value == _value.value)
                                  .text
                              : ''),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                        ),
                      ],
                    )
                  : DropdownButton(
                      isExpanded: true,
                      underline: Container(),
                      value: _value.value,
                      items: options.map((e) => e.toWidget()).toList(),
                      onChanged: (dynamic a) {
                        _errorText.value = null;
                        //更新选择的值
                        _value.value = a;
                        //联动回调
                        if (callback != null) {
                          callback!(a);
                        }
                      },
                    ),
            ),
          )),
    );
  }

  @override
  Widget toFilterWidget() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Obx(() => InputDecorator(
              expands: false,
              decoration: InputDecoration(
                  labelText: '$text',
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(10, 3, 5, 3),
                  errorText: _errorText.value,
                  helperText:
                      isRequired ? '* ${helperText ?? ''}' : helperText ?? ''),
              isFocused: false,
              isEmpty: !hasValue,
              child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                value: _value.value,
                items: options.map((e) => e.toWidget()).toList(),
                onChanged: (readonly || !editMode)
                    ? null
                    : (dynamic a) {
                        _errorText.value = null;
                        _value.value = a;
                        //联动回调
                        if (callback != null) {
                          callback!(a);
                        }
                      },
              ),
            )));
  }
}
