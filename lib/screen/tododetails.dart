import 'package:flutter/material.dart';
import 'package:flutter_sqlite_todoapp/model/todo.dart';
import 'package:flutter_sqlite_todoapp/utils/dbhelper.dart';
import 'package:intl/intl.dart';

const List<String> choices = <String>[menuSave, menuDelete, menuBack];

const menuSave = "Save Todo & Back";
const menuDelete = "Delete Todo";
const menuBack = "Back To List";

DbHelper helper = DbHelper.instance;

class TodoDetails extends StatefulWidget {
  final Todo todo;
  const TodoDetails({Key? key, required this.todo}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<TodoDetails> createState() => _TodoDetailsState(todo);
}

class _TodoDetailsState extends State<TodoDetails> {
  Todo todo;

  _TodoDetailsState(this.todo);

  final _priorities = ["High", "Medium", "Low"];
  // ignore: unused_field
  final String _priority = "Low";
  final _formDistance = 5.0;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = todo.title ?? '';
    descController.text = todo.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.caption;
    var title = todo.title == '' ? "New Todo" : todo.title;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title ?? ''),
        actions: [
          PopupMenuButton<String>(
              onSelected: select,
              itemBuilder: ((context) {
                return choices.map((e) {
                  return PopupMenuItem<String>(value: e, child: Text(e));
                }).toList();
              })),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: _formDistance, bottom: _formDistance),
              child: TextField(
                controller: titleController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  label: const Text("Title"),
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: _formDistance, bottom: _formDistance),
              child: TextField(
                controller: descController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  label: const Text("Description"),
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
            ),
            DropdownButton(
                value: _priorities[(todo.priority ?? 2) - 1],
                items: _priorities.map((String str) {
                  return DropdownMenuItem<String>(
                    value: str,
                    child: Text(str),
                  );
                }).toList(),
                onChanged: (str) {
                  updatePriority(str.toString());
                }),
          ],
        ),
      ),
    );
  }

  void updatePriority(String value) {
    int priority = 0;
    switch (value) {
      case "High":
        priority = 1;
        break;
      case "Medium":
        priority = 2;
        break;
      case "Low":
        priority = 3;
        break;
      default:
        priority = 3;
    }
    setState(() {
      todo.priority = priority;
    });
  }

  void select(String value) async {
    switch (value) {
      case menuSave:
        save();
        break;
      case menuDelete:
        delete();
        break;
      case menuBack:
        Navigator.pop(context, true);
        break;
      default:
    }
  }

  void save() {
    todo.title = titleController.text;
    todo.description = descController.text;
    todo.date = DateFormat.yMd().format(DateTime.now());
    if (todo.id != null) {
      helper.updateTodo(todo);
    } else {
      helper.insertTodo(todo);
    }
    Navigator.pop(context, true);
    showAlert(todo.id != null);
  }

  void showAlert(bool isUpdate) {
    AlertDialog alertDialog;
    if (isUpdate) {
      alertDialog = const AlertDialog(
        title: Text("Update Todo"),
        content: Text("The Todo has been updated"),
      );
    } else {
      alertDialog = const AlertDialog(
        title: Text("Insert Todo"),
        content: Text("The Todo has been inserted"),
      );
    }
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future<void> delete() async {
    Navigator.pop(context, true);
    if (todo.id == null) {
      return;
    }
    int result = await helper.deleteTodo(todo.id!);
    if (result != 0) {
      AlertDialog alertDialog = const AlertDialog(
        title: Text("Delete Todo"),
        content: Text("The Todo has been deleted"),
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }
  }
}
