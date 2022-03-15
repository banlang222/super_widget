import 'dart:convert';
import 'package:flutter/material.dart';

class SelectOption {
  SelectOption({required this.text, required this.value});
  SelectOption.fromMap(Map<String, dynamic> map) {
    text = map['text'];
    value = map['value'];
  }

  late String text;
  dynamic value;

  Map<String, dynamic> toMap() {
    return {'text': text, 'value': value};
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  DropdownMenuItem toWidget() {
    return DropdownMenuItem(value: value, child: Text(text));
  }
}
