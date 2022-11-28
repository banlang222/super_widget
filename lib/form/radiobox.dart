import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'super_form_field.dart';

class RadioBoxField implements SuperFormField<Map<String, bool>> {
  RadioBoxField(
      {this.defaultValue,
      this.options = const [],
      this.text,
      this.readonly = false,
      this.editMode = true,
      required this.name,
      this.isRequired = false,
      this.helperText}) {
    defaultValue ??= <String, bool>{};
    _value.value = Map<String, bool>.from(defaultValue!);
    if (_value.isEmpty) {
      for (var element in options) {
        _value.update(element.name, (value) => false);
      }
    }
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
  FieldType? type = FieldType.radioBox;

  @override
  late bool isRequired;

  @override
  String? helperText;

  late List<RadioOption> options;

  final _value = <String, bool>{}.obs;

  @override
  Map<String, bool>? get value {
    if (readonly) return defaultValue;

    return _value.value;
  }

  @override
  set value(Map<String, bool>? v) {
    if (v != null) {
      _value.value = v;
      _value.refresh();
    }
  }

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
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text ?? ''),
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

class RadioOption {
  RadioOption({this.group, required this.name, required this.text});

  RadioOption.fromMap(Map<String, dynamic> map) {
    group = map['group'];
    name = map['name'];
    text = map['text'];
  }

  late String name;
  late String text;
  String? group;

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
        Radio(
            value: value,
            groupValue: group,
            onChanged: (Object? ob) {
              callback(ob);
            }),
        Text(text)
      ],
    );
  }
}
