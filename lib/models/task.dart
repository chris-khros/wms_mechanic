enum TaskPriority {
  low,
  medium,
  high,
  urgent
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled
}

enum TaskCategory {
  maintenance,
  repair,
  inspection,
  diagnostic,
  customerService,
  administrative,
  other
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? assignedTo;
  final String? jobId; // Optional: link to a specific job
  final int estimatedDurationMinutes;
  final int actualDurationMinutes;
  final List<String> tags;
  final String? notes;
  final String? location;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.status = TaskStatus.pending,
    required this.category,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.assignedTo,
    this.jobId,
    this.estimatedDurationMinutes = 0,
    this.actualDurationMinutes = 0,
    this.tags = const [],
    this.notes,
    this.location,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    TaskCategory? category,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    String? assignedTo,
    String? jobId,
    int? estimatedDurationMinutes,
    int? actualDurationMinutes,
    List<String>? tags,
    String? notes,
    String? location,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      jobId: jobId ?? this.jobId,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'job_id': jobId,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'tags': tags.join(','),
      'notes': notes,
      'location': location,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      assignedTo: map['assigned_to'] as String?,
      jobId: map['job_id'] as String?,
      estimatedDurationMinutes: map['estimated_duration_minutes'] as int? ?? 0,
      actualDurationMinutes: map['actual_duration_minutes'] as int? ?? 0,
      tags: map['tags'] != null ? (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList() : [],
      notes: map['notes'] as String?,
      location: map['location'] as String?,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    final due = dueDate!;
    return today.year == due.year && today.month == due.month && today.day == due.day;
  }

  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case TaskCategory.maintenance:
        return 'Maintenance';
      case TaskCategory.repair:
        return 'Repair';
      case TaskCategory.inspection:
        return 'Inspection';
      case TaskCategory.diagnostic:
        return 'Diagnostic';
      case TaskCategory.customerService:
        return 'Customer Service';
      case TaskCategory.administrative:
        return 'Administrative';
      case TaskCategory.other:
        return 'Other';
    }
  }

  String get formattedEstimatedDuration {
    if (estimatedDurationMinutes == 0) return 'Not set';
    final hours = estimatedDurationMinutes ~/ 60;
    final minutes = estimatedDurationMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  String get formattedActualDuration {
    if (actualDurationMinutes == 0) return 'Not started';
    final hours = actualDurationMinutes ~/ 60;
    final minutes = actualDurationMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}
