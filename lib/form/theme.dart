import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.black)),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: const BorderRadius.all(Radius.circular(8))),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: const BorderRadius.all(Radius.circular(8))),
    disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[700]!),
        borderRadius: const BorderRadius.all(Radius.circular(8))),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(8))),
  ),
);
