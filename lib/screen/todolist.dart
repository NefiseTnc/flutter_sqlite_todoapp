import 'package:flutter/material.dart';
import 'package:flutter_sqlite_todoapp/screen/tododetails.dart';
import 'package:flutter_sqlite_todoapp/utils/dbhelper.dart';

import '../model/todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  DbHelper helper = DbHelper.instance;
  List<Todo> todos = [];
  int count = 0;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            navigateToDetails(Todo("", 3, ""));
          }),
    );
  }

  ListView todoListItems() {
    return ListView.builder(
        itemCount: todos.length,
        itemBuilder: ((context, index) => Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getColor(todos[index].priority ?? 3),
                ),
                title: Text(todos[index].title ?? ''),
                subtitle: Text(todos[index].description ?? ''),
                trailing: Text(todos[index].date ?? ''),
                onTap: () {
                  navigateToDetails(todos[index]);
                },
              ),
            )));
  }

  void navigateToDetails(Todo todo) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: ((context) => TodoDetails(todo: todo))));
    if (result) {
      getData();
    }
  }

  void getData() {
    final todosFuture = helper.getTodos();
    todosFuture.then((result) {
      setState(() {
        todos = result as List<Todo>;
        count = todos.length;
      });
    });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.green;
    }
  }
}
