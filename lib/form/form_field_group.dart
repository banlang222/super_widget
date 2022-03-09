import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:extension/extension.dart';
import 'field_group.dart';
import 'super_form_field.dart';
import 'input.dart';
import 'textarea.dart';
import 'upload.dart';
import 'date.dart';
import 'select.dart';
import 'search_select.dart';
import 'radiobox.dart';
import 'checkbox.dart';

class FormFieldGroup {
  FormFieldGroup({required this.name, this.items = const []});
  FormFieldGroup.fromMap(Map<String, dynamic> map) {
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

  void setReadonly() {}

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
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        color: Colors.white,
        child: Padding(
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
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: items.map((e) => e.toWidget()).toList(),
        ),
      ),
    );
  }

  Widget toFilterWidget([bool showName = true]) {
    if (showName) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: items
                  .map((e) => Expanded(
                        flex: e is InputField ? 3 : 1,
                        child: e.toFilterWidget(),
                      ))
                  .toList(),
            )
          ],
        ),
      );
    }
    return Row(
      children: items
          .map((e) => Expanded(
                flex: e is InputField ? 3 : 1,
                child: e.toFilterWidget(),
              ))
          .toList(),
    );
  }
}
