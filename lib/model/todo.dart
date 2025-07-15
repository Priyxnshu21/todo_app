class ToDo {
  String id;
  String todoText;
  bool isDone;
  String username;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone ? 1 : 0,
      'username': username,
    };
  }

  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      todoText: map['todoText'],
      isDone: map['isDone'] == 1,
      username: map['username'],
    );
  }

  static List<ToDo> todoList() {
    return [];
  }
}
