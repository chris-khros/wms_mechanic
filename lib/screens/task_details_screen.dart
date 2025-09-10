import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../l10n/app_localizations.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';

class TimeEntry {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final String? notes;
  final bool isManual;

  TimeEntry({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.notes,
    this.isManual = false,
  });

  TimeEntry copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? notes,
    bool? isManual,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      isManual: isManual ?? this.isManual,
    );
  }
}

class TaskDetailsScreen extends StatefulWidget {
  static const routeName = '/task-details';
  final String taskId;

  const TaskDetailsScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // Timer animation removed - no longer needed
  
  Task? _task;
  bool _isLoading = true;
  bool _isTimerRunning = false;
  Duration _elapsedTime = Duration.zero;
  DateTime? _timerStartTime;
  Timer? _timerUpdateTimer;
  
  final TextEditingController _notesController = TextEditingController();
  final List<String> _capturedPhotos = [];
  final List<String> _pendingPhotos = []; // Photos waiting to be confirmed
  final List<String> _taskNotes = [];
  final List<TimeEntry> _timeEntries = [];
  
  // Signature related variables
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  String? _customerSignature;
  
  // Quality check related variables
  bool _isQualityCheckCompleted = false;
  Map<String, bool> _qualityCheckItems = {
    'work_completed': false,
    'safety_standards': false,
    'equipment_tested': false,
    'documentation_complete': false,
    'customer_satisfied': false,
    'cleanup_done': false,
  };
  String _qualityCheckNotes = '';
  DateTime? _qualityCheckDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Timer animation controller removed - no longer needed
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    // Timer pulse animation removed - no longer needed
    _loadTaskDetails();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    // Timer animation controller dispose removed - no longer needed
    _timerUpdateTimer?.cancel();
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetails() async {
    try {
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      _task = tasksProvider.getTaskById(widget.taskId);
      if (_task != null) {
        _taskNotes.addAll(_task!.notes?.split('\n') ?? []);
        _capturedPhotos.addAll(_task!.photos);
        await _loadTimerState();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timerData = prefs.getString('timer_${widget.taskId}');
      
      if (timerData != null) {
        final Map<String, dynamic> data = jsonDecode(timerData);
        
        setState(() {
          _elapsedTime = Duration(milliseconds: data['elapsedTime'] ?? 0);
          _isTimerRunning = data['isRunning'] ?? false;
          
          if (data['timerStartTime'] != null) {
            _timerStartTime = DateTime.fromMillisecondsSinceEpoch(data['timerStartTime']);
          }
          
          // Load time entries
          final List<dynamic> entriesData = data['timeEntries'] ?? [];
          _timeEntries.clear();
          for (final entryData in entriesData) {
            _timeEntries.add(TimeEntry(
              id: entryData['id'],
              startTime: DateTime.fromMillisecondsSinceEpoch(entryData['startTime']),
              endTime: entryData['endTime'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(entryData['endTime'])
                : null,
              duration: Duration(milliseconds: entryData['duration']),
              notes: entryData['notes'],
              isManual: entryData['isManual'] ?? false,
            ));
          }
          
          // Load photos
          _capturedPhotos.clear();
          _capturedPhotos.addAll((data['capturedPhotos'] as List<dynamic>?)?.cast<String>() ?? []);
          _pendingPhotos.clear();
          _pendingPhotos.addAll((data['pendingPhotos'] as List<dynamic>?)?.cast<String>() ?? []);
          
          // Load quality check data
          _isQualityCheckCompleted = data['qualityCheckCompleted'] ?? false;
          _qualityCheckItems = Map<String, bool>.from(data['qualityCheckItems'] ?? {});
          _qualityCheckNotes = data['qualityCheckNotes'] ?? '';
          _qualityCheckDate = data['qualityCheckDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(data['qualityCheckDate'])
            : null;
          
          // Load signature
          _customerSignature = data['customerSignature'];
        });
        
        // If timer was running, restart it
        if (_isTimerRunning && _timerStartTime != null) {
          _startTimer();
        }
      }
    } catch (e) {
      debugPrint('Error loading timer state: $e');
    }
  }

  Future<void> _saveTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'elapsedTime': _elapsedTime.inMilliseconds,
        'isRunning': _isTimerRunning,
        'timerStartTime': _timerStartTime?.millisecondsSinceEpoch,
        'timeEntries': _timeEntries.map((entry) => {
          'id': entry.id,
          'startTime': entry.startTime.millisecondsSinceEpoch,
          'endTime': entry.endTime?.millisecondsSinceEpoch,
          'duration': entry.duration.inMilliseconds,
          'notes': entry.notes,
          'isManual': entry.isManual,
        }).toList(),
        'capturedPhotos': _capturedPhotos,
        'pendingPhotos': _pendingPhotos,
        'qualityCheckCompleted': _isQualityCheckCompleted,
        'qualityCheckItems': _qualityCheckItems,
        'qualityCheckNotes': _qualityCheckNotes,
        'qualityCheckDate': _qualityCheckDate?.millisecondsSinceEpoch,
        'customerSignature': _customerSignature,
      };
      
      await prefs.setString('timer_${widget.taskId}', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving timer state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
        ),
      );
    }

    if (_task == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).taskNotFound),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(AppLocalizations.of(context).taskNotFoundMessage),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              _buildSliverAppBar(),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTaskInfoTab(),
              _buildTimeTrackingTab(),
              _buildNotesPhotosTab(),
              _buildSignOffTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.task_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _task!.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _task!.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatusChip(_task!.status),
                      const SizedBox(width: 8),
                      _buildPriorityChip(_task!.priority),
                      const SizedBox(width: 8),
                      _buildCategoryChip(_task!.category),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: AppLocalizations.of(context).detailsTab),
              Tab(text: AppLocalizations.of(context).timeTrackingTab),
              Tab(text: AppLocalizations.of(context).notesPhotosTab),
              Tab(text: AppLocalizations.of(context).signOffTab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    final statusInfo = _getStatusInfo(status);
    final text = _getStatusDisplayName(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo['color'].withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusInfo['color'].withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusInfo['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              statusInfo['icon'],
              size: 14,
              color: statusInfo['color'],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: statusInfo['color'],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        text = AppLocalizations.of(context).low;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        text = AppLocalizations.of(context).medium;
        break;
      case TaskPriority.high:
        color = Colors.red;
        text = AppLocalizations.of(context).high;
        break;
      case TaskPriority.urgent:
        color = Colors.purple;
        text = AppLocalizations.of(context).urgent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(TaskCategory category) {
    Color color = Colors.blue;
    String text = _getCategoryDisplayName(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTaskInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(AppLocalizations.of(context).taskManagement, [
            _buildInfoRow(AppLocalizations.of(context).title, _task!.title),
            _buildInfoRow(AppLocalizations.of(context).description, _task!.description),
            _buildInfoRow(AppLocalizations.of(context).priority, _task!.priorityDisplayName),
            _buildInfoRow(AppLocalizations.of(context).status, _task!.statusDisplayName),
            _buildInfoRow(AppLocalizations.of(context).category, _task!.categoryDisplayName),
            if (_task!.dueDate != null)
              _buildInfoRow(AppLocalizations.of(context).dueDate, _formatDate(_task!.dueDate!)),
            if (_task!.estimatedDurationMinutes > 0)
              _buildInfoRow('Estimated Duration', _task!.formattedEstimatedDuration),
            if (_task!.location != null)
              _buildInfoRow(AppLocalizations.of(context).location, _task!.location!),
            if (_task!.tags.isNotEmpty)
              _buildInfoRow('Tags', _task!.tags.join(', ')),
          ]),
          const SizedBox(height: 16),
          _buildStatusUpdateCard(),
        ],
      ),
    );
  }

  Widget _buildTimeTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTimerCard(),
          const SizedBox(height: 16),
          _buildTimeHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildNotesPhotosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAddNoteCard(),
          const SizedBox(height: 16),
          _buildNotesListCard(),
          const SizedBox(height: 16),
          _buildPhotosCard(),
        ],
      ),
    );
  }

  Widget _buildSignOffTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCompletionStatusCard(),
          const SizedBox(height: 16),
          _buildQualityCheckCard(),
          const SizedBox(height: 16),
          _buildSignatureCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.update,
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).updateStatus,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Fixed grid layout for status buttons
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.0,
                children: TaskStatus.values.map((status) {
                  final isSelected = _task!.status == status;
                  return _buildStatusUpdateChip(status, isSelected);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusUpdateChip(TaskStatus status, bool isSelected) {
    final statusInfo = _getStatusInfo(status);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _updateTaskStatus(status),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? statusInfo['color'] : statusInfo['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? statusInfo['color'] : statusInfo['color'].withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: statusInfo['color'].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : statusInfo['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusInfo['icon'],
                  color: isSelected ? statusInfo['color'] : statusInfo['color'].withOpacity(0.8),
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _getStatusDisplayName(status),
                  style: TextStyle(
                    color: isSelected ? Colors.white : statusInfo['color'],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return {
          'color': const Color(0xFFF59E0B), // Amber
          'icon': Icons.schedule,
        };
      case TaskStatus.inProgress:
        return {
          'color': const Color(0xFF3B82F6), // Blue
          'icon': Icons.play_circle_outline,
        };
      case TaskStatus.completed:
        return {
          'color': const Color(0xFF10B981), // Green
          'icon': Icons.check_circle,
        };
      case TaskStatus.cancelled:
        return {
          'color': const Color(0xFFEF4444), // Red
          'icon': Icons.cancel,
        };
    }
  }

  Widget _buildTimerCard() {
    final isRunning = _isTimerRunning;
    
    // Calculate current elapsed time including running session
    Duration currentElapsedTime = _elapsedTime;
    if (isRunning && _timerStartTime != null) {
      currentElapsedTime += DateTime.now().difference(_timerStartTime!);
    }
    
    // Calculate total time including current session
    final totalTime = _getTotalTime() + (isRunning && _timerStartTime != null 
        ? DateTime.now().difference(_timerStartTime!) 
        : Duration.zero);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isRunning 
              ? [const Color(0xFF667eea).withOpacity(0.1), const Color(0xFF764ba2).withOpacity(0.1)]
              : [Colors.grey.withOpacity(0.05), Colors.grey.withOpacity(0.1)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).timeTracking,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isRunning ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRunning ? Colors.green : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isRunning ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isRunning ? 'Running' : 'Stopped',
                          style: TextStyle(
                            color: isRunning ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isRunning 
                    ? const Color(0xFF667eea).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRunning 
                      ? const Color(0xFF667eea).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatDuration(currentElapsedTime),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isRunning ? const Color(0xFF667eea) : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Session',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isRunning) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _formatDuration(totalTime),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isRunning ? Colors.green[600] : const Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Entries',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_timeEntries.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(isRunning ? 'Pause' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopTimer,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddTimeEntryDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Manual Entry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF667eea),
                    side: const BorderSide(color: Color(0xFF667eea)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).timeHistory,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_timeEntries.isNotEmpty)
                  TextButton.icon(
                    onPressed: _showTimeAnalytics,
                    icon: const Icon(Icons.analytics_rounded, size: 16),
                    label: const Text('Analytics'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF667eea),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_timeEntries.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No time entries yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start tracking time or add manual entries',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _timeEntries.length,
                itemBuilder: (context, index) {
                  final entry = _timeEntries[index];
                  return _buildTimeEntryItem(entry, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNoteCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).addNote,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).enterNoteHere,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _notesController.clear();
                  },
                  child: Text(AppLocalizations.of(context).clear),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addNote,
                  child: Text(AppLocalizations.of(context).addNote),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesListCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).notesTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_taskNotes.isEmpty)
              Text(
                AppLocalizations.of(context).noNotesYet,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ..._taskNotes.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(note),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosCard() {
    final totalPhotos = _capturedPhotos.length + _pendingPhotos.length;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).photos,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (totalPhotos > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF667eea).withOpacity(0.3)),
                        ),
                        child: Text(
                          '$totalPhotos',
                          style: const TextStyle(
                            color: Color(0xFF667eea),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _showPhotoOptionsDialog,
                      icon: const Icon(Icons.camera_alt),
                      tooltip: 'Take Photo',
                    ),
                    IconButton(
                      onPressed: _showPhotoOptionsDialog,
                      icon: const Icon(Icons.photo_library),
                      tooltip: 'Choose from Gallery',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (totalPhotos == 0)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).noPhotosYet,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap camera or gallery to add photos',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Confirmed photos
              if (_capturedPhotos.isNotEmpty) ...[
                Text(
                  'Confirmed Photos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _capturedPhotos.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoPreview(_capturedPhotos[index], index, isConfirmed: true);
                  },
                ),
                const SizedBox(height: 12),
              ],
              // Pending photos
              if (_pendingPhotos.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Pending Photos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${_pendingPhotos.length}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _pendingPhotos.length,
                  itemBuilder: (context, index) {
                    return _buildPhotoPreview(_pendingPhotos[index], index, isConfirmed: false);
                  },
                ),
                const SizedBox(height: 12),
                // Confirm button for pending photos
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _confirmPendingPhotos,
                    icon: const Icon(Icons.check),
                    label: Text('Confirm ${_pendingPhotos.length} Photos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStatusCard() {
    final isCompleted = _task!.status == TaskStatus.completed;
    final canComplete = _isQualityCheckCompleted && _customerSignature != null;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  color: isCompleted ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).completionStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Checkbox(
                value: isCompleted,
                onChanged: canComplete ? (value) {
                  if (value == true) {
                    _updateTaskStatus(TaskStatus.completed);
                  }
                } : null,
              ),
              title: Text(AppLocalizations.of(context).markAsCompleted),
              subtitle: Text(
                isCompleted 
                  ? 'Task has been completed successfully'
                  : canComplete 
                    ? 'Ready to mark as completed'
                    : 'Complete quality check and signature first'
              ),
            ),
            if (!isCompleted && !canComplete) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete quality check and customer signature to enable task completion',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQualityCheckCard() {
    final completedItems = _qualityCheckItems.values.where((value) => value).length;
    final totalItems = _qualityCheckItems.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isQualityCheckCompleted ? Icons.verified : Icons.checklist,
                  color: _isQualityCheckCompleted ? Colors.green : const Color(0xFF667eea),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quality Check',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isQualityCheckCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'VERIFIED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: $completedItems of $totalItems items',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: _isQualityCheckCompleted ? Colors.green : const Color(0xFF667eea),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isQualityCheckCompleted ? Colors.green : const Color(0xFF667eea),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Quality check items
            ..._qualityCheckItems.entries.map((entry) => _buildQualityCheckItem(entry.key, entry.value)),
            
            const SizedBox(height: 16),
            
            // Notes section
            TextField(
              onChanged: (value) {
                _qualityCheckNotes = value;
                _autoSaveTask();
              },
              decoration: const InputDecoration(
                labelText: 'Quality Check Notes (Optional)',
                hintText: 'Add any additional notes or observations...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            if (!_isQualityCheckCompleted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: completedItems == totalItems ? _completeQualityCheck : null,
                  icon: const Icon(Icons.verified),
                  label: Text(completedItems == totalItems 
                    ? 'Complete Quality Check' 
                    : 'Complete All Items First ($completedItems/$totalItems)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completedItems == totalItems ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetQualityCheck,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showQualityCheckDetails,
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQualityCheckItem(String key, bool value) {
    final itemData = _getQualityCheckItemData(key);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: (newValue) {
                setState(() {
                  _qualityCheckItems[key] = newValue ?? false;
                });
                _autoSaveTask();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color: value ? Colors.green : Colors.grey,
                width: 2,
              ),
              activeColor: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemData['title'] ?? 'Unknown Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: value ? Colors.green.shade700 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itemData['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: value ? Colors.green.shade600 : Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getQualityCheckItemData(String key) {
    switch (key) {
      case 'work_completed':
        return {
          'title': 'Work Completed',
          'description': 'All assigned work has been completed according to specifications'
        };
      case 'safety_standards':
        return {
          'title': 'Safety Standards Met',
          'description': 'All safety protocols and standards have been followed'
        };
      case 'equipment_tested':
        return {
          'title': 'Equipment Tested',
          'description': 'All equipment has been tested and is functioning properly'
        };
      case 'documentation_complete':
        return {
          'title': 'Documentation Complete',
          'description': 'All required documentation has been completed and filed'
        };
      case 'customer_satisfied':
        return {
          'title': 'Customer Satisfied',
          'description': 'Customer has confirmed satisfaction with the work performed'
        };
      case 'cleanup_done':
        return {
          'title': 'Cleanup Completed',
          'description': 'Work area has been cleaned and restored to original condition'
        };
      default:
        return {'title': 'Unknown Item', 'description': 'No description available'};
    }
  }

  Widget _buildSignatureCard() {
    final hasSignature = _customerSignature != null;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasSignature ? Icons.check_circle : Icons.edit,
                  color: hasSignature ? Colors.green : const Color(0xFF667eea),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).digitalSignOff,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (hasSignature)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'SIGNED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              hasSignature 
                ? 'Customer signature has been captured and saved'
                : AppLocalizations.of(context).customerSignature,
              style: TextStyle(
                color: hasSignature ? Colors.green.shade700 : Colors.grey,
                fontWeight: hasSignature ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            if (hasSignature) ...[
              // Signature preview
              GestureDetector(
                onTap: _showSignatureFullscreen,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        _customerSignature!.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(_customerSignature!.split(',')[1]),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildSignaturePlaceholder();
                                },
                              )
                            : _buildSignaturePlaceholder(),
                        // Tap indicator
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showSignaturePad,
                      icon: const Icon(Icons.edit),
                      label: const Text('Re-sign'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearSignature,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showSignaturePad,
                  icon: const Icon(Icons.edit),
                  label: Text(AppLocalizations.of(context).customerSignature),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _clearSignature() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Signature'),
        content: const Text('Are you sure you want to clear the customer signature?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _customerSignature = null;
              });
              _autoSaveTask();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }


  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _timerStartTime = DateTime.now();
    });
    
    // Pulse animation removed - timer display stays stable
    
    // Start periodic updates to refresh the display
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning && mounted) {
        setState(() {
          // Just trigger a rebuild to show updated time
        });
        _saveTimerState(); // Save state every second
      }
    });
    
    _saveTimerState();
  }

  void _pauseTimer() {
    setState(() {
      _isTimerRunning = false;
      if (_timerStartTime != null) {
        _elapsedTime += DateTime.now().difference(_timerStartTime!);
        _timerStartTime = null;
      }
    });
    
    // Pulse animation removed - timer display stays stable
    
    // Cancel periodic updates
    _timerUpdateTimer?.cancel();
    
    _saveTimerState();
  }

  void _stopTimer() {
    if (_timerStartTime != null) {
      final sessionDuration = DateTime.now().difference(_timerStartTime!);
      _elapsedTime += sessionDuration;
      
      // Add time entry for this session
      final timeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _timerStartTime!,
        endTime: DateTime.now(),
        duration: sessionDuration,
        notes: 'Timer session',
        isManual: false,
      );
      
      setState(() {
        _timeEntries.insert(0, timeEntry);
        _isTimerRunning = false;
        _timerStartTime = null;
      });
    } else {
      setState(() {
        _isTimerRunning = false;
      });
    }
    
    // Pulse animation removed - timer display stays stable
    
    // Cancel periodic updates
    _timerUpdateTimer?.cancel();
    
    _saveTimerState();
    
    // Show completion message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Timer stopped. Session saved.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _addNote() {
    if (_notesController.text.trim().isNotEmpty) {
      setState(() {
        _taskNotes.add(_notesController.text.trim());
        _notesController.clear();
      });
      _autoSaveTask();
    }
  }


  void _showPhotoOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhotoFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pendingPhotos.add(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured! Tap "Confirm Photos" to save.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pendingPhotos.add(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo selected! Tap "Confirm Photos" to save.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPhotoPreview(String photoPath, int index, {bool isConfirmed = true}) {
    return GestureDetector(
      onTap: () => _showPhotoViewer(photoPath, index, isConfirmed: isConfirmed),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isConfirmed 
              ? Colors.grey.withOpacity(0.3)
              : Colors.orange.withOpacity(0.5),
            width: isConfirmed ? 1 : 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo preview
              if (photoPath.startsWith('http'))
                Image.network(
                  photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.withOpacity(0.2),
                      child: const Icon(Icons.broken_image, size: 48),
                    );
                  },
                )
              else
                Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.withOpacity(0.2),
                      child: const Icon(Icons.broken_image, size: 48),
                    );
                  },
                ),
              // Pending overlay
              if (!isConfirmed)
                Container(
                  color: Colors.orange.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              // Overlay with delete button
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _deletePhoto(index, isConfirmed: isConfirmed),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              // Photo number indicator
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isConfirmed 
                      ? Colors.black.withOpacity(0.6)
                      : Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoViewer(String photoPath, int index, {bool isConfirmed = true}) {
    final list = isConfirmed ? _capturedPhotos : _pendingPhotos;
    final listName = isConfirmed ? 'Confirmed' : 'Pending';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: photoPath.startsWith('http')
                    ? Image.network(photoPath)
                    : Image.file(File(photoPath)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deletePhoto(index, isConfirmed: isConfirmed);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$listName Photo ${index + 1} of ${list.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (!isConfirmed)
                        const Text(
                          'Tap "Confirm Photos" to save',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _sharePhoto(photoPath),
                    icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPendingPhotos() {
    if (_pendingPhotos.isEmpty) return;
    
    setState(() {
      _capturedPhotos.addAll(_pendingPhotos);
      _pendingPhotos.clear();
    });
    
    _autoSaveTask();
    _saveTimerState(); // Also save to SharedPreferences
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photos confirmed and saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deletePhoto(int index, {bool isConfirmed = true}) {
    final list = isConfirmed ? _capturedPhotos : _pendingPhotos;
    final listName = isConfirmed ? 'confirmed' : 'pending';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text('Are you sure you want to delete this $listName photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                list.removeAt(index);
              });
              if (isConfirmed) {
                _autoSaveTask();
                _saveTimerState(); // Also save to SharedPreferences
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sharePhoto(String photoPath) {
    // Placeholder for photo sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo sharing functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSignaturePad() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Customer Signature',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Signature pad
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Please sign below to complete the task',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Signature(
                          controller: _signatureController,
                          backgroundColor: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Controls
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _signatureController.clear();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveSignature,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Signature'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSignature() async {
    if (_signatureController.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a signature before saving'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Convert signature to image
      final ui.Image? image = await _signatureController.toImage();
      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error saving signature'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Convert to byte data
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error processing signature'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Generate signature ID (in a real app, you'd save the byte data)
      final signatureId = 'signature_${widget.taskId}_${DateTime.now().millisecondsSinceEpoch}';
      
      setState(() {
        _customerSignature = signatureId;
      });

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _autoSaveTask();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving signature: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    try {
      await Provider.of<TasksProvider>(context, listen: false)
          .updateTaskStatus(_task!.id, newStatus);
      setState(() {
        _task = _task!.copyWith(status: newStatus);
      });
      _autoSaveTask();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to ${_getStatusDisplayName(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _autoSaveTask() async {
    try {
      // Update task with notes and photos
      final updatedTask = _task!.copyWith(
        notes: _taskNotes.join('\n'),
        photos: _capturedPhotos,
      );
      
      await Provider.of<TasksProvider>(context, listen: false)
          .updateTask(updatedTask);
      
      // Silent auto-save - no success message
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error auto-saving task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusDisplayName(TaskStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
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

  Duration _getTotalTime() {
    Duration total = _elapsedTime;
    for (final entry in _timeEntries) {
      total += entry.duration;
    }
    return total;
  }

  Widget _buildTimeEntryItem(TimeEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isManual ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: entry.isManual ? Colors.blue.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: entry.isManual ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              entry.isManual ? Icons.edit_rounded : Icons.timer_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDuration(entry.duration),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_formatDateTime(entry.startTime)} - ${entry.endTime != null ? _formatDateTime(entry.endTime!) : 'Ongoing'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Text(
                    entry.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editTimeEntry(entry, index);
              } else if (value == 'delete') {
                _deleteTimeEntry(index);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAddTimeEntryDialog() {
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Manual Time Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time (HH:MM)',
                hintText: '09:00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time (HH:MM)',
                hintText: '10:30',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'What did you work on?',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addManualTimeEntry(startTimeController.text, endTimeController.text, notesController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Add Entry'),
          ),
        ],
      ),
    );
  }

  void _addManualTimeEntry(String startTimeStr, String endTimeStr, String notes) {
    try {
      final now = DateTime.now();
      final startTime = _parseTimeString(startTimeStr, now);
      final endTime = _parseTimeString(endTimeStr, now);
      
      if (endTime.isBefore(startTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final duration = endTime.difference(startTime);
      
      final timeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        notes: notes.trim().isEmpty ? null : notes.trim(),
        isManual: true,
      );
      
      setState(() {
        _timeEntries.insert(0, timeEntry);
      });
      
      _saveTimerState();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual time entry added'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid time format: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  DateTime _parseTimeString(String timeStr, DateTime baseDate) {
    final parts = timeStr.split(':');
    if (parts.length != 2) throw const FormatException('Invalid time format');
    
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const FormatException('Invalid time values');
    }
    
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  void _editTimeEntry(TimeEntry entry, int index) {
    // Placeholder for edit functionality
    // In a real implementation, this would show an edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality would be implemented here'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteTimeEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Entry'),
        content: const Text('Are you sure you want to delete this time entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _timeEntries.removeAt(index);
              });
              _saveTimerState();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Time entry deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTimeAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time Analytics'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnalyticsRow('Total Time', _formatDuration(_getTotalTime())),
              _buildAnalyticsRow('Timer Sessions', '${_timeEntries.where((e) => !e.isManual).length}'),
              _buildAnalyticsRow('Manual Entries', '${_timeEntries.where((e) => e.isManual).length}'),
              _buildAnalyticsRow('Average Session', _formatDuration(_getAverageSessionTime())),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Duration _getAverageSessionTime() {
    if (_timeEntries.isEmpty) return Duration.zero;
    
    final totalDuration = _timeEntries.fold<Duration>(
      Duration.zero,
      (sum, entry) => sum + entry.duration,
    );
    
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ _timeEntries.length,
    );
  }

  void _completeQualityCheck() {
    setState(() {
      _isQualityCheckCompleted = true;
      _qualityCheckDate = DateTime.now();
    });
    
    _autoSaveTask();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quality check completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetQualityCheck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Quality Check'),
        content: const Text('Are you sure you want to reset the quality check? This will uncheck all items and allow you to start over.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isQualityCheckCompleted = false;
                _qualityCheckItems = {
                  'work_completed': false,
                  'safety_standards': false,
                  'equipment_tested': false,
                  'documentation_complete': false,
                  'customer_satisfied': false,
                  'cleanup_done': false,
                };
                _qualityCheckNotes = '';
                _qualityCheckDate = null;
              });
              _autoSaveTask();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showQualityCheckDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quality Check Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Completed on: ${_qualityCheckDate?.toString().split('.')[0] ?? 'Unknown'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Completed Items:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._qualityCheckItems.entries
                  .where((entry) => entry.value)
                  .map((entry) {
                final itemData = _getQualityCheckItemData(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemData['title'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_qualityCheckNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _qualityCheckNotes,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.draw,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Signature Captured',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignatureFullscreen() {
    if (_customerSignature == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: _customerSignature!.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(_customerSignature!.split(',')[1]),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: const Text(
                              'Error loading signature',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          'No signature available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearSignature();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  ),
                  const Text(
                    'Customer Signature',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSignaturePad();
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
