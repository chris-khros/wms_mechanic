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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildTitle(),
              const SizedBox(height: 4),
              _buildDescription(),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildTags(),
              ],
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildPriorityIndicator(),
        const SizedBox(width: 8),
        _buildStatusChip(),
        const Spacer(),
        _buildActions(),
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    IconData icon;
    
    switch (task.priority) {
      case TaskPriority.low:
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case TaskPriority.high:
        color = Colors.red;
        icon = Icons.keyboard_arrow_up;
        break;
      case TaskPriority.urgent:
        color = Colors.purple;
        icon = Icons.priority_high;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            task.priorityDisplayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;
    
    switch (task.status) {
      case TaskStatus.pending:
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        icon = Icons.play_circle_outline;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case TaskStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            task.statusDisplayName,
            style: TextStyle(
              fontSize: 12,
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
              Icon(Icons.schedule, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text('Mark as Pending'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'status_in_progress',
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('Mark as In Progress'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'status_completed',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Text('Mark as Completed'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'status_cancelled',
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
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

  Widget _buildTitle() {
    return Text(
      task.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      task.description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        height: 1.3,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: task.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _buildCategoryChip(),
        const Spacer(),
        if (task.dueDate != null) _buildDueDate(),
        if (task.estimatedDurationMinutes > 0) ...[
          const SizedBox(width: 12),
          _buildDuration(),
        ],
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        task.categoryDisplayName,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDueDate() {
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;
    
    Color color;
    String text;
    
    if (isOverdue) {
      color = Colors.red;
      text = 'Overdue';
    } else if (isDueToday) {
      color = Colors.orange;
      text = 'Due Today';
    } else {
      color = Colors.grey;
      text = 'Due ${_formatDate(task.dueDate!)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            task.formattedEstimatedDuration,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
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
