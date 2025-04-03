import 'dart:convert';

import 'package:extension/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'super_form_field.dart';
import 'utils.dart';

class ValueType {
  const ValueType._(this.name, this.info);
  final String name;
  final String info;

  static const ValueType text = ValueType._('text', '');
  static const ValueType int = ValueType._('int', '仅限整数');
  static const ValueType number = ValueType._('number', '整数和浮点数');
  static const ValueType email = ValueType._('email', '仅限xx@xx.com形式');
  static const ValueType password = ValueType._('password', '');
  static const ValueType search = ValueType._('search', '');
  static const ValueType date = ValueType._('date', '格式：2024-01-01');

  static ValueType? fromName(String? name) {
    switch (name) {
      case 'text':
        return text;
      case 'int':
        return int;
      case 'number':
        return number;
      case 'email':
        return email;
      case 'password':
        return password;
      case 'search':
        return search;
      case 'date':
        return date;
    }
    return null;
  }
}

class InputField<T> implements SuperFormField<T> {
  InputField(
      {required this.name,
      this.text,
      this.readonly = false,
      this.editMode = true,
      this.defaultValue,
      this.valueType = ValueType.text,
      this.maxLength,
      this.minLength = 0,
      this.minValue,
      this.maxValue,
      this.isRequired = false,
      this.helperText,
      this.showCopyBtn = true,
      this.callback}) {
    if (defaultValue != null) {
      _controller.text = defaultValue.toString();
    }
  }

  InputField.fromMap(Map<String, dynamic> map) {
    defaultValue = map['defaultValue'];
    name = map['name'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    text = map['text'];
    valueType = ValueType.fromName(map['valueType']);
    maxLength = map['maxLength'];
    minLength = map['minLength'] ?? 0;
    minValue = map['minValue'];
    maxValue = map['maxValue'];
    isRequired = map['isRequired'] ?? false;
    helperText = map['helperText'];
    showCopyBtn = map['showCopyBtn'] ?? true;
    //填入初始值
    _controller.text = defaultValue?.toString() ?? '';
  }

  @override
  T? defaultValue;

  @override
  late String name;

  @override
  late bool readonly;

  @override
  late bool editMode;

  @override
  String? text;

  @override
  FieldType? type = FieldType.input;

  @override
  late bool isRequired;

  @override
  String? helperText;

  @override
  set errorText(String? v) {
    _errorText.value = v;
  }

  ValueType? valueType;

  int? maxLength;
  int? minLength;

  num? minValue;
  num? maxValue;

  late bool showCopyBtn;

  //联动回调
  Callback? callback;

  final TextEditingController _controller = TextEditingController();

  @override
  T? get value {
    String? t = _controller.text.supperTrim();
    if (t.isNullOrEmpty) return null;
    if (valueType == ValueType.int) {
      return t.toInt() as T;
    } else if (valueType == ValueType.number) {
      return t.toNum() as T;
    }
    return t as T;
  }

  @override
  set value(dynamic v) {
    _controller.text = v == null ? '' : v.toString();
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
        _errorText.value = '超出最大长度$maxLength';
        return false;
      } else if (minLength != null && t!.length < minLength!) {
        _errorText.value = '小于最低长度$minLength';
        return false;
      }

      //校验输入类型或格式
      if (valueType == ValueType.int) {
        int? tv = t.toInt();
        if (tv == null) {
          if (isRequired && !readonly) {
            _errorText.value = '${isRequired ? '必须填写,' : ''}${valueType!.info}';
            return false;
          }
        } else {
          if (minValue != null && tv < minValue!) {
            _errorText.value = '不能小于$minValue';
            return false;
          } else if (maxValue != null && tv > maxValue!) {
            _errorText.value = '不能大于$maxValue';
            return false;
          }
        }
      } else if (valueType == ValueType.number) {
        num? tv = t.toNum();
        if (tv == null) {
          if (isRequired && !readonly) {
            _errorText.value = '${isRequired ? '必须填写,' : ''}${valueType!.info}';
            return false;
          }
        } else {
          if (minValue != null && tv < minValue!) {
            _errorText.value = '不能小于$minValue';
            return false;
          } else if (maxValue != null && tv > maxValue!) {
            _errorText.value = '不能大于$maxValue';
            return false;
          }
        }
      } else if (valueType == ValueType.email &&
          !RegExp(r'\S+@\S+\.\S+').hasMatch(t!) &&
          !readonly) {
        _errorText.value = '${isRequired ? '必须填写,' : ''}${valueType!.info}';
        return false;
      }
    }
    //没填写又必须填写时
    else if (isRequired && !readonly) {
      _errorText.value = '必须填写';
      return false;
    }

    _errorText.value = null;
    return true;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'type': type?.name,
      'valueType': valueType?.name,
      'defaultValue': defaultValue,
      'readonly': readonly,
      'editMode': editMode,
      'maxLength': maxLength,
      'minLength': minLength,
      'minValue': minValue,
      'maxValue': maxValue,
      'isRequired': isRequired,
      'helperText': helperText,
      'showCopyBtn': showCopyBtn
    };
  }

  @override
  String toString() {
    return json.encode(toMap());
  }

  @override
  SuperFormField clone() {
    return InputField(
        name: name,
        text: text,
        readonly: readonly,
        editMode: editMode,
        defaultValue: defaultValue,
        valueType: valueType,
        minLength: minLength,
        maxLength: maxLength,
        minValue: minValue,
        maxValue: maxValue,
        isRequired: isRequired,
        showCopyBtn: showCopyBtn,
        helperText: helperText);
  }

  final _errorText = Rx<String?>(null);
  final _obscureText = true.obs;

  @override
  Widget toWidget() {
    List<TextInputFormatter> inputFormatters = [];
    if (valueType == ValueType.int) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'(^-|\d+)')));
    } else if (valueType == ValueType.number) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'(^-|\d+|\.)')));
    } else if (valueType == ValueType.date) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'(^\d|\-)')));
    }
    final ThemeData themeData = Theme.of(Get.context!);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Obx(() => TextField(
            controller: _controller,
            readOnly: (readonly || !editMode),
            keyboardType: valueType == ValueType.int
                ? const TextInputType.numberWithOptions(
                    signed: true, decimal: false)
                : valueType == ValueType.number
                    ? const TextInputType.numberWithOptions(
                        signed: true, decimal: true)
                    : valueType == ValueType.email
                        ? TextInputType.emailAddress
                        : TextInputType.text,
            inputFormatters: inputFormatters.isEmpty ? null : inputFormatters,
            maxLength: maxLength,
            obscureText:
                valueType == ValueType.password ? _obscureText.value : false,
            textInputAction: TextInputAction.done,
            onChanged: (String t) {
              _check(t.supperTrim());

              //联动回调
              if (callback != null) {
                callback!(valueType == ValueType.int
                    ? t.supperTrim().toInt()
                    : valueType == ValueType.number
                        ? t.supperTrim().toNum()
                        : t);
              }
            },
            decoration: InputDecoration(
              labelText: text,
              isDense: true,
              helperText: isRequired
                  ? ' * ${helperText ?? ''} ${valueType!.info}'
                  : helperText ?? '',
              errorText: _errorText.value,
              enabledBorder: (readonly || !editMode)
                  ? themeData.inputDecorationTheme.disabledBorder
                  : themeData.inputDecorationTheme.border,
              contentPadding: const EdgeInsets.fromLTRB(
                  15, 14, 15, 10), //当高度不一致时关注theme中的字号
              suffix: valueType == ValueType.password
                  ? InkWell(
                      child: Icon(
                        _obscureText.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _obscureText.value
                            ? Colors.grey
                            : Colors.orangeAccent,
                        size: 20,
                      ),
                      onTap: () async {
                        _obscureText.value = _obscureText.value ? false : true;
                      },
                    )
                  : showCopyBtn
                      ? InkWell(
                          child: const Icon(
                            Icons.copy,
                            color: Colors.orangeAccent,
                            size: 20,
                          ),
                          onTap: () async {
                            Utils.copy('$value');
                          },
                        )
                      : null,
            ),
          )),
    );
  }

  @override
  Widget toFilterWidget() {
    List<TextInputFormatter> inputFormatters = [];
    if (valueType == ValueType.int) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'(^-|\d+)')));
    } else if (valueType == ValueType.number) {
      inputFormatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'(^-|\d+|\.)')));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Obx(() => TextField(
            controller: _controller,
            readOnly: (readonly || !editMode),
            keyboardType: valueType == ValueType.int
                ? const TextInputType.numberWithOptions(
                    signed: true, decimal: false)
                : valueType == ValueType.number
                    ? const TextInputType.numberWithOptions(
                        signed: true, decimal: true)
                    : valueType == ValueType.email
                        ? TextInputType.emailAddress
                        : TextInputType.text,
            inputFormatters: inputFormatters.isEmpty ? null : inputFormatters,
            maxLength: maxLength,
            textInputAction: TextInputAction.search,
            expands: false,
            onChanged: (String t) {
              _check(t.supperTrim());
              //联动回调
              if (callback != null) {
                callback!(valueType == ValueType.int
                    ? t.supperTrim().toInt()
                    : valueType == ValueType.number
                        ? t.supperTrim().toNum()
                        : t);
              }
            },
            decoration: InputDecoration(
              labelText: text,
              helperText: helperText,
              errorText: _errorText.value,
              isDense: true,
              isCollapsed: true,
              contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
              focusedBorder: (readonly || !editMode)
                  ? Get.theme.inputDecorationTheme.focusedBorder?.copyWith(
                      borderSide: BorderSide(
                          color: Get.theme.inputDecorationTheme.disabledBorder
                                  ?.borderSide.color ??
                              Colors.grey))
                  : null,
              suffix: valueType == ValueType.search
                  ? InkWell(
                      child: const Icon(
                        Icons.clear,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      onTap: () async {
                        _controller.text = '';
                      },
                    )
                  : null,
            ),
          )),
    );
  }
}
