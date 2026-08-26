class TaskModel {
  final String title;
  final String? description;
  final int userId;
  final int id;
  final bool isCompleted;

  const TaskModel({
    required this.title,
    this.description,
    required this.userId,
    required this.id,
    required this.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'] as String,
      description: json['body'] as String?,
      userId: json['userId'] as int,
      id: json['id'] as int,
      isCompleted: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': description,
      'userId': userId,
      'id': id,
      'completed': isCompleted,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    int? userId,
    int? id,
    bool? isCompleted,
  }) {
    return TaskModel(
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
