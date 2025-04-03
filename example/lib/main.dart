import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_widget/form/checkbox.dart';
import 'package:super_widget/form/date.dart';
import 'package:super_widget/form/input.dart';
import 'package:super_widget/form/radiobox.dart';
import 'package:super_widget/form/search_select.dart';
import 'package:super_widget/form/select.dart';
import 'package:super_widget/form/select_option.dart';
import 'package:super_widget/html_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          //默认为enable
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          //readonly或非editMode时为disable
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: InputField(name: 'aa', text: '填空').toWidget()),
              Expanded(child: DateField(name: 'bb', text: '日期').toWidget()),
              Expanded(
                  child: RadioBoxField(
                          name: 'cc',
                          text: 'cc',
                          options: [RadioOption(value: 'cc', text: '选择')])
                      .toWidget()),
              Expanded(
                  child: SelectField(
                          name: 'dd',
                          text: '选择',
                          options: [SelectOption(text: 'aaa', value: 'aaa')])
                      .toWidget()),
              Expanded(
                  child: SearchSelectField(
                          name: 'eee',
                          text: '搜索选择',
                          options: [SelectOption(text: 'aaa', value: 'aaa')])
                      .toWidget()),
              Expanded(
                  child: CheckBoxField(
                name: 'fff',
                text: '复选',
                options: [CheckBoxOption(name: 'aaa', text: 'aaaa')],
              ).toWidget())
            ],
          ),
          HtmlTable(
            children: [
              TR(children: [
                TD(
                  text: '1',
                  colSpan: 2,
                ),
                TD(
                  text: '3',
                ),
              ]),
              TR(children: [
                TD(
                  text: '4',
                  rowSpan: 2,
                ),
                TD(
                  text: '5',
                ),
                TD(
                  text: '6',
                ),
              ]),
              TR(children: [
                TD(
                  text: '8',
                ),
                TD(
                  text: '9',
                ),
              ]),
            ],
          ),
          HtmlTable(
            html: '''
          <table>
          <tr><td colspan="2">1</td><td>3</td></tr>
          <tr><td rowspan="2">4</td><td>5</td><td>6</td></tr>
          <tr><td>8</td><td>9</td></tr>
          </table>
          ''',
          )
        ],
      ),
    );
  }
}
