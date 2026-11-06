class Subtask {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] as String? ?? '',
      taskId: map['taskId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subtask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          taskId == other.taskId &&
          title == other.title &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^ taskId.hashCode ^ title.hashCode ^ isCompleted.hashCode;
}
