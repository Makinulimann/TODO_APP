import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('tasks');
  List<Map<String, dynamic>> _tasks = [];
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    _database.onValue.listen((event) {
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _tasks = data.entries.map((entry) {
            return {
              'id': entry.key,
              'title': entry.value['title'] ?? 'Tanpa Judul',
              'isDone': entry.value['isDone'] ?? false,
            };
          }).toList();
        });
      } else {
        setState(() => _tasks = []);
      }
    });
  }

  void _addTask() {
    if (_taskController.text.trim().isNotEmpty) {
      _database
          .push()
          .set({'title': _taskController.text.trim(), 'isDone': false});
      _taskController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task tidak boleh kosong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<CustomAuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Tambah Tugas Baru',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tasks[index]['title']),
                  trailing: Checkbox(
                    value: _tasks[index]['isDone'] ?? false,
                    onChanged: (bool? value) {
                      _database
                          .child(_tasks[index]['id'])
                          .update({'isDone': value ?? false});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
