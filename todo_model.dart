import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class Todo {
  String title;
  String place;
  DateTime date;
  TimeOfDay time;
  bool isDone;
  Priority priority;

  Todo({
    required this.title,
    required this.place,
    required this.date,
    required this.time,
    this.isDone = false,
    this.priority = Priority.medium,
  });
}
