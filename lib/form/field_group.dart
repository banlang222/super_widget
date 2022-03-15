import 'package:flutter/material.dart';
import 'super_form_field.dart';
import 'input.dart';
import 'textarea.dart';
import 'upload.dart';
import 'date.dart';
import 'select.dart';
import 'search_select.dart';
import 'radiobox.dart';
import 'checkbox.dart';

class FieldGroup<T> extends SuperFormField<T> {
  FieldGroup({required this.name, this.text, this.items = const []});

  FieldGroup.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    text = map['text'];
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
          break;
      }
      return null;
    }));
  }

  @override
  late String name;

  @override
  String? text;

  @override
  FieldType? type = FieldType.group;

  late List<SuperFormField> items;

  @override
  T? get value {
    Map<String, dynamic> _value = {};
    for (var element in items) {
      _value[element.name] = element.value;
    }
    return _value as T;
  }

  @override
  set value(T? data) {
    if (data is Map) {
      for (var element in items) {
        if (data.containsKey(element.name)) {
          element.value = data[element.name];
        }
      }
    }
  }

  @override
  bool check() {
    bool _check = true;
    for (var element in items) {
      if (element.check() == false) {
        _check = false;
      }
    }

    return _check;
  }

  @override
  SuperFormField clone() {
    return FieldGroup(
        name: name, text: text, items: items.map((e) => e.clone()).toList());
  }

  @override
  Widget toFilterWidget() {
    return toWidget();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'items': items.map((element) => element.toMap()).toList()
    };
  }

  @override
  Widget toWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 1, bottom: 1),
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(text ?? name)),
          SizedBox(
            width: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((e) => e.toFilterWidget()).toList(),
            ),
          )
        ],
      ),
    );
  }
}
