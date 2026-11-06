import 'package:flutter_test/flutter_test.dart';
import 'package:kantiq/data/models/energy_level.dart';
import 'package:kantiq/data/models/task_model.dart';
import 'package:kantiq/providers/task_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TaskProvider Tests', () {
    test('Initial state loads mock tasks and initial gamification', () async {
      final provider = TaskProvider();
      await provider.loadData();

      expect(provider.allTasks.isNotEmpty, isTrue);
      expect(provider.todayTasksCount, greaterThanOrEqualTo(4));
      expect(provider.gamification.plantLevel, 3);
      expect(provider.gamification.currentStreak, 7);
      expect(provider.user.name, 'Amanda');
    });

    test('waterPlant awards 20 XP and prevents double watering on same day',
        () async {
      final provider = TaskProvider();
      await provider.loadData();

      final initialXp = provider.gamification.currentXp;
      final success1 = await provider.waterPlant();

      expect(success1, isTrue);
      expect(provider.gamification.currentXp, initialXp + 20);
      expect(provider.gamification.isWateredToday, isTrue);

      // Attempting to water again today returns false
      final success2 = await provider.waterPlant();
      expect(success2, isFalse);
    });

    test('addTask adds task to list and awards 25 XP', () async {
      final provider = TaskProvider();
      await provider.loadData();

      final initialXp = provider.gamification.currentXp;
      final initialCount = provider.allTasks.length;

      final newTask = Task(
        id: 'new_custom_task',
        title: 'Tugas Eksperimen Baru',
        energyLevel: EnergyLevel.high,
        deadline: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await provider.addTask(newTask);

      expect(provider.allTasks.length, initialCount + 1);
      expect(provider.allTasks.first.title, 'Tugas Eksperimen Baru');
      expect(provider.gamification.currentXp, initialXp + 25);
    });

    test('toggleTaskCompletion awards 50 XP and completes all subtasks',
        () async {
      final provider = TaskProvider();
      await provider.loadData();

      final initialXp = provider.gamification.currentXp;
      final incompleteTask =
          provider.allTasks.firstWhere((t) => !t.isCompleted);

      await provider.toggleTaskCompletion(incompleteTask.id);

      final updatedTask = provider.findTaskById(incompleteTask.id);
      expect(updatedTask?.isCompleted, isTrue);
      expect(provider.gamification.currentXp, initialXp + 50);

      // All subtasks should now be marked completed
      for (final sub in updatedTask!.subtasks) {
        expect(sub.isCompleted, isTrue);
      }
    });

    test(
        'toggleSubtaskCompletion marks parent task completed when all subtasks become completed',
        () async {
      final provider = TaskProvider();
      await provider.loadData();

      // Find task 1 which has 3 subtasks, 2 completed, 1 incomplete ('sub_1_3')
      final task1 = provider.findTaskById('task_1');
      expect(task1, isNotNull);
      expect(task1!.isCompleted, isFalse);

      final incompleteSub =
          task1.subtasks.firstWhere((s) => !s.isCompleted);

      await provider.toggleSubtaskCompletion(task1.id, incompleteSub.id);

      final updatedTask1 = provider.findTaskById('task_1');
      expect(updatedTask1!.isCompleted, isTrue);
    });

    test('addSubtask and deleteSubtask update task subtask list', () async {
      final provider = TaskProvider();
      await provider.loadData();

      final task = provider.allTasks.first;
      final initialSubCount = task.subtasks.length;

      await provider.addSubtask(task.id, 'Langkah Uji Coba');

      var updated = provider.findTaskById(task.id);
      expect(updated!.subtasks.length, initialSubCount + 1);
      expect(updated.subtasks.last.title, 'Langkah Uji Coba');

      final addedSubId = updated.subtasks.last.id;
      await provider.deleteSubtask(task.id, addedSubId);

      updated = provider.findTaskById(task.id);
      expect(updated!.subtasks.length, initialSubCount);
    });

    test('deleteTask removes task from list', () async {
      final provider = TaskProvider();
      await provider.loadData();

      final initialCount = provider.allTasks.length;
      final firstId = provider.allTasks.first.id;

      await provider.deleteTask(firstId);

      expect(provider.allTasks.length, initialCount - 1);
      expect(provider.findTaskById(firstId), isNull);
    });

    test('energyDistribution calculates percentages correctly', () async {
      final provider = TaskProvider();
      await provider.loadData();

      final dist = provider.energyDistribution;
      expect(dist[EnergyLevel.high], isNotNull);
      expect(dist[EnergyLevel.medium], isNotNull);
      expect(dist[EnergyLevel.relaxed], isNotNull);

      final sum = dist[EnergyLevel.high]! +
          dist[EnergyLevel.medium]! +
          dist[EnergyLevel.relaxed]!;
      expect((sum - 1.0).abs(), lessThan(0.01));
    });
  });
}
