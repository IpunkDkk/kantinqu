import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/date_formatter.dart';
import '../data/mock_data.dart';
import '../data/models/energy_level.dart';
import '../data/models/gamification_model.dart';
import '../data/models/subtask_model.dart';
import '../data/models/task_model.dart';
import '../data/models/user_model.dart';

enum SortOption {
  time,
  energy,
  status,
}

class TaskProvider extends ChangeNotifier {
  static const String _tasksPrefKey = 'myplan_tasks_key_v1';
  static const String _gamificationPrefKey = 'myplan_gamification_key_v1';
  static const String _userPrefKey = 'myplan_user_key_v1';

  final _uuid = const Uuid();

  List<Task> _tasks = [];
  GamificationModel _gamification = MockData.initialGamification;
  UserModel _user = MockData.initialUser;

  String _currentFilter = 'all'; // 'all', 'high', 'medium', 'relaxed'
  SortOption _currentSort = SortOption.time;
  bool _isLoading = true;

  List<Task> get allTasks => List.unmodifiable(_tasks);
  GamificationModel get gamification => _gamification;
  UserModel get user => _user;
  String get currentFilter => _currentFilter;
  SortOption get currentSort => _currentSort;
  bool get isLoading => _isLoading;

  TaskProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load tasks
      final tasksRaw = prefs.getStringList(_tasksPrefKey);
      if (tasksRaw != null && tasksRaw.isNotEmpty) {
        _tasks = tasksRaw
            .map((item) => Task.fromMap(jsonDecode(item) as Map<String, dynamic>))
            .toList();
      } else {
        _tasks = MockData.initialTasks;
        await _saveTasksToPrefs();
      }

      // Load gamification
      final gamificationRaw = prefs.getString(_gamificationPrefKey);
      if (gamificationRaw != null) {
        _gamification = GamificationModel.fromMap(
            jsonDecode(gamificationRaw) as Map<String, dynamic>);
      } else {
        _gamification = MockData.initialGamification;
        await _saveGamificationToPrefs();
      }

      // Load user
      final userRaw = prefs.getString(_userPrefKey);
      if (userRaw != null) {
        _user = UserModel.fromMap(jsonDecode(userRaw) as Map<String, dynamic>);
      } else {
        _user = MockData.initialUser;
        await _saveUserToPrefs();
      }
    } catch (e) {
      debugPrint('Error loading saved data: $e');
      _tasks = MockData.initialTasks;
      _gamification = MockData.initialGamification;
      _user = MockData.initialUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_tasksPrefKey, rawList);
  }

  Future<void> _saveGamificationToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gamificationPrefKey, jsonEncode(_gamification.toMap()));
  }

  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPrefKey, jsonEncode(_user.toMap()));
  }

  void setFilter(String filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      notifyListeners();
    }
  }

  void setSort(SortOption sort) {
    if (_currentSort != sort) {
      _currentSort = sort;
      notifyListeners();
    }
  }

  // Get tasks for Today (including uncompleted from previous days if desired)
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return DateFormatter.isSameDay(task.deadline, now);
    }).toList();
  }

  int get todayTasksCount => todayTasks.length;

  int get todayCompletedCount =>
      todayTasks.where((task) => task.isCompleted).length;

  double get todayProgressPercentage {
    if (todayTasks.isEmpty) return 0.0;
    return (todayCompletedCount / todayTasks.length).clamp(0.0, 1.0);
  }

  // Counts by energy level for today
  int get todayHighFocusCount =>
      todayTasks.where((t) => t.energyLevel == EnergyLevel.high).length;

  int get todayMediumFocusCount =>
      todayTasks.where((t) => t.energyLevel == EnergyLevel.medium).length;

  int get todayRelaxedCount =>
      todayTasks.where((t) => t.energyLevel == EnergyLevel.relaxed).length;

  List<Task> get filteredTodayTasks {
    List<Task> list = todayTasks;

    if (_currentFilter == 'high') {
      list = list.where((t) => t.energyLevel == EnergyLevel.high).toList();
    } else if (_currentFilter == 'medium') {
      list = list.where((t) => t.energyLevel == EnergyLevel.medium).toList();
    } else if (_currentFilter == 'relaxed') {
      list = list.where((t) => t.energyLevel == EnergyLevel.relaxed).toList();
    }

    // Sort
    switch (_currentSort) {
      case SortOption.time:
        list.sort((a, b) => a.targetTime.compareTo(b.targetTime));
        break;
      case SortOption.energy:
        list.sort((a, b) => a.energyLevel.index.compareTo(b.energyLevel.index));
        break;
      case SortOption.status:
        list.sort((a, b) {
          if (a.isCompleted == b.isCompleted) return 0;
          return a.isCompleted ? 1 : -1;
        });
        break;
    }

    return list;
  }

  List<Task> getTasksForDate(DateTime date) {
    final list = _tasks.where((t) => DateFormatter.isSameDay(t.deadline, date)).toList();
    list.sort((a, b) => a.targetTime.compareTo(b.targetTime));
    return list;
  }

  // Grouped tasks for calendar timeline
  Map<String, List<Task>> getGroupedTasksForDate(DateTime date) {
    final list = getTasksForDate(date);
    final morning = <Task>[];
    final afternoon = <Task>[];
    final evening = <Task>[];

    for (final task in list) {
      // Parse hour from targetTime like "14:00 WIB"
      final parts = task.targetTime.split(':');
      int hour = 12;
      if (parts.isNotEmpty) {
        hour = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;
      }

      if (hour < 12) {
        morning.add(task);
      } else if (hour < 18) {
        afternoon.add(task);
      } else {
        evening.add(task);
      }
    }

    return {
      'Pagi (06:00 - 12:00)': morning,
      'Siang & Sore (12:00 - 18:00)': afternoon,
      'Malam (18:00 - 24:00)': evening,
    };
  }

  // Weekly stats: Sen to Min tasks completed
  List<double> get weeklyCompletionData {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final result = <double>[];

    for (int i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day).add(Duration(days: i));
      final tasksOnDay = _tasks.where((t) => DateFormatter.isSameDay(t.deadline, day));
      final completed = tasksOnDay.where((t) => t.isCompleted).length;
      result.add(completed.toDouble());
    }

    return result;
  }

  // Energy distribution percentages
  Map<EnergyLevel, double> get energyDistribution {
    if (_tasks.isEmpty) {
      return {
        EnergyLevel.high: 0.33,
        EnergyLevel.medium: 0.33,
        EnergyLevel.relaxed: 0.34,
      };
    }
    final high = _tasks.where((t) => t.energyLevel == EnergyLevel.high).length;
    final medium = _tasks.where((t) => t.energyLevel == EnergyLevel.medium).length;
    final relaxed = _tasks.where((t) => t.energyLevel == EnergyLevel.relaxed).length;
    final total = _tasks.length;

    return {
      EnergyLevel.high: high / total,
      EnergyLevel.medium: medium / total,
      EnergyLevel.relaxed: relaxed / total,
    };
  }

  Task? findTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  // Actions
  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final willBeCompleted = !task.isCompleted;

    // Also update all subtasks to match parent if marking completed
    final updatedSubtasks = task.subtasks.map((s) {
      return s.copyWith(isCompleted: willBeCompleted);
    }).toList();

    _tasks[index] = task.copyWith(
      isCompleted: willBeCompleted,
      subtasks: updatedSubtasks,
    );

    if (willBeCompleted) {
      _awardXp(50, taskCompleted: true);
    }

    await _saveTasksToPrefs();
    notifyListeners();
  }

  Future<void> toggleSubtaskCompletion(String taskId, String subtaskId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];
    final subtasks = List<Subtask>.from(task.subtasks);
    final subIndex = subtasks.indexWhere((s) => s.id == subtaskId);
    if (subIndex == -1) return;

    final currentSub = subtasks[subIndex];
    final newSubCompleted = !currentSub.isCompleted;
    subtasks[subIndex] = currentSub.copyWith(isCompleted: newSubCompleted);

    // If all subtasks are completed, mark parent completed!
    final allDone = subtasks.isNotEmpty && subtasks.every((s) => s.isCompleted);
    final wasCompleted = task.isCompleted;
    final isNowCompleted = allDone ? true : (newSubCompleted ? wasCompleted : false);

    _tasks[taskIndex] = task.copyWith(
      isCompleted: isNowCompleted,
      subtasks: subtasks,
    );

    if (!wasCompleted && isNowCompleted) {
      _awardXp(50, taskCompleted: true);
    }

    await _saveTasksToPrefs();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    _awardXp(25); // +25 XP from adding task
    await _saveTasksToPrefs();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveTasksToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasksToPrefs();
    notifyListeners();
  }

  Future<void> addSubtask(String taskId, String title) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final newSubtask = Subtask(
      id: _uuid.v4(),
      taskId: taskId,
      title: title.trim(),
      isCompleted: false,
    );

    final updatedSubtasks = [...task.subtasks, newSubtask];
    _tasks[index] = task.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: false,
    );

    await _saveTasksToPrefs();
    notifyListeners();
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    final updatedSubtasks =
        task.subtasks.where((s) => s.id != subtaskId).toList();

    final allDone = updatedSubtasks.isNotEmpty &&
        updatedSubtasks.every((s) => s.isCompleted);

    _tasks[index] = task.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: updatedSubtasks.isEmpty ? task.isCompleted : allDone,
    );

    await _saveTasksToPrefs();
    notifyListeners();
  }

  Future<bool> waterPlant() async {
    if (_gamification.isWateredToday) {
      return false;
    }

    _awardXp(20);
    _gamification = _gamification.copyWith(
      lastWateredDate: DateTime.now(),
    );

    await _saveGamificationToPrefs();
    notifyListeners();
    return true;
  }

  void _awardXp(int xpGained, {bool taskCompleted = false}) {
    int totalXp = _gamification.currentXp + xpGained;
    int level = _gamification.plantLevel;
    int xpNeeded = _gamification.xpNeededForNextLevel;
    int completedCount = _gamification.completedTasksCount + (taskCompleted ? 1 : 0);

    // Level up check
    while (totalXp >= xpNeeded) {
      totalXp -= xpNeeded;
      level++;
      xpNeeded = (xpNeeded * 1.5).round();
    }

    _gamification = _gamification.copyWith(
      currentXp: totalXp,
      plantLevel: level,
      plantName: GamificationModel.getPlantTitleForLevel(level),
      xpNeededForNextLevel: xpNeeded,
      completedTasksCount: completedCount,
      lastActiveDate: DateTime.now(),
    );

    _saveGamificationToPrefs();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;
    await _saveUserToPrefs();
    notifyListeners();
  }

  Future<void> resetToMockData() async {
    _tasks = MockData.initialTasks;
    _gamification = MockData.initialGamification;
    _user = MockData.initialUser;
    await _saveTasksToPrefs();
    await _saveGamificationToPrefs();
    await _saveUserToPrefs();
    notifyListeners();
  }
}
