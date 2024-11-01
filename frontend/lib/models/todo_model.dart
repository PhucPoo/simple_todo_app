// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// Lớp đại diện của nhiệm vụ (công việc ) cần làm
class TodoModel {
  //Mã của công việc
  int id;
  // Tên công việc
  String title;
  // Trạng thái hoàn thành
  bool completed;
  TodoModel({
    required this.id,
    required this.title,
    required this.completed,
  });

  TodoModel copyWith({
    int? id,
    String? title,
    bool? completed,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      completed: map['completed'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) =>
      TodoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TodoModel(id: $id, title: $title, completed: $completed)';

  @override
  bool operator ==(covariant TodoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.completed == completed;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ completed.hashCode;
}
