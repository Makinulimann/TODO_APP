import 'package:firebase_database/firebase_database.dart';
import '../models/task_model.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('tasks');

  // Menambah Task Baru
  Future<void> addTask(TaskModel task) async {
    await _database.push().set(task.toMap());
  }

  // Mengupdate Task
  Future<void> updateTask(TaskModel task) async {
    if (task.id != null) {
      await _database.child(task.id!).update(task.toMap());
    }
  }

  // Menghapus Task
  Future<void> deleteTask(String taskId) async {
    await _database.child(taskId).remove();
  }

  // Mendapatkan Semua Task
  Stream<List<TaskModel>> getTasks() {
    return _database.onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        return data.entries.map((entry) {
          return TaskModel.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
            entry.key,
          );
        }).toList();
      }
      return [];
    });
  }

  // Mendapatkan Task Berdasarkan ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final snapshot = await _database.child(taskId).get();
    if (snapshot.exists) {
      return TaskModel.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map), taskId);
    }
    return null;
  }
}
