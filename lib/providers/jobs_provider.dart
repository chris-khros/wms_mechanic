import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../database/database_helper.dart';

class JobsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Job> _jobs = [];
  bool _isLoading = false;

  JobsProvider() {
    loadJobs();
  }

  List<Job> get jobs => [..._jobs];
  bool get isLoading => _isLoading;
  
  List<Job> get todaysJobs {
    final today = DateTime.now();
    return _jobs.where((job) => 
      job.createdAt.day == today.day && 
      job.createdAt.month == today.month && 
      job.createdAt.year == today.year
    ).toList();
  }
  
  List<Job> get thisWeeksJobs {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return _jobs.where((job) => job.createdAt.isAfter(startDate) || 
        (job.createdAt.day == startDate.day && 
        job.createdAt.month == startDate.month && 
        job.createdAt.year == startDate.year)
    ).toList();
  }

  Job? getJobById(String jobId) {
    try {
      return _jobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _dbHelper.getAllJobs();
    } catch (e) {
      debugPrint('Error loading jobs: $e');
      _jobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobStatus(String jobId, JobStatus newStatus) async {
    try {
      await _dbHelper.updateJobStatus(jobId, newStatus);
      
      // Update local state
      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        _jobs[jobIndex].status = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating job status: $e');
    }
  }

  Future<void> updateTaskTimer(String jobId, String taskId, JobTask updatedTask) async {
    try {
      await _dbHelper.updateTask(updatedTask);
      
      // Update local state
      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        final taskIndex = _jobs[jobIndex].tasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          _jobs[jobIndex].tasks[taskIndex] = updatedTask;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating task timer: $e');
    }
  }

  Future<void> addJobNote(String jobId, JobNote note) async {
    try {
      await _dbHelper.addJobNote(jobId, note);
      
      // Update local state
      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        _jobs[jobIndex].notes.add(note);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding job note: $e');
    }
  }

  Future<void> updateCustomerSignature(String jobId, String signatureId) async {
    try {
      // Update local state
      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        _jobs[jobIndex].customerSignature = signatureId;
        _jobs[jobIndex].isSignedOff = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating customer signature: $e');
    }
  }

  Future<void> refreshJobs() async {
    await loadJobs();
  }
}