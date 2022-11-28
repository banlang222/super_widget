import 'dart:convert';
import 'package:flutter/material.dart';
import 'super_form_field.dart';
import 'package:get/get.dart';

class CheckBoxField implements SuperFormField<Map<String, bool>> {
  CheckBoxField(
      {this.defaultValue,
      this.options = const [],
      this.readonly = false,
      this.editMode = true,
      required this.name,
      this.text,
      this.isRequired = false,
      this.helperText}) {
    defaultValue ??= <String, bool>{};
    _value.value = Map<String, bool>.from(defaultValue!);
    if (_value.value.isEmpty) {
      for (var element in options) {
        _value.update(element.name, (value) => false);
      }
    }
  }

  CheckBoxField.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    text = map['text'];
    options = List<Map<String, dynamic>>.from(map['options'] ?? [])
        .map((e) => CheckBoxOption.fromMap(e))
        .toList();
    isRequired = map['isRequired'] ?? false;
    defaultValue = map['defaultValue'] ?? <String, bool>{};
    _value.value = Map.from(defaultValue!);
    if (_value.value.isEmpty) {
      for (var element in options) {
        _value.value[element.name] = false;
      }
      _value.refresh();
    }
    helperText = map['helperText'];
  }

  @override
  Map<String, bool>? defaultValue;

  @override
  late String name;

  @override
  late bool readonly;

  @override
  late bool editMode;

  @override
  String? text;

  @override
  FieldType? type = FieldType.checkBox;

  @override
  late bool isRequired;

  @override
  String? helperText;

  late List<CheckBoxOption> options;

  final RxMap<String, bool> _value = <String, bool>{}.obs;

  @override
  Map<String, bool> get value {
    if (readonly) {
      Map<String, bool> _v = Map.from(defaultValue!);
      if (_v.isEmpty) {
        for (var element in options) {
          _v[element.name] = false;
        }
        return _v;
      }
    }
    return _value.value;
  }

  @override
  set value(dynamic v) {
    _value.value = Map.from(v);
    if (readonly) defaultValue = Map.from(v);
  }

  @override
  bool check() {
    return true;
  }

  @override
  SuperFormField clone() {
    return CheckBoxField(
        name: name,
        text: text,
        readonly: readonly,
        editMode: editMode,
        options: options,
        defaultValue: defaultValue,
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
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text!),
          Obx(() => Wrap(
                children: options
                    .map((e) => e.toWidget(_value[e.name] ?? false, (bool v) {
                          _value.update(e.name, (value) => v);
                        }))
                    .toList(),
              ))
        ],
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
    );
  }

  @override
  Widget toFilterWidget() {
    return Container();
  }
}

class CheckBoxOption {
  CheckBoxOption({required this.name, required this.text});

  CheckBoxOption.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    text = map['text'];
  }

  late String name;
  late String text;

  Map<String, dynamic> toMap() {
    return {'name': name, 'text': text};
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  Widget toWidget(bool value, Function callback) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Checkbox(
            value: value,
            onChanged: (bool? checked) {
              print('change to ${checked}');
              callback(checked);
            }),
        Text(text)
      ],
    );
  }
}
