import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  late Box<AppTask> _box;
  List<AppTask> _tasks = [];

  List<AppTask> get tasks => List.unmodifiable(_tasks);

  List<AppTask> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<AppTask> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

  List<AppTask> get upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return pendingTasks
        .where((t) =>
            t.dueDate.isAfter(now) && t.dueDate.isBefore(nextWeek))
        .toList();
  }

  TaskProvider() {
    _init();
  }

  void _init() {
    _box = Hive.box<AppTask>('tasks');
    _tasks = _box.values.toList();
  }

  Future<void> addTask(AppTask task) async {
    await _box.put(task.id, task);
    _tasks = _box.values.toList();

    // Görev tarihi gelecekteyse bildirim planla
    if (task.dueDate.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: task.id.hashCode,
        title: '${AppTask.typeIcon(task.type)} ${task.title}',
        body: 'Bugün yapılacak: ${task.title}',
        scheduledDate: DateTime(
          task.dueDate.year,
          task.dueDate.month,
          task.dueDate.day,
          8, // Sabah 8'de bildirim
        ),
      );
    }

    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _box.put(id, updated);
    if (updated.isCompleted) {
      await NotificationService.cancelNotification(id.hashCode);
    }
    _tasks = _box.values.toList();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await NotificationService.cancelNotification(id.hashCode);
    await _box.delete(id);
    _tasks = _box.values.toList();
    notifyListeners();
  }
}
