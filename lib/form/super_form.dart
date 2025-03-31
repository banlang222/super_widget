import 'dart:convert';
import 'package:flutter/material.dart';
import 'form_field_group.dart';
import 'super_form_field.dart';

class SuperForm {
  SuperForm({this.formName, this.items = const []});

  String? formName;
  late List<FormFieldGroup> items;
  bool _editMode = true;

  ///当含有自定义字段时，需要传入customFieldCallback，对自定义字段进行构建
  SuperForm.fromMap(Map<String, dynamic> map,
      {CustomFieldCallback? customFieldCallback}) {
    formName = map['formName'];
    items = List<Map<String, dynamic>>.from(map['items'])
        .map((e) =>
            FormFieldGroup.fromMap(e, customFieldCallback: customFieldCallback))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'formName': formName,
      'items': items.map((e) => e.toMap()).toList()
    };
  }

  SuperForm clone() {
    return SuperForm(
        formName: formName, items: items.map((e) => e.clone()).toList());
  }

  FormFieldGroup? findGroup(String name) {
    var groups = items.where((element) => element.name == name);
    if (groups.isNotEmpty) {
      return groups.first;
    }
    return null;
  }

  /// 查找field
  SuperFormField? find(String name) {
    var _field;
    for (var group in items) {
      for (var field in group.items) {
        if (field.name == name) {
          _field = field;
          break;
        }
      }
      if (_field != null) {
        break;
      }
    }
    return _field;
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> get value {
    Map<String, dynamic> _value = {};
    for (var element in items) {
      _value.addAll(element.value);
    }
    return _value;
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

  bool get editMode {
    return _editMode;
  }

  set editMode(bool editable) {
    _editMode = editable;
    for (var item in items) {
      item.setEditMode(_editMode);
    }
  }

  Widget toWidget([bool showGroupTitle = true]) {
    return Column(
      children: items.map((e) => e.toWidget(showGroupTitle)).toList(),
    );
  }
}
