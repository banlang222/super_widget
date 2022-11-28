import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extension/extension.dart';
import 'super_form_field.dart';
import 'select_option.dart';
import '../bottom_sheet/container.dart';

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

  final _errorText = {}.obs;

  //联动回调
  Callback? callback;

  late List<SelectOption> options;

  final Rx<T?> _value = Rx<T?>(null);

  @override
  T? get value {
    if (readonly) return defaultValue;

    return _value.value;
  }

  @override
  set value(T? v) {
    _value.value = v;
    if (readonly) {
      defaultValue = v;
    }
  }

  bool get hasValue {
    return options.map((e) => e.value).contains(_value.value);
  }

  @override
  bool check() {
    if (isRequired && !hasValue) {
      _errorText['error'] = '必须选择';
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
      'helperText': helperText
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
        helperText: helperText);
  }

  @override
  Widget toWidget() {
    SelectOption selected;
    try {
      selected = options.firstWhere((element) => element.value == _value.value);
    } catch (e) {
      print('非法值');
    }

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
      child: Container(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Obx(() => InputDecorator(
                decoration: InputDecoration(
                    labelText: '$text',
                    isDense: true,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    errorText: _errorText['error'],
                    helperText: isRequired
                        ? '* ${helperText ?? ''}'
                        : helperText ?? ''),
                isFocused: false,
                isEmpty: !hasValue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 55,
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
                                  ? Colors.black54
                                  : Colors.black)),
                    ),
                    const Icon(Icons.arrow_drop_down_sharp)
                  ],
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
              print('tap1');
              SelectOption? _selected =
                  await Get.bottomSheet<SelectOption>(BottomSearchSelect(
                options: options,
                value: _value.value,
              ));
              if (_selected != null) {
                _value.value = _selected.value;
              }
            },
      child: Obx(() => InputDecorator(
            decoration: InputDecoration(
                labelText: '$text',
                isDense: true,
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                errorText: _errorText['error'],
                helperText:
                    isRequired ? '* ${helperText ?? ''}' : helperText ?? ''),
            isFocused: false,
            isEmpty: !hasValue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: Text(
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
                ),
                const Icon(Icons.arrow_drop_down_sharp)
              ],
            ),
          )),
    );
  }
}

class BottomSearchSelect<T> extends StatefulWidget {
  BottomSearchSelect({Key? key, required this.options, this.value})
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
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow[700]!),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
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
            counter: Container()),
        onChanged: (String word) {
          word.supperTrim();
          if (word.isNotEmpty) {
            word = word.replaceAll(RegExp(r'\s+'), '.*');
            _options = widget.options
                .where((element) => RegExp('$word', caseSensitive: false)
                    .hasMatch(element.text))
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
              selectedTileColor: Colors.grey[100],
              leading:
                  widget.value != null && _options[index].value == widget.value
                      ? const Icon(Icons.check)
                      : null,
              onTap: () {
                Get.back(result: _options[index]);
              },
              hoverColor: Colors.grey[100],
              focusColor: Colors.grey[100],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 1,
            );
          },
          itemCount: _options.length),
      isFullScreen: true,
    );
  }
}
