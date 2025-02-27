import 'dart:convert';

import 'package:extension/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_widget/form/utils.dart';

import '../bottom_sheet/container.dart';
import 'select_option.dart';
import 'super_form_field.dart';

class SearchSelectField<T> implements SuperFormField<T> {
  SearchSelectField(
      {required this.name,
      this.text,
      this.readonly = false,
      this.editMode = true,
      this.defaultValue,
      this.options = const [],
      this.isRequired = false,
      this.helperText,
      this.showCopyBtn = false,
      this.callback}) {
    if (defaultValue != null &&
        !options.map((e) => e.value).contains(defaultValue)) {
      defaultValue = null;
    }
    _value.value = defaultValue;
  }

  SearchSelectField.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    text = map['text'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    options = List<Map<String, dynamic>>.from(map['options'])
        .map((e) => SelectOption.fromMap(e))
        .toList();
    defaultValue = map['defaultValue'];
    if (defaultValue != null &&
        !options.map((e) => e.value).contains(defaultValue)) {
      defaultValue = null;
    }
    isRequired = map['isRequired'] ?? false;
    helperText = map['helperText'];
    showCopyBtn = map['showCopyBtn'] ?? true;

    _value.value = defaultValue;
  }

  @override
  late String name;

  @override
  String? text;

  @override
  FieldType? type = FieldType.searchSelect;

  @override
  late bool readonly;

  @override
  late bool editMode;

  @override
  T? defaultValue;

  @override
  late bool isRequired;

  @override
  String? helperText;

  late bool showCopyBtn;

  final _errorText = Rx<String?>(null);

  //联动回调
  Callback? callback;

  late List<SelectOption> options;

  ///group为null时不筛选
  dynamic group;

  final Rx<T?> _value = Rx<T?>(null);

  @override
  T? get value {
    return _value.value;
  }

  @override
  set value(T? v) {
    _value.value = v;
  }

  @override
  set errorText(String? v) {
    _errorText.value = v;
  }

  bool get hasValue {
    if (group != null) {
      return options
          .where((element) => element.group == group)
          .map((e) => e.value)
          .contains(_value.value);
    }
    return options.map((e) => e.value).contains(_value.value);
  }

  @override
  bool check() {
    if (isRequired && (!hasValue || _value.value == null)) {
      _errorText.value = '必须选择';
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
      'readonly': readonly,
      'editMode': editMode,
      'defaultValue': defaultValue,
      'options': options.map((element) => element.toMap()).toList(),
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
    return SearchSelectField(
        name: name,
        text: text,
        readonly: readonly,
        editMode: editMode,
        defaultValue: defaultValue,
        options: options,
        isRequired: isRequired,
        helperText: helperText,
        showCopyBtn: showCopyBtn);
  }

  @override
  Widget toWidget() {
    ThemeData themeData = Theme.of(Get.context!);
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Obx(() => InputDecorator(
          decoration: InputDecoration(
              labelText: '$text',
              isDense: true,
              isCollapsed: true,
              contentPadding: const EdgeInsets.fromLTRB(15, 4, 15, 0),
              errorText: _errorText.value,
              helperText:
                  isRequired ? '* ${helperText ?? ''}' : helperText ?? '',
              suffix: showCopyBtn
                  ? InkWell(
                      child: const Icon(
                        Icons.copy,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      onTap: () async {
                        if (value != null) {
                          Utils.copy(options
                              .firstWhere((element) => element.value == value)
                              .text);
                        }
                      },
                    )
                  : null),
          isFocused: false,
          isEmpty: !hasValue,
          child: InkWell(
            onTap: (readonly || !editMode)
                ? null
                : () async {
                    SelectOption? _selected =
                        await Get.bottomSheet<SelectOption>(BottomSearchSelect(
                      options: group != null
                          ? options
                              .where((element) => element.group == group)
                              .toList()
                          : options,
                      value: _value.value,
                    ));
                    if (_selected != null) {
                      _value.value = _selected.value;
                    }
                  },
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        child: Text(
                            hasValue
                                ? options
                                    .firstWhere((element) =>
                                        element.value == _value.value)
                                    .text
                                : '',
                            style: TextStyle(
                                color: (readonly || !editMode)
                                    ? themeData.disabledColor
                                    : null)),
                      ),
                      Icon(
                        Icons.arrow_drop_down_sharp,
                        color: (readonly || !editMode)
                            ? themeData.disabledColor
                            : null,
                      ),
                    ],
                  )),
                  if (showCopyBtn)
                    const SizedBox(
                      width: 10,
                    )
                ],
              ),
            ),
          ))),
    );
  }

  @override
  Widget toFilterWidget() {
    return GestureDetector(
      onTap: (readonly || !editMode)
          ? null
          : () async {
              SelectOption? _selected =
                  await Get.bottomSheet<SelectOption>(BottomSearchSelect(
                options: options,
                value: _value.value,
              ));
              if (_selected != null) {
                _value.value = _selected.value;
              }
            },
      child: Obx(() => InputDecorator(expands: false,
            decoration: InputDecoration(
                labelText: '$text',
                isDense: true,
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                errorText: _errorText.value,
                helperText:
                    isRequired ? '* ${helperText ?? ''}' : helperText ?? ''),
            isFocused: false,
            isEmpty: !hasValue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasValue
                      ? options
                          .firstWhere(
                              (element) => element.value == _value.value)
                          .text
                      : '',
                  style: TextStyle(
                      color: (readonly || !editMode)
                          ? Colors.black54
                          : Colors.black),
                ),
                const Icon(Icons.arrow_drop_down_sharp)
              ],
            ),
          )),
    );
  }
}

class BottomSearchSelect<T> extends StatefulWidget {
  const BottomSearchSelect({Key? key, required this.options, this.value})
      : super(key: key);
  final List<SelectOption> options;
  final T? value;
  @override
  State<StatefulWidget> createState() {
    return _BottomSearchSelectState();
  }
}

class _BottomSearchSelectState extends State<BottomSearchSelect> {
  List<SelectOption> _options = [];
  @override
  void initState() {
    _options = List.from(widget.options);
    super.initState();
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      header: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.text,
        maxLength: 50,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
            labelText: '关键词',
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.text = '';
                if (_options.length != widget.options.length) {
                  _options = List.from(widget.options);
                  setState(() {});
                }
              },
            ),
            counter: const SizedBox()),
        onChanged: (String word) {
          word.supperTrim();
          if (word.isNotEmpty) {
            word = word.replaceAll(RegExp(r'\s+'), '.*');
            _options = widget.options
                .where((element) =>
                    RegExp(word, caseSensitive: false).hasMatch(element.text))
                .toList();
            setState(() {});
          } else if (_options.length != widget.options.length) {
            _options = List.from(widget.options);
            setState(() {});
          }
        },
      ),
      content: ListView.separated(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_options[index].text),
              selected:
                  widget.value != null && _options[index].value == widget.value,
              leading:
                  widget.value != null && _options[index].value == widget.value
                      ? const Icon(Icons.check)
                      : null,
              onTap: () {
                Get.back(result: _options[index]);
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 1,
            );
          },
          itemCount: _options.length),
      containerSize: ContainerSize.big,
    );
  }
}
