class TaskModel {
  String? id;
  String title;
  bool isDone;

  TaskModel({this.id, required this.title, this.isDone = false});

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? 'Tanpa Judul',
      isDone: map['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }
}
