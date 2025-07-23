import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job.dart';

class TaskTimerWidget extends StatefulWidget {
  final JobTask task;
  final String jobId;
  final Function(JobTask) onTaskUpdated;

  const TaskTimerWidget({
    Key? key,
    required this.task,
    required this.jobId,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  State<TaskTimerWidget> createState() => _TaskTimerWidgetState();
}

class _TaskTimerWidgetState extends State<TaskTimerWidget> {
  Timer? _timer;
  late int _timeSpentSeconds;
  late bool _isRunning;
  late String _prefKey;

  @override
  void initState() {
    super.initState();
    _timeSpentSeconds = widget.task.timeSpentSeconds;
    _isRunning = widget.task.isRunning;
    _prefKey = 'job_${widget.jobId}_task_${widget.task.id}';
    _loadTimerState();
    
    if (_isRunning) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _pauseTimer(); // Stop the timer when widget is disposed
    super.dispose();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load time spent
    final storedTime = prefs.getInt('${_prefKey}_time') ?? 0;
    
    // Load timer status
    final bool storedIsRunning = prefs.getBool('${_prefKey}_running') ?? false;
    
    // Load last start time if the timer was running
    final int? storedLastStartTime = prefs.getInt('${_prefKey}_lastStart');
    DateTime? lastStartTime;
    
    if (storedLastStartTime != null) {
      lastStartTime = DateTime.fromMillisecondsSinceEpoch(storedLastStartTime);
      
      // If the timer was running when the app was closed, calculate the elapsed time
      if (storedIsRunning) {
        final now = DateTime.now();
        final elapsedSeconds = now.difference(lastStartTime).inSeconds;
        _timeSpentSeconds = storedTime + elapsedSeconds;
      } else {
        _timeSpentSeconds = storedTime;
      }
    } else {
      _timeSpentSeconds = storedTime;
    }
    
    // Update state
    setState(() {
      _isRunning = storedIsRunning;
      widget.task.timeSpentSeconds = _timeSpentSeconds;
      widget.task.isRunning = _isRunning;
      if (storedLastStartTime != null) {
        widget.task.lastStartTime = lastStartTime;
      }
    });
    
    // Start timer if it was running
    if (_isRunning) {
      _startTimer();
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save current time spent
    await prefs.setInt('${_prefKey}_time', _timeSpentSeconds);
    
    // Save timer status
    await prefs.setBool('${_prefKey}_running', _isRunning);
    
    // Save last start time if the timer is running
    if (_isRunning && widget.task.lastStartTime != null) {
      await prefs.setInt('${_prefKey}_lastStart', 
        widget.task.lastStartTime!.millisecondsSinceEpoch);
    } else {
      await prefs.remove('${_prefKey}_lastStart');
    }
    
    // Update the task object
    widget.task.timeSpentSeconds = _timeSpentSeconds;
    widget.task.isRunning = _isRunning;
    
    // Notify parent of the update
    widget.onTaskUpdated(widget.task);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeSpentSeconds++;
      });
    });
    
    setState(() {
      _isRunning = true;
      widget.task.isRunning = true;
      widget.task.lastStartTime = DateTime.now();
    });
    
    _saveTimerState();
  }

  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    
    setState(() {
      _isRunning = false;
      widget.task.isRunning = false;
    });
    
    _saveTimerState();
  }

  void _resetTimer() {
    _pauseTimer();
    
    setState(() {
      _timeSpentSeconds = 0;
      widget.task.timeSpentSeconds = 0;
      widget.task.lastStartTime = null;
    });
    
    _saveTimerState();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Tracked:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                _formatDuration(_timeSpentSeconds),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timer controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimerButton(
                icon: Icons.play_arrow,
                label: 'Start',
                color: Colors.green,
                onPressed: !_isRunning ? _startTimer : null,
              ),
              _buildTimerButton(
                icon: Icons.pause,
                label: 'Pause',
                color: Colors.orange,
                onPressed: _isRunning ? _pauseTimer : null,
              ),
              _buildTimerButton(
                icon: Icons.stop,
                label: 'Reset',
                color: Colors.red,
                onPressed: _timeSpentSeconds > 0 ? _resetTimer : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required String label,
    required Color color,
    required Function()? onPressed,
  }) {
    return SizedBox(
      width: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
} 