import 'package:flutter/material.dart';
import '../model/todo.dart';
import 'login_screen.dart';
import '../database/database_helper.dart';
import 'notes_screen.dart';

class Home extends StatefulWidget {
  final String username;
  const Home({Key? key, required this.username}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        ToDoPage(username: widget.username),
        NotesScreen(username: widget.username),
      ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context)
            .colorScheme
            .onSurface
            .withAlpha((0.6 * 255).toInt()),
        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'ToDos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      title: Text(
        _selectedIndex == 0 ? 'My ToDos' : 'My Notes',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}

class ToDoPage extends StatefulWidget {
  final String username;
  const ToDoPage({Key? key, required this.username}) : super(key: key);

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToDos();
  }

  Future<void> _loadToDos() async {
    final db = DatabaseHelper();
    final todos = await db.getToDos(widget.username);
    setState(() {
      todosList = todos;
      _foundToDo = todos;
    });
  }

  void _handleToDoChange(ToDo todo) async {
    todo.isDone = !todo.isDone;
    await DatabaseHelper().updateToDo(todo);
    _loadToDos();
  }

  void _deleteToDoItem(String id) async {
    await DatabaseHelper().deleteToDo(id, widget.username);
    _loadToDos();
  }

  void _addToDoItem(String toDo) async {
    if (toDo.trim().isEmpty) return;
    final newToDo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: toDo,
      isDone: false,
      username: widget.username,
    );
    await DatabaseHelper().insertToDo(newToDo);
    _loadToDos();
    _todoController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: theme.hintColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your ToDos',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            theme.dividerColor.withAlpha((0.15 * 255).toInt()),
                        width: 1.2),
                  ),
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new todo item',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  elevation: 2,
                ),
                onPressed: () {
                  _addToDoItem(_todoController.text);
                },
                child: const Icon(Icons.add, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: searchBox(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _foundToDo.isEmpty
              ? Center(
                  child: Text('No todos yet. Add your first one!',
                      style: theme.textTheme.bodyMedium),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _foundToDo.length,
                  itemBuilder: (context, index) {
                    final todo = _foundToDo.reversed.toList()[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleToDoChange(todo),
                      child: Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.dividerColor
                                .withAlpha((0.15 * 255).toInt()),
                            width: 1.2,
                          ),
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Checkbox(
                              value: todo.isDone,
                              onChanged: (_) => _handleToDoChange(todo),
                              activeColor: theme.colorScheme.primary,
                            ),
                            title: Text(
                              todo.todoText,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: todo.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isDone ? theme.disabledColor : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                              onPressed: () => _deleteToDoItem(todo.id),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
