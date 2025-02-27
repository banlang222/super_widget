import 'dart:convert';

import 'package:flutter/material.dart';

import 'checkbox.dart';
import 'date.dart';
import 'field_group.dart';
import 'input.dart';
import 'radiobox.dart';
import 'search_select.dart';
import 'select.dart';
import 'super_form_field.dart';
import 'textarea.dart';
import 'upload.dart';

class FormFieldGroup {
  FormFieldGroup({required this.name, this.items = const []});

  ///当含有自定义字段时，需要传入customFieldCallback，对自定义字段进行构建，不传入则返回一个不能用的CustomField
  FormFieldGroup.fromMap(Map<String, dynamic> map,
      {CustomFieldCallback? customFieldCallback}) {
    name = map['name'];
    items = List<SuperFormField>.from((map['items'] ?? []).map((e) {
      FieldType? fieldType = FieldType.fromName(e['type']);
      switch (fieldType) {
        case FieldType.input:
          return InputField.fromMap(e);
        case FieldType.checkBox:
          return CheckBoxField.fromMap(e);
        case FieldType.radioBox:
          return RadioBoxField.fromMap(e);
        case FieldType.textarea:
          return TextareaField.fromMap(e);
        case FieldType.select:
          return SelectField.fromMap(e);
        case FieldType.searchSelect:
          return SearchSelectField.fromMap(e);
        case FieldType.upload:
          return UploadField.fromMap(e);
        case FieldType.date:
          return DateField.fromMap(e);
        case FieldType.group:
          return FieldGroup.fromMap(e);
        case FieldType.custom:
          if (customFieldCallback != null) {
            return customFieldCallback.call(e) ?? CustomField.fromMap(e);
          } else {
            return CustomField.fromMap(e);
          }
      }
      return null;
    }));
  }

  late String name;
  late List<SuperFormField> items;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((element) => element.toMap()).toList()
    };
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  FormFieldGroup clone() {
    return FormFieldGroup(
        name: name, items: items.map((e) => e.clone()).toList());
  }

  ///正常情况setValue即可，不需要setDefaultValue
  void setDefaultValue(Map<String, dynamic>? data) {
    if (data != null && data.isNotEmpty) {
      for (var element in items) {
        if (data.containsKey(element.name)) {
          element.defaultValue = data[element.name];
        }
      }
    }
  }

  ///setValue时，如果readonly，则defaultValue也会被设置为相同的值
  void setValue(Map<String, dynamic>? data) {
    if (data == null) {
      for (var element in items) {
        element.value = null;
      }
    } else {
      for (var element in items) {
        if (data.containsKey(element.name)) {
          element.value = data[element.name];
        }
      }
    }
  }

  void setEditMode(bool editable) {
    for (var element in items) {
      element.editMode = editable;
    }
  }

  bool check() {
    bool _check = true;
    for (var element in items) {
      if (element.check() == false) {
        _check = false;
      }
    }

    return _check;
  }

  int checkN() {
    int n = 0;
    for (var element in items) {
      if (element.check() == false) {
        n += 1;
      }
    }
    return n;
  }

  Map<String, dynamic> get value {
    Map<String, dynamic> _value = {};
    for (var element in items) {
      _value[element.name] = element.value;
    }
    return _value;
  }

  Widget toWidget([bool showName = true]) {
    if (showName) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: items.map((e) => e.toWidget()).toList(),
            )
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: items.map((e) => e.toWidget()).toList(),
      ),
    );
  }

  ///width: 每个Field的宽度，key为Field.name，不设置宽度的情况下按比例分配，Input占3，其它占1
  Widget toFilterWidget({bool isVertical = false, Map<String, double> width = const {}}) {
    if (isVertical) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((e)=>e.toFilterWidget()).toList(),
      );
    }
    return Row(
      children: items
          .map((e) => width.containsKey(e.name) ? SizedBox(width: width[e.name],child: e.toFilterWidget(),) : Expanded(
        flex: e is InputField ? 3 : 1,
        child: e.toFilterWidget(),
      ))
          .toList(),
    );
  }
}
