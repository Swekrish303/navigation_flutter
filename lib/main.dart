import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Flutter Navigation'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoItem {
  String title;
  String description;
  bool completed;
  TodoItem({
    required this.title,
    required this.description,
    this.completed = false,
  });

  factory TodoItem.fromJSON(Map<String, dynamic> json) {
    return TodoItem(
        title: json['Title'],
        description: json['Description'],
        completed: json['Completed']);
  }

  static Map<String, dynamic> toJSON(TodoItem todo) => {
        'Title': todo.title,
        'Description': todo.description,
        'Completed': todo.completed,
      };

  static String encode(List<TodoItem> todos) => json.encode(
        todos
            .map<Map<String, dynamic>>((todo) => TodoItem.toJSON(todo))
            .toList(),
      );

  static List<TodoItem> decode(String todos) =>
      (json.decode(todos) as List<dynamic>)
          .map<TodoItem>((item) => TodoItem.fromJSON(item))
          .toList();

  void complete() {
    completed = true;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<TodoItem> list;
  late List<TodoItem> listnew;
  late String? _todoString;
  @override
  void initState() {
    super.initState();
    list = [];
    listnew = [];
    _todoString = '';
    getSharedPrefs();
  }

  void getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _todoString = await prefs.getString('todo_key');
    setState(() {
      list = _todoString == null ? [] : TodoItem.decode(_todoString!);
    });
  }

  void setSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = TodoItem.encode(list);
    prefs.setString('todo_key', encodedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 29, 247, 163),
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: list.length,
          itemBuilder: (context, int i) {
            int revI = list.length - i - 1;
            return Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.8,
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: ((context) => setState(
                          () {
                            list.removeAt(revI);
                            setSharedPrefs();
                          },
                        )),
                    backgroundColor: const Color.fromARGB(255, 254, 2, 2),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: ((context) => setState(
                          () {
                            list[revI].complete();
                            setSharedPrefs();
                          },
                        )),
                    backgroundColor: const Color.fromARGB(255, 6, 248, 135),
                    foregroundColor: Colors.white,
                    icon: Icons.check_box_outlined,
                    label: 'Complete',
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  list[revI].title,
                  style: TextStyle(
                      color: list[revI].completed
                          ? const Color.fromARGB(255, 29, 247, 163)
                          : Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisplayItem(todo: list[revI])),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 29, 247, 163),
        child: const Icon(Icons.add),
        onPressed: () async {
          listnew = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Additem()),
          );
          setState(() {
            list.addAll(listnew);
            setSharedPrefs();
          });
        },
      ),
    );
  }
}

class DisplayItem extends StatelessWidget {
  const DisplayItem({super.key, required this.todo});

  final TodoItem todo;
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(todo.title),
        backgroundColor: const Color.fromARGB(255, 9, 215, 230),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              todo.description,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 9, 215, 230),
        child: const Icon(Icons.home),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ));
  }
}

class Additem extends StatefulWidget {
  const Additem({Key? key}) : super(key: key);

  @override
  State<Additem> createState() => _AdditemState();
}

class _AdditemState extends State<Additem> {
  final List<TodoItem> _todoList = [];

  final _formKey = GlobalKey<FormState>();
  final _myController = TextEditingController();
  final _myController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Items'),
        backgroundColor: const Color.fromARGB(255, 9, 215, 230),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            TextFormField(
              controller: _myController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _myController2,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                  setState(() {
                    TodoItem item = TodoItem(
                        title: _myController.text,
                        description: _myController2.text);
                    _todoList.add(item);
                  });
                }
                _myController.clear();
                _myController2.clear();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 9, 215, 230),
        child: const Icon(Icons.home),
        onPressed: () {
          Navigator.pop(context, _todoList);
        },
      ),
    ));
  }
}
