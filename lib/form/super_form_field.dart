import 'package:flutter/material.dart';

typedef Callback = Function(dynamic value);

abstract class SuperFormField<T> {
  late String name;
  String? text;
  FieldType? type;
  late bool readonly;
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
    }
    return null;
  }
}
