import 'dart:convert';

import 'form_field_group.dart';
import 'super_form_field.dart';

class SuperForm {
  SuperForm({this.formName, this.items = const []});

  String? formName;
  late List<FormFieldGroup> items;
  bool _editMode = true;

  SuperForm.fromMap(Map<String, dynamic> map) {
    formName = map['formName'];
    items = List<Map<String, dynamic>>.from(map['items'])
        .map((e) => FormFieldGroup.fromMap(e))
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
}
