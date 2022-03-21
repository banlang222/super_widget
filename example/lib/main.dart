import 'package:flutter/material.dart';
import 'package:super_widget/html_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
