class GamificationModel {
  final String id;
  final String userId;
  final int currentStreak;
  final int highestStreak;
  final int plantLevel;
  final String plantName;
  final int currentXp;
  final int xpNeededForNextLevel;
  final DateTime? lastWateredDate;
  final DateTime lastActiveDate;
  final int completedTasksCount;

  const GamificationModel({
    required this.id,
    required this.userId,
    this.currentStreak = 7,
    this.highestStreak = 14,
    this.plantLevel = 3,
    this.plantName = 'Monstera Sejuk',
    this.currentXp = 120,
    this.xpNeededForNextLevel = 240,
    this.lastWateredDate,
    required this.lastActiveDate,
    this.completedTasksCount = 8,
  });

  double get growthProgress {
    if (xpNeededForNextLevel <= 0) return 1.0;
    final progress = currentXp / xpNeededForNextLevel;
    return progress.clamp(0.0, 1.0);
  }

  bool get isWateredToday {
    if (lastWateredDate == null) return false;
    final now = DateTime.now();
    return lastWateredDate!.year == now.year &&
        lastWateredDate!.month == now.month &&
        lastWateredDate!.day == now.day;
  }

  static String getPlantTitleForLevel(int level) {
    switch (level) {
      case 1:
        return 'Tunas Kecil';
      case 2:
        return 'Bibit Monstera';
      case 3:
        return 'Monstera Sejuk';
      case 4:
        return 'Monstera Rimbun';
      default:
        return 'Kebun Harmoni';
    }
  }

  GamificationModel copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? highestStreak,
    int? plantLevel,
    String? plantName,
    int? currentXp,
    int? xpNeededForNextLevel,
    DateTime? lastWateredDate,
    DateTime? lastActiveDate,
    int? completedTasksCount,
  }) {
    return GamificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      plantLevel: plantLevel ?? this.plantLevel,
      plantName: plantName ?? this.plantName,
      currentXp: currentXp ?? this.currentXp,
      xpNeededForNextLevel: xpNeededForNextLevel ?? this.xpNeededForNextLevel,
      lastWateredDate: lastWateredDate ?? this.lastWateredDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'currentStreak': currentStreak,
      'highestStreak': highestStreak,
      'plantLevel': plantLevel,
      'plantName': plantName,
      'currentXp': currentXp,
      'xpNeededForNextLevel': xpNeededForNextLevel,
      'lastWateredDate': lastWateredDate?.toIso8601String(),
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'completedTasksCount': completedTasksCount,
    };
  }

  factory GamificationModel.fromMap(Map<String, dynamic> map) {
    return GamificationModel(
      id: map['id'] as String? ?? 'gamification_1',
      userId: map['userId'] as String? ?? 'user_1',
      currentStreak: map['currentStreak'] as int? ?? 7,
      highestStreak: map['highestStreak'] as int? ?? 14,
      plantLevel: map['plantLevel'] as int? ?? 3,
      plantName: map['plantName'] as String? ?? 'Monstera Sejuk',
      currentXp: map['currentXp'] as int? ?? 120,
      xpNeededForNextLevel: map['xpNeededForNextLevel'] as int? ?? 240,
      lastWateredDate: map['lastWateredDate'] != null
          ? DateTime.tryParse(map['lastWateredDate'] as String)
          : null,
      lastActiveDate: DateTime.tryParse(map['lastActiveDate'] as String? ?? '') ??
          DateTime.now(),
      completedTasksCount: map['completedTasksCount'] as int? ?? 8,
    );
  }
}
