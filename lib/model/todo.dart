// ignore_for_file: unnecessary_this, unnecessary_getters_setters

class Todo {
  int? _id;
  String? _title;
  String? _description;
  String? _date;
  int? _priority;
  String? _imageUrl;

  Todo(this._title, this._priority, this._date,
      [this._description, this._imageUrl]);

  Todo.withId(this._id, this._title, this._priority, this._date,
      [this._description]);

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get title => _title;
  set title(String? title) => _title = title;
  String? get description => _description;
  set description(String? description) => _description = description;
  String? get date => _date;
  set date(String? date) => _date = date;
  int? get priority => _priority;
  set priority(int? priority) => _priority = priority;
  String? get imageUrl => _imageUrl;
  set imageUrl(String? imageUrl) => _imageUrl = imageUrl;

  Todo.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _date = json['date'];
    _priority = json['priority'];
    _imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this._id;
    data['title'] = this._title;
    data['description'] = this._description;
    data['date'] = this._date;
    data['priority'] = this._priority;
    data['imageUrl'] = this._imageUrl;
    return data;
  }
}
