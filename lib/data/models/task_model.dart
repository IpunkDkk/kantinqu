import 'energy_level.dart';
import 'subtask_model.dart';

class Task {
  final String id;
  final String userId;
  final String title;
  final String intention;
  final EnergyLevel energyLevel;
  final DateTime deadline;
  final String targetTime;
  final int durationMinutes;
  final bool gentleReminder;
  final bool isCompleted;
  final DateTime createdAt;
  final List<Subtask> subtasks;

  const Task({
    required this.id,
    this.userId = 'user_default',
    required this.title,
    this.intention = '',
    this.energyLevel = EnergyLevel.medium,
    required this.deadline,
    this.targetTime = '14:00 WIB',
    this.durationMinutes = 45,
    this.gentleReminder = true,
    this.isCompleted = false,
    required this.createdAt,
    this.subtasks = const [],
  });

  int get completedSubtasksCount =>
      subtasks.where((subtask) => subtask.isCompleted).length;

  int get totalSubtasksCount => subtasks.length;

  double get progress {
    if (isCompleted) return 1.0;
    if (subtasks.isEmpty) return 0.0;
    return completedSubtasksCount / totalSubtasksCount;
  }

  String get subtaskProgressText {
    if (subtasks.isEmpty) {
      return isCompleted ? 'Selesai' : '0 Langkah';
    }
    return '$completedSubtasksCount/$totalSubtasksCount Selesai';
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? intention,
    EnergyLevel? energyLevel,
    DateTime? deadline,
    String? targetTime,
    int? durationMinutes,
    bool? gentleReminder,
    bool? isCompleted,
    DateTime? createdAt,
    List<Subtask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      intention: intention ?? this.intention,
      energyLevel: energyLevel ?? this.energyLevel,
      deadline: deadline ?? this.deadline,
      targetTime: targetTime ?? this.targetTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      gentleReminder: gentleReminder ?? this.gentleReminder,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'intention': intention,
      'energyLevel': energyLevel.toJson(),
      'deadline': deadline.toIso8601String(),
      'targetTime': targetTime,
      'durationMinutes': durationMinutes,
      'gentleReminder': gentleReminder,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? 'user_default',
      title: map['title'] as String? ?? '',
      intention: map['intention'] as String? ?? '',
      energyLevel: EnergyLevel.fromString(map['energyLevel'] as String?),
      deadline: DateTime.tryParse(map['deadline'] as String? ?? '') ??
          DateTime.now(),
      targetTime: map['targetTime'] as String? ?? '14:00 WIB',
      durationMinutes: map['durationMinutes'] as int? ?? 45,
      gentleReminder: map['gentleReminder'] as bool? ?? true,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      subtasks: (map['subtasks'] as List<dynamic>?)
              ?.map((s) => Subtask.fromMap(s as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
