import 'package:flutter/material.dart';
import 'package:flutter_sqlite_todoapp/screen/todolist.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: TodoList(),
    );
  }
}
