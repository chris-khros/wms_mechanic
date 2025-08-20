import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';
import '../widgets/status_update_widget.dart';
import '../widgets/task_timer_widget.dart';

class JobStatusScreen extends StatefulWidget {
  static const routeName = '/job-status';

  const JobStatusScreen({Key? key}) : super(key: key);

  @override
  State<JobStatusScreen> createState() => _JobStatusScreenState();
}

class _JobStatusScreenState extends State<JobStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;
    final jobsProvider = Provider.of<JobsProvider>(context);
    final job = jobsProvider.getJobById(jobId);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Job Not Found'),
        ),
        body: const Center(
          child: Text('The job you requested was not found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Job Status - Job ${job.id}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF11998e),
                Color(0xFF38ef7d),
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status Card with Progress
              _buildAnimatedCard(
                delay: 0,
                child: _buildStatusCard(job),
              ),
              const SizedBox(height: 20),

              // Status Update Section
              _buildAnimatedCard(
                delay: 200,
                child: _buildStatusUpdateCard(job),
              ),
              const SizedBox(height: 20),

              // Tasks and Time Tracking
              _buildAnimatedCard(
                delay: 400,
                child: _buildTasksCard(job),
              ),
              const SizedBox(height: 20),

              // Service History
              _buildAnimatedCard(
                delay: 600,
                child: _buildServiceHistoryCard(job),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(Job job) {
    final statusData = _getStatusData(job.status);
    final progress = _getStatusProgress(job.status);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: statusData['gradient'] as List<Color>,
        ),
        boxShadow: [
          BoxShadow(
            color: (statusData['gradient'] as List<Color>)[0].withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                  child: Icon(
                    statusData['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Status',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        statusData['text'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Progress indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateCard(Job job) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.update,
                    color: Color(0xFF667eea),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Update Status',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StatusUpdateWidget(job: job),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCard(Job job) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Tasks & Time Tracking',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTasksListWithTimers(context, job),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHistoryCard(Job job) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8360c3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF8360c3),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Service History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildServiceHistory(job),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksListWithTimers(BuildContext context, Job job) {
    if (job.tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks assigned to this job',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: job.tasks.map((task) => _buildTaskItemWithTimer(context, job, task)).toList(),
    );
  }

  Widget _buildTaskItemWithTimer(BuildContext context, Job job, JobTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
                    Icons.task_alt,
                    color: Color(0xFF667eea),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TaskTimerWidget(
              task: task,
              jobId: job.id,
              onTaskUpdated: (updatedTask) {
                // Handle task updates if needed
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHistory(Job job) {
    if (job.serviceHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No service history available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      children: job.serviceHistory.map((service) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8360c3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Color(0xFF8360c3),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8360c3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dateFormat.format(service.date),
                      style: const TextStyle(
                        color: Color(0xFF8360c3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _getStatusData(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return {
          'text': 'Accepted',
          'icon': Icons.check_circle_outline,
          'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
        };
      case JobStatus.inProgress:
        return {
          'text': 'In Progress',
          'icon': Icons.play_circle_outline,
          'gradient': [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        };
      case JobStatus.onHold:
        return {
          'text': 'On Hold',
          'icon': Icons.pause_circle_outline,
          'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
        };
      case JobStatus.completed:
        return {
          'text': 'Completed',
          'icon': Icons.check_circle,
          'gradient': [const Color(0xFF8360c3), const Color(0xFF2ebf91)],
        };
    }
  }

  double _getStatusProgress(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return 0.25;
      case JobStatus.inProgress:
        return 0.75;
      case JobStatus.onHold:
        return 0.5;
      case JobStatus.completed:
        return 1.0;
    }
  }
}