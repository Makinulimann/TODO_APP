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
  String? _editingTaskId;

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

  void _addOrUpdateTask() {
    final taskText = _taskController.text.trim();
    if (taskText.isNotEmpty) {
      if (_editingTaskId == null) {
        _database.push().set({'title': taskText, 'isDone': false});
      } else {
        _database.child(_editingTaskId!).update({'title': taskText});
        _editingTaskId = null;
      }
      _taskController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task tidak boleh kosong')),
      );
    }
  }

  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Task'),
          content: const Text('Apakah Anda yakin ingin menghapus task ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                _database.child(taskId).remove();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(Map<String, dynamic> task) {
    setState(() {
      _editingTaskId = task['id'];
      _taskController.text = task['title'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<CustomAuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[50],
                      hintText: _editingTaskId == null
                          ? 'Tambah Tugas Baru...'
                          : 'Edit Tugas',
                      prefixIcon: const Icon(Icons.task,
                          color: Color.fromARGB(255, 52, 53, 53)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addOrUpdateTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _editingTaskId == null ? 'Tambah' : 'Simpan',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada tugas',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          leading: Checkbox(
                            value: task['isDone'] ?? false,
                            onChanged: (bool? value) {
                              _database
                                  .child(task['id'])
                                  .update({'isDone': value ?? false});
                            },
                          ),
                          title: Text(
                            task['title'],
                            style: task['isDone']
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  )
                                : const TextStyle(color: Colors.black),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String choice) {
                              if (choice == 'edit') {
                                _editTask(task);
                              } else if (choice == 'delete') {
                                _deleteTask(task['id']);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            icon: const Icon(Icons.more_vert),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
