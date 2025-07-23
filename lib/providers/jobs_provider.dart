import 'package:flutter/foundation.dart';
import '../models/job.dart';

class JobsProvider with ChangeNotifier {
  List<Job> _jobs = [];

  JobsProvider() {
    _loadMockJobs();
  }

  List<Job> get jobs => [..._jobs];
  
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

  void updateJobStatus(String jobId, JobStatus newStatus) {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex].status = newStatus;
      notifyListeners();
    }
  }

  void updateTaskTimer(String jobId, String taskId, JobTask updatedTask) {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      final taskIndex = _jobs[jobIndex].tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _jobs[jobIndex].tasks[taskIndex].timeSpentSeconds = updatedTask.timeSpentSeconds;
        _jobs[jobIndex].tasks[taskIndex].isRunning = updatedTask.isRunning;
        _jobs[jobIndex].tasks[taskIndex].lastStartTime = updatedTask.lastStartTime;
        notifyListeners();
      }
    }
  }
  
  void addJobNote(String jobId, String content, String? photoPath) {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      final newNote = JobNote(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        createdAt: DateTime.now(),
        photoPath: photoPath,
      );
      
      final updatedNotes = List<JobNote>.from(_jobs[jobIndex].notes)
        ..add(newNote);
      
      _jobs[jobIndex] = Job(
        id: _jobs[jobIndex].id,
        customerId: _jobs[jobIndex].customerId,
        customerName: _jobs[jobIndex].customerName,
        customerPhone: _jobs[jobIndex].customerPhone,
        vehicleModel: _jobs[jobIndex].vehicleModel,
        vehiclePlate: _jobs[jobIndex].vehiclePlate,
        description: _jobs[jobIndex].description,
        tasks: _jobs[jobIndex].tasks,
        parts: _jobs[jobIndex].parts,
        serviceHistory: _jobs[jobIndex].serviceHistory,
        notes: updatedNotes,
        customerSignature: _jobs[jobIndex].customerSignature,
        isSignedOff: _jobs[jobIndex].isSignedOff,
        status: _jobs[jobIndex].status,
        createdAt: _jobs[jobIndex].createdAt,
      );
      
      notifyListeners();
    }
  }
  
  void updateCustomerSignature(String jobId, String signaturePath) {
    final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      _jobs[jobIndex] = Job(
        id: _jobs[jobIndex].id,
        customerId: _jobs[jobIndex].customerId,
        customerName: _jobs[jobIndex].customerName,
        customerPhone: _jobs[jobIndex].customerPhone,
        vehicleModel: _jobs[jobIndex].vehicleModel,
        vehiclePlate: _jobs[jobIndex].vehiclePlate,
        description: _jobs[jobIndex].description,
        tasks: _jobs[jobIndex].tasks,
        parts: _jobs[jobIndex].parts,
        serviceHistory: _jobs[jobIndex].serviceHistory,
        notes: _jobs[jobIndex].notes,
        customerSignature: signaturePath,
        isSignedOff: true,
        status: _jobs[jobIndex].status,
        createdAt: _jobs[jobIndex].createdAt,
      );
      
      notifyListeners();
    }
  }

  void _loadMockJobs() {
    _jobs = [
      Job(
        id: "JOB-001",
        customerId: "CUST-001",
        customerName: "John Smith",
        customerPhone: "012-3456789",
        vehicleModel: "Toyota Camry",
        vehiclePlate: "ABC 1234",
        description: "Regular maintenance service and oil change",
        tasks: [
          JobTask(
            id: "TASK-001-1",
            name: "Oil Change",
            description: "Change engine oil and filter",
          ),
          JobTask(
            id: "TASK-001-2",
            name: "Brake Check",
            description: "Inspect brake pads and discs",
          ),
        ],
        parts: [
          JobPart(
            id: "PART-001-1",
            name: "Engine Oil (5W-30)",
            quantity: 4,
            price: 25.0,
          ),
          JobPart(
            id: "PART-001-2",
            name: "Oil Filter",
            quantity: 1,
            price: 15.0,
          ),
        ],
        serviceHistory: [
          ServiceRecord(
            id: "SVC-001-1",
            date: DateTime(2024, 1, 15),
            description: "Replaced timing belt",
            technician: "Mike Johnson",
            cost: 350.0,
          ),
          ServiceRecord(
            id: "SVC-001-2",
            date: DateTime(2023, 10, 8),
            description: "Annual service",
            technician: "David Wong",
            cost: 220.0,
          ),
        ],
        notes: [
          JobNote(
            id: "NOTE-001-1", 
            content: "Customer mentioned strange noise when braking at high speeds", 
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        status: JobStatus.inProgress,
        createdAt: DateTime.now(),
      ),
      Job(
        id: "JOB-002",
        customerId: "CUST-002",
        customerName: "Sarah Lee",
        customerPhone: "012-9876543",
        vehicleModel: "Honda Civic",
        vehiclePlate: "DEF 5678",
        description: "Strange noise when braking, needs inspection",
        tasks: [
          JobTask(
            id: "TASK-002-1",
            name: "Brake System Inspection",
            description: "Check brake components for the source of noise",
          ),
          JobTask(
            id: "TASK-002-2",
            name: "Wheel Alignment",
            description: "Perform wheel alignment if needed",
          ),
        ],
        parts: [
          JobPart(
            id: "PART-002-1",
            name: "Brake Pads (Front)",
            quantity: 2,
            price: 45.0,
          ),
        ],
        serviceHistory: [
          ServiceRecord(
            id: "SVC-002-1",
            date: DateTime(2024, 2, 10),
            description: "Replaced alternator",
            technician: "Mike Johnson",
            cost: 280.0,
          ),
        ],
        status: JobStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Job(
        id: "JOB-003",
        customerId: "CUST-003",
        customerName: "Alex Wong",
        customerPhone: "012-5551234",
        vehicleModel: "BMW 3 Series",
        vehiclePlate: "GHI 9012",
        description: "Annual maintenance and software update",
        tasks: [
          JobTask(
            id: "TASK-003-1",
            name: "Full Service",
            description: "Complete annual maintenance service",
          ),
          JobTask(
            id: "TASK-003-2",
            name: "Software Update",
            description: "Update car's ECU software",
          ),
        ],
        parts: [
          JobPart(
            id: "PART-003-1",
            name: "Air Filter",
            quantity: 1,
            price: 30.0,
          ),
          JobPart(
            id: "PART-003-2",
            name: "Cabin Filter",
            quantity: 1,
            price: 25.0,
          ),
          JobPart(
            id: "PART-003-3",
            name: "Spark Plugs",
            quantity: 4,
            price: 20.0,
          ),
        ],
        serviceHistory: [
          ServiceRecord(
            id: "SVC-003-1",
            date: DateTime(2023, 7, 20),
            description: "Fixed air conditioning system",
            technician: "Chris Lee",
            cost: 420.0,
          ),
          ServiceRecord(
            id: "SVC-003-2",
            date: DateTime(2023, 4, 12),
            description: "Annual service",
            technician: "David Wong",
            cost: 380.0,
          ),
        ],
        status: JobStatus.onHold,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Job(
        id: "JOB-004",
        customerId: "CUST-004",
        customerName: "Michael Tan",
        customerPhone: "012-7778888",
        vehicleModel: "Mercedes E-Class",
        vehiclePlate: "JKL 3456",
        description: "Check engine light is on, diagnostic needed",
        tasks: [
          JobTask(
            id: "TASK-004-1",
            name: "Diagnostic Scan",
            description: "Full scan of engine management system",
          ),
          JobTask(
            id: "TASK-004-2",
            name: "Fault Fixing",
            description: "Repair faults identified in diagnostic",
          ),
        ],
        parts: [],
        serviceHistory: [
          ServiceRecord(
            id: "SVC-004-1",
            date: DateTime(2024, 1, 5),
            description: "Replaced fuel pump",
            technician: "Calvin Ng",
            cost: 520.0,
          ),
        ],
        status: JobStatus.completed,
        isSignedOff: true,
        customerSignature: 'assets/signatures/sample_signature.png', // Mock signature path
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
} 