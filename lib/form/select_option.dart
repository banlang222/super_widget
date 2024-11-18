import 'dart:convert';
import 'package:flutter/material.dart';

class SelectOption {
  SelectOption({required this.text, required this.value, this.group = 0});
  SelectOption.fromMap(Map<String, dynamic> map) {
    text = map['text'];
    value = map['value'];
    group = map['group'] ?? 0;
  }

  late String text;
  dynamic value;
  dynamic group;

  Map<String, dynamic> toMap() {
    return {'text': text, 'value': value, 'group': group};
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  DropdownMenuItem toWidget() {
    return DropdownMenuItem(value: value, child: Text(text));
  }
}
