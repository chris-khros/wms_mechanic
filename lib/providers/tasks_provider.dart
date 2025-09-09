import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TasksProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  TaskCategory? _categoryFilter;

  TasksProvider() {
    loadTasks();
  }

  List<Task> get tasks => [..._tasks];
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  TaskCategory? get categoryFilter => _categoryFilter;

  List<Task> get filteredTasks {
    List<Task> filtered = _tasks;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((task) => task.status == _statusFilter).toList();
    }

    // Apply priority filter
    if (_priorityFilter != null) {
      filtered = filtered.where((task) => task.priority == _priorityFilter).toList();
    }

    // Apply category filter
    if (_categoryFilter != null) {
      filtered = filtered.where((task) => task.category == _categoryFilter).toList();
    }

    // Sort by priority (urgent first), then by due date, then by creation date
    filtered.sort((a, b) {
      // First sort by priority
      final priorityOrder = {
        TaskPriority.urgent: 0,
        TaskPriority.high: 1,
        TaskPriority.medium: 2,
        TaskPriority.low: 3,
      };
      final priorityComparison = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityComparison != 0) return priorityComparison;

      // Then sort by due date (overdue first, then due today, then future dates)
      if (a.dueDate != null && b.dueDate != null) {
        final now = DateTime.now();
        final aOverdue = a.dueDate!.isBefore(now) && a.status != TaskStatus.completed;
        final bOverdue = b.dueDate!.isBefore(now) && b.status != TaskStatus.completed;
        
        if (aOverdue && !bOverdue) return -1;
        if (!aOverdue && bOverdue) return 1;
        
        if (!aOverdue && !bOverdue) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // Finally sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  List<Task> get pendingTasks => _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<Task> get inProgressTasks => _tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.status == TaskStatus.completed).toList();
  List<Task> get overdueTasks => _tasks.where((task) => task.isOverdue).toList();
  List<Task> get dueTodayTasks => _tasks.where((task) => task.isDueToday && task.status != TaskStatus.completed).toList();

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksByJobId(String jobId) {
    return _tasks.where((task) => task.jobId == jobId).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _dbHelper.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _dbHelper.insertTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _dbHelper.updateTaskRecord(task);
      
      final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        _tasks[taskIndex] = task;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dbHelper.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final task = getTaskById(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(
          status: newStatus,
          completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
        );
        await updateTask(updatedTask);
      }
    } catch (e) {
      debugPrint('Error updating task status: $e');
      rethrow;
    }
  }

  Future<void> updateTaskPriority(String taskId, TaskPriority newPriority) async {
    try {
      final task = getTaskById(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(priority: newPriority);
        await updateTask(updatedTask);
      }
    } catch (e) {
      debugPrint('Error updating task priority: $e');
      rethrow;
    }
  }

  Future<void> updateTaskDuration(String taskId, int actualDurationMinutes) async {
    try {
      final task = getTaskById(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(actualDurationMinutes: actualDurationMinutes);
        await updateTask(updatedTask);
      }
    } catch (e) {
      debugPrint('Error updating task duration: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  Future<void> refreshTasks() async {
    await loadTasks();
  }

  Future<void> resetDatabaseWithSampleTasks() async {
    try {
      await _dbHelper.resetDatabase();
      await loadTasks();
    } catch (e) {
      debugPrint('Error resetting database: $e');
      rethrow;
    }
  }

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasksCount => completedTasks.length;
  int get pendingTasksCount => pendingTasks.length;
  int get inProgressTasksCount => inProgressTasks.length;
  int get overdueTasksCount => overdueTasks.length;
  int get dueTodayTasksCount => dueTodayTasks.length;

  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasksCount / totalTasks;
  }

  int get totalEstimatedTime {
    return _tasks.fold(0, (sum, task) => sum + task.estimatedDurationMinutes);
  }

  int get totalActualTime {
    return _tasks.fold(0, (sum, task) => sum + task.actualDurationMinutes);
  }

  Map<TaskCategory, int> get tasksByCategory {
    final Map<TaskCategory, int> categoryCount = {};
    for (final category in TaskCategory.values) {
      categoryCount[category] = _tasks.where((task) => task.category == category).length;
    }
    return categoryCount;
  }

  Map<TaskPriority, int> get tasksByPriority {
    final Map<TaskPriority, int> priorityCount = {};
    for (final priority in TaskPriority.values) {
      priorityCount[priority] = _tasks.where((task) => task.priority == priority).length;
    }
    return priorityCount;
  }
}
