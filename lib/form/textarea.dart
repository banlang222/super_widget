import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:extension/extension.dart';
import 'package:get/get.dart';
import 'utils.dart';
import 'super_form_field.dart';

class TextareaField implements SuperFormField<String> {
  TextareaField(
      {required this.name,
      this.text,
      this.readonly = false,
      this.editMode = true,
      this.defaultValue,
      this.maxLength = 500,
      this.minLength = 0,
      this.isRequired = false,
      this.showCopyBtn = true,
      this.helperText});

  TextareaField.fromMap(Map<String, dynamic> map) {
    defaultValue = map['defaultValue'];
    name = map['name'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    text = map['text'];
    _controller.text = defaultValue ?? '';
    maxLength = map['maxLength'] ?? 500;
    minLength = map['minLength'] ?? 0;
    isRequired = map['isRequired'] ?? false;
    showCopyBtn = map['showCopyBtn'] ?? true;
    helperText = map['helperText'];
  }

  @override
  String? defaultValue;

  @override
  late String name;

  @override
  late bool readonly;

  @override
  late bool editMode;

  @override
  String? text;

  @override
  FieldType? type = FieldType.textarea;

  @override
  late bool isRequired;

  @override
  String? helperText;

  int? maxLength;
  int? minLength;

  bool? showCopyBtn;

  final TextEditingController _controller = TextEditingController();

  @override
  String? get value {
    if (readonly) return defaultValue;

    return _controller.text.supperTrim();
  }

  @override
  set value(dynamic v) {
    _controller.text = v;
    if (readonly) defaultValue = v;
  }

  @override
  bool check() {
    return _check(_controller.text.supperTrim());
  }

  bool _check(String? t) {
    //有填写时
    if (!t.isNullOrEmpty) {
      //进行长度校验
      if (maxLength != null && t!.length > maxLength!) {
        _errorText['error'] = '超出最大长度$maxLength';
        return false;
      } else if (minLength != null && t!.length < minLength!) {
        _errorText['error'] = '小于最低长度$minLength';
        return false;
      }
    }
    //没填写又必须填写时
    else if (isRequired) {
      _errorText['error'] = '必须填写';
      return false;
    }
    return true;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'type': type?.name,
      'defaultValue': defaultValue,
      'readonly': readonly,
      'editMode': editMode,
      'maxLength': maxLength,
      'minLength': minLength,
      'isRequired': isRequired,
      'showCopyBtn': showCopyBtn,
      'helperText': helperText
    };
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  @override
  SuperFormField clone() {
    return TextareaField(
        name: name,
        text: text,
        readonly: readonly,
        editMode: editMode,
        defaultValue: defaultValue,
        maxLength: maxLength,
        minLength: minLength,
        isRequired: isRequired,
        showCopyBtn: showCopyBtn,
        helperText: helperText);
  }

  final _errorText = {}.obs;

  @override
  Widget toWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Obx(() => TextField(
            maxLines: 5,
            maxLength: maxLength,
            controller: _controller,
            readOnly: (readonly || !editMode),
            style: TextStyle(
                color: (readonly || !editMode) ? Colors.black54 : Colors.black),
            textInputAction: TextInputAction.newline,
            onChanged: (String t) {
              _check(t.supperTrim());
            },
            decoration: InputDecoration(
              labelText: text,
              helperText: isRequired ? ' * ${helperText ?? ''}' : helperText,
              errorText: _errorText['error'],
              isDense: true,
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: (readonly || !editMode)
                          ? Colors.black12
                          : Colors.yellow[700]!),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              suffix: showCopyBtn!
                  ? InkWell(
                      child: const Icon(
                        Icons.copy,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      onTap: () async {
                        Utils.copy(value!);
                      },
                    )
                  : null,
            ),
          )),
    );
  }

  @override
  Widget toFilterWidget() {
    return Container();
  }
}
