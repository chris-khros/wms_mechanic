import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(TaskStatus)? onStatusChanged;
  final Function(TaskPriority)? onPriorityChanged;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
    this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 12),
                _buildTitle(theme),
                const SizedBox(height: 8),
                _buildDescription(theme),
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTags(theme),
                ],
                const SizedBox(height: 16),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildPriorityIndicator(theme),
        const SizedBox(width: 8),
        _buildStatusChip(theme),
        const Spacer(),
        _buildActions(),
      ],
    );
  }

  Widget _buildPriorityIndicator(ThemeData theme) {
    Color color;
    IconData icon;
    
    switch (task.priority) {
      case TaskPriority.low:
        color = const Color(0xFF10B981);
        icon = Icons.keyboard_arrow_down;
        break;
      case TaskPriority.medium:
        color = const Color(0xFFF59E0B);
        icon = Icons.remove;
        break;
      case TaskPriority.high:
        color = const Color(0xFFEF4444);
        icon = Icons.keyboard_arrow_up;
        break;
      case TaskPriority.urgent:
        color = const Color(0xFF8B5CF6);
        icon = Icons.priority_high;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            task.priorityDisplayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color color;
    IconData icon;
    
    switch (task.status) {
      case TaskStatus.pending:
        color = const Color(0xFFF59E0B);
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        color = const Color(0xFF3B82F6);
        icon = Icons.play_circle_outline;
        break;
      case TaskStatus.completed:
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_outline;
        break;
      case TaskStatus.cancelled:
        color = const Color(0xFFEF4444);
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            task.statusDisplayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
          case 'status_pending':
            onStatusChanged?.call(TaskStatus.pending);
            break;
          case 'status_in_progress':
            onStatusChanged?.call(TaskStatus.inProgress);
            break;
          case 'status_completed':
            onStatusChanged?.call(TaskStatus.completed);
            break;
          case 'status_cancelled':
            onStatusChanged?.call(TaskStatus.cancelled);
            break;
          case 'priority_low':
            onPriorityChanged?.call(TaskPriority.low);
            break;
          case 'priority_medium':
            onPriorityChanged?.call(TaskPriority.medium);
            break;
          case 'priority_high':
            onPriorityChanged?.call(TaskPriority.high);
            break;
          case 'priority_urgent':
            onPriorityChanged?.call(TaskPriority.urgent);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'status_pending',
          child: Row(
            children: [
              Icon(Icons.schedule, size: 20, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Mark as Pending'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'status_in_progress',
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, size: 20, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Text('Mark as In Progress'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'status_completed',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Mark as Completed'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'status_cancelled',
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, size: 20, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Mark as Cancelled'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'priority_low',
          child: Row(
            children: [
              Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('Set Priority: Low'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'priority_medium',
          child: Row(
            children: [
              Icon(Icons.remove, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text('Set Priority: Medium'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'priority_high',
          child: Row(
            children: [
              Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Set Priority: High'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'priority_urgent',
          child: Row(
            children: [
              Icon(Icons.priority_high, size: 20, color: Colors.purple),
              SizedBox(width: 8),
              Text('Set Priority: Urgent'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      task.title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      task.description,
      style: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurface.withOpacity(0.7),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: task.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        _buildCategoryChip(theme),
        const Spacer(),
        if (task.dueDate != null) _buildDueDate(theme),
        if (task.estimatedDurationMinutes > 0) ...[
          const SizedBox(width: 12),
          _buildDuration(theme),
        ],
      ],
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Text(
        task.categoryDisplayName,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDueDate(ThemeData theme) {
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;
    
    Color color;
    String text;
    
    if (isOverdue) {
      color = const Color(0xFFEF4444);
      text = 'Overdue';
    } else if (isDueToday) {
      color = const Color(0xFFF59E0B);
      text = 'Due Today';
    } else {
      color = const Color(0xFF64748B);
      text = 'Due ${_formatDate(task.dueDate!)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            task.formattedEstimatedDuration,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'in $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}
