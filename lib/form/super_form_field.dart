import 'package:flutter/material.dart';

typedef Callback = Function(dynamic value);
typedef CustomFieldCallback = SuperFormField? Function(
    Map<String, dynamic> map);

abstract class SuperFormField<T> {
  late String name;
  String? text;
  FieldType? type;
  late bool readonly;
  late bool editMode;
  T? defaultValue;
  Map<String, dynamic> toMap();
  @override
  String toString();
  SuperFormField clone();
  Widget toWidget();
  Widget toFilterWidget();
  T? get value;
  set value(T? v);
  late bool isRequired;
  bool check();
  String? helperText;
  set errorText(String? v);
}

class FieldType {
  const FieldType._(this.name);
  final String name;

  static const FieldType input = FieldType._('input');
  static const FieldType select = FieldType._('select');
  static const FieldType searchSelect = FieldType._('searchSelect');
  static const FieldType textarea = FieldType._('textarea');
  static const FieldType radioBox = FieldType._('radioBox');
  static const FieldType checkBox = FieldType._('checkBox');
  static const FieldType upload = FieldType._('upload');
  static const FieldType date = FieldType._('date');
  static const FieldType group = FieldType._('group');
  static const FieldType custom = FieldType._('custom');

  static FieldType? fromName(String? name) {
    switch (name) {
      case 'input':
        return input;
      case 'select':
        return select;
      case 'searchSelect':
        return searchSelect;
      case 'textarea':
        return textarea;
      case 'radioBox':
        return radioBox;
      case 'checkBox':
        return checkBox;
      case 'upload':
        return upload;
      case 'date':
        return date;
      case 'group':
        return group;
      case 'custom':
        return custom;
    }
    return null;
  }
}

///自定义类型
///只解析基本数据
class CustomField implements SuperFormField {
  CustomField(
      {required this.name,
      required this.text,
      this.isRequired = false,
      this.readonly = false,
      this.helperText,
      this.defaultValue,
      this.editMode = true});

  @override
  var defaultValue;

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
  FieldType? type = FieldType.custom;

  CustomField.fromMap(Map<String, dynamic> map) {
    defaultValue = map['defaultValue'];
    name = map['name'];
    readonly = map['readonly'] ?? false;
    text = map['text'];
    isRequired = map['isRequired'] ?? false;
    helperText = map['helperText'];
    editMode = map['editMode'] ?? true;
  }
  @override
  CustomField clone() {
    return CustomField(
        name: name,
        text: text,
        isRequired: isRequired,
        readonly: readonly,
        helperText: helperText,
        defaultValue: defaultValue,
        editMode: editMode);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'type': type?.name,
      'isRequired': isRequired,
      'readonly': readonly,
      'helperText': helperText,
      'defaultValue': defaultValue,
      'editMode': editMode
    };
  }

  @override
  late bool editMode;

  @override
  var value;

  @override
  bool check() {
    return true;
  }

  @override
  set errorText(String? v) {}

  @override
  Widget toFilterWidget() {
    return Container();
  }

  @override
  Widget toWidget() {
    return Container();
  }
}
