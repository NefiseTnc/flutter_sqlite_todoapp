import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/todo.dart';

class DbHelper {
  String tblTodo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";
  String colImageUrl = "imageUrl";

  static final DbHelper instance = DbHelper._init();
  DbHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initializeDb('todos.db');

    return _database!;
  }

  Future<Database> initializeDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    var dbTodos = openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodos;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,"
        "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT , $colImageUrl TEXT"
        ")");
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await instance.database;
    var result = await db.insert(tblTodo, todo.toJson());
    return result;
  }

  Future<List> getTodos() async {
    List<Todo> todoList = [];
    final db = await instance.database;

    var result =
        await db.rawQuery("SELECT * FROM $tblTodo ORDER BY $colDate ASC");
    for (var element in result) {
      todoList.add(Todo.fromJson(element));
    }
    return todoList;
  }

  Future<int?> getCount() async {
    final db = await instance.database;

    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tblTodo"));

    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await instance.database;

    var result = await db.update(tblTodo, todo.toJson(),
        where: "$colId = ?", whereArgs: [todo.id]);
    return result;
  }

  Future<int> deleteTodo(int id) async {
    final db = await instance.database;
    var result = await db.delete(tblTodo, where: "$colId = ?", whereArgs: [id]);
    return result;
  }
}
