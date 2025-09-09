import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final Function(Task) onSubmit;
  final VoidCallback? onCancel;

  const TaskForm({
    Key? key,
    this.task,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.other;
  DateTime? _selectedDueDate;
  String? _selectedJobId;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    final task = widget.task!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _notesController.text = task.notes ?? '';
    _locationController.text = task.location ?? '';
    _estimatedDurationController.text = task.estimatedDurationMinutes.toString();
    _tagsController.text = task.tags.join(', ');
    _selectedPriority = task.priority;
    _selectedCategory = task.category;
    _selectedDueDate = task.dueDate;
    _selectedJobId = task.jobId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _estimatedDurationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildPriorityAndCategoryRow(),
          const SizedBox(height: 16),
          _buildDueDateField(),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildLocationField(),
          const SizedBox(height: 16),
          _buildTagsField(),
          const SizedBox(height: 16),
          _buildNotesField(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Task Title *',
        hintText: 'Enter task title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description *',
        hintText: 'Enter task description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task description';
        }
        return null;
      },
    );
  }

  Widget _buildPriorityAndCategoryRow() {
    return Column(
      children: [
        DropdownButtonFormField<TaskPriority>(
          value: _selectedPriority,
          decoration: const InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.priority_high),
            isDense: true,
          ),
          items: TaskPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getPriorityIcon(priority),
                  const SizedBox(width: 8),
                  Text(_getPriorityDisplayName(priority)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPriority = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TaskCategory>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
            isDense: true,
          ),
          items: TaskCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_getCategoryDisplayName(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDueDateField() {
    return InkWell(
      onTap: _selectDueDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDueDate != null
              ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
              : 'Select due date (optional)',
          style: TextStyle(
            color: _selectedDueDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _estimatedDurationController,
      decoration: const InputDecoration(
        labelText: 'Estimated Duration (minutes)',
        hintText: 'Enter estimated duration in minutes',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timer),
        suffixText: 'min',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final duration = int.tryParse(value);
          if (duration == null || duration < 0) {
            return 'Please enter a valid duration';
          }
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location',
        hintText: 'Enter task location (optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags',
        hintText: 'Enter tags separated by commas',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tag),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Enter additional notes (optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.task != null ? 'Update Task' : 'Create Task'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Icon(Icons.keyboard_arrow_down, color: Colors.green, size: 20);
      case TaskPriority.medium:
        return const Icon(Icons.remove, color: Colors.orange, size: 20);
      case TaskPriority.high:
        return const Icon(Icons.keyboard_arrow_up, color: Colors.red, size: 20);
      case TaskPriority.urgent:
        return const Icon(Icons.priority_high, color: Colors.purple, size: 20);
    }
  }

  String _getPriorityDisplayName(TaskPriority priority) {
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

  String _getCategoryDisplayName(TaskCategory category) {
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

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _submitForm() {
    try {
      if (_formKey.currentState!.validate()) {
        final tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        final task = Task(
          id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          category: _selectedCategory,
          createdAt: widget.task?.createdAt ?? DateTime.now(),
          dueDate: _selectedDueDate,
          assignedTo: widget.task?.assignedTo,
          jobId: _selectedJobId,
          estimatedDurationMinutes: int.tryParse(_estimatedDurationController.text) ?? 0,
          actualDurationMinutes: widget.task?.actualDurationMinutes ?? 0,
          tags: tags,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          status: widget.task?.status ?? TaskStatus.pending,
          completedAt: widget.task?.completedAt,
        );

        widget.onSubmit(task);
      }
    } catch (e) {
      // Handle any unexpected errors gracefully
      debugPrint('Error in form submission: $e');
    }
  }
}
