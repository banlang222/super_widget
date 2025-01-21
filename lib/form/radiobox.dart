import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'super_form_field.dart';

class RadioBoxField<T> implements SuperFormField<T> {
  RadioBoxField(
      {this.defaultValue,
      this.options = const [],
      this.text,
      this.readonly = false,
      this.editMode = true,
      required this.name,
      this.isRequired = false,
      this.helperText}) {
    _value.value = defaultValue!;
  }

  RadioBoxField.fromMap(Map<String, dynamic> map) {
    defaultValue = map['defaultValue'] ?? <String, bool>{};
    name = map['name'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    text = map['text'];
    options = List<Map<String, dynamic>>.from(map['options'] ?? [])
        .map((e) => RadioOption.fromMap(e))
        .toList();
    isRequired = map['isRequired'] ?? false;
    helperText = map['helperText'];
    _value.value = defaultValue!;
  }

  //只有一个值
  @override
  T? defaultValue;

  @override
  late String name;

  @override
  late bool readonly;

  @override
  late bool editMode;

  @override
  String? text;

  @override
  FieldType? type = FieldType.radioBox;

  @override
  late bool isRequired;

  @override
  String? helperText;

  late List<RadioOption> options;

  late Rx<T?> _value = Rx(null);

  @override
  T? get value {
    return _value.value;
  }

  @override
  set value(dynamic v) {
    _value.value = v;
  }

  @override
  set errorText(String? v) {}

  @override
  bool check() {
    return true;
  }

  @override
  SuperFormField clone() {
    return RadioBoxField(
        name: name,
        readonly: readonly,
        editMode: editMode,
        text: text,
        options: options,
        defaultValue: defaultValue,
        isRequired: isRequired,
        helperText: helperText);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'type': type?.name,
      'readonly': readonly,
      'editMode': editMode,
      'options': options.map((e) => e.toMap()).toList(),
      'defaultValue': defaultValue,
      'isRequired': isRequired,
      'helperText': helperText
    };
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  @override
  Widget toWidget() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: '$text',
        isDense: true,
        isCollapsed: true,
        contentPadding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      ),
      isEmpty: false,
      child: Obx(() => Wrap(
            children: options
                .map((e) => e.toWidget(_value.value, (T v) {
                      _value.value = v;
                    }))
                .toList(),
          )),
    );
  }

  @override
  Widget toFilterWidget() {
    return Container();
  }
}

class RadioOption<T> {
  RadioOption({required this.value, required this.text});

  RadioOption.fromMap(Map<String, dynamic> map) {
    value = map['value'];
    text = map['text'];
  }

  late T value;
  late String text;

  Map<String, dynamic> toMap() {
    return {'value': value, 'text': text};
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  Widget toWidget(T? groupValue, Function callback) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Radio(
            value: value,
            groupValue: groupValue,
            onChanged: (val) {
              callback(val);
            }),
        Text(text)
      ],
    );
  }
}
