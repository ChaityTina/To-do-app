import 'package:flutter/material.dart';

class Todo {
  String title;
  String place;
  DateTime date;
  TimeOfDay time;
  bool isDone;

  Todo({
    required this.title,
    required this.place,
    required this.date,
    required this.time,
    this.isDone = false,
  });
}
