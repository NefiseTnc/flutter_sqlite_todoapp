import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sqlite_todoapp/model/todo.dart';
import 'package:flutter_sqlite_todoapp/utils/dbhelper.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _image;
  final picker = ImagePicker();

  Future<void> getImage(ImageSource imageSource) async {
    final image = await ImagePicker().pickImage(source: imageSource);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() {
      _image = imageTemporary;
    });
  }

  @override
  void initState() {
    super.initState();
    titleController.text = todo.title ?? '';
    descController.text = todo.description ?? '';
    _image = todo.imageUrl != null ? File(todo.imageUrl!) : null;
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.caption;
    var title = todo.title == '' ? "New Todo" : "Update Todo";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: [
          ElevatedButton(
              onPressed: () async {
                await getImage(ImageSource.camera);
              },
              child: const Icon(Icons.photo_camera)),
          ElevatedButton(
            onPressed: () async {
              await getImage(ImageSource.gallery);
            },
            child: const Icon(Icons.photo_album),
          ),
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
        child: SingleChildScrollView(
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
              Row(
                children: [
                  const Text('Priorities : '),
                  Expanded(
                    child: DropdownButton(
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
                  ),
                ],
              ),
              if (_image != null)
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(
                                  () {
                                    _image = null;
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.delete,
                                size: 16.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              Padding(
                padding:
                    EdgeInsets.only(top: _formDistance, bottom: _formDistance),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: descController,
                  decoration: InputDecoration(
                    label: const Text("Description"),
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
            ],
          ),
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
    todo.imageUrl = _image != null ? _image!.path : '';
    //todo.date = DateFormat.yMd().format(DateTime.now());
    todo.date = DateFormat.MMMd().format(DateTime.now());
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
