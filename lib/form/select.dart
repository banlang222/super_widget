import 'dart:convert';
import 'package:flutter/material.dart';
import 'super_form_field.dart';
import 'select_option.dart';
import 'package:get/get.dart';

///select
class SelectField<T> implements SuperFormField<T> {
  SelectField(
      {required this.name,
      this.text,
      this.readonly = false,
      this.defaultValue,
      this.options = const [],
      this.isRequired = false,
      this.helperText,
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
  T? defaultValue;

  @override
  late bool isRequired;

  @override
  String? helperText;

  final _errorText = {}.obs;

  //联动回调
  Callback? callback;

  late List<SelectOption> options;

  final _value = Rx<T?>(null);

  @override
  T? get value {
    if (readonly) return defaultValue;

    return _value.value;
  }

  @override
  set value(dynamic v) {
    _value.value = v;
    if (readonly) {
      defaultValue = v;
    }
  }

  bool get hasValue {
    return options.map((e) => e.value).contains(_value.value);
  }

  @override
  bool check() {
    if (isRequired && !hasValue) {
      _errorText['error'] = '必须选择';
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
      'defaultValue': defaultValue,
      'options': options.map((element) => element.toMap()).toList(),
      'isRequired': isRequired,
      'helperText': helperText
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
        defaultValue: defaultValue,
        options: options,
        isRequired: isRequired,
        helperText: helperText);
  }

  @override
  Widget toWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Obx(() => InputDecorator(
            decoration: InputDecoration(
                labelText: '$text',
                isDense: true,
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                errorText: _errorText['error'],
                helperText:
                    isRequired ? '* ${helperText ?? ''}' : helperText ?? ''),
            isFocused: false,
            isEmpty: !hasValue,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                value: _value.value,
                items: options.map((e) => e.toWidget()).toList(),
                onChanged: readonly
                    ? null
                    : (dynamic a) {
                        if (a != null) {
                          _errorText.clear();
                          //更新选择的值
                          _value.value = a;
                          //联动回调
                          if (callback != null) {
                            callback!(a);
                          }
                        }
                      },
                focusColor: Colors.white,
              ),
            ),
          )),
    );
  }

  @override
  Widget toFilterWidget() {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Obx(() => InputDecorator(
              decoration: InputDecoration(
                  labelText: '$text',
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  errorText: _errorText['error'],
                  helperText:
                      isRequired ? '* ${helperText ?? ''}' : helperText ?? ''),
              isFocused: false,
              isEmpty: !hasValue,
              child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                value: _value.value,
                items: options.map((e) => e.toWidget()).toList(),
                onChanged: readonly
                    ? null
                    : (dynamic a) {
                        if (a != null) {
                          _errorText.clear();
                          _value.value = a;
                          //联动回调
                          if (callback != null) {
                            callback!(a);
                          }
                        }
                      },
              ),
            )));
  }
}
