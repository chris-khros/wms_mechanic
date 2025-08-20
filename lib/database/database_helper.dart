import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/job.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wms_mechanic.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create mechanics table
    await db.execute('''
      CREATE TABLE mechanics (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        specialization TEXT,
        experience_years INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Create jobs table
    await db.execute('''
      CREATE TABLE jobs (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        vehicle_model TEXT NOT NULL,
        vehicle_plate TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        assigned_mechanic_id TEXT,
        FOREIGN KEY (assigned_mechanic_id) REFERENCES mechanics (id)
      )
    ''');

    // Create job_tasks table
    await db.execute('''
      CREATE TABLE job_tasks (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        time_spent_seconds INTEGER DEFAULT 0,
        is_running INTEGER DEFAULT 0,
        last_start_time TEXT,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
      )
    ''');

    // Create job_parts table
    await db.execute('''
      CREATE TABLE job_parts (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
      )
    ''');

    // Create service_records table
    await db.execute('''
      CREATE TABLE service_records (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        technician TEXT NOT NULL,
        cost REAL NOT NULL,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
      )
    ''');

    // Create job_notes table
    await db.execute('''
      CREATE TABLE job_notes (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        photo_path TEXT,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
      )
    ''');

    // Insert default mechanic
    await _insertDefaultMechanic(db);
    
    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertDefaultMechanic(Database db) async {
    await db.insert('mechanics', {
      'id': 'mech_001',
      'name': 'John Smith',
      'email': 'john.smith@workshop.com',
      'password': 'password123', // In production, this should be hashed
      'phone': '+1234567890',
      'specialization': 'Engine & Transmission',
      'experience_years': 8,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _insertSampleData(Database db) async {
    // Insert sample jobs
    final jobs = [
      {
        'id': 'JOB001',
        'customer_id': 'CUST001',
        'customer_name': 'Alice Johnson',
        'customer_phone': '+1234567890',
        'vehicle_model': 'Toyota Camry 2020',
        'vehicle_plate': 'ABC123',
        'description': 'Engine making unusual noise, needs diagnostic check',
        'status': 'inProgress',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'assigned_mechanic_id': 'mech_001',
      },
      {
        'id': 'JOB002',
        'customer_id': 'CUST002',
        'customer_name': 'Bob Wilson',
        'customer_phone': '+1234567891',
        'vehicle_model': 'Honda Civic 2019',
        'vehicle_plate': 'XYZ789',
        'description': 'Brake pads replacement and oil change',
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
        'assigned_mechanic_id': 'mech_001',
      },
    ];

    for (var job in jobs) {
      await db.insert('jobs', job);
    }

    // Insert sample tasks
    final tasks = [
      {
        'id': 'task_001',
        'job_id': 'JOB001',
        'name': 'Engine Diagnostic',
        'description': 'Run comprehensive engine diagnostic test',
        'time_spent_seconds': 1800,
        'is_running': 0,
        'last_start_time': null,
      },
      {
        'id': 'task_002',
        'job_id': 'JOB001',
        'name': 'Check Engine Components',
        'description': 'Inspect engine components for wear and damage',
        'time_spent_seconds': 0,
        'is_running': 0,
        'last_start_time': null,
      },
      {
        'id': 'task_003',
        'job_id': 'JOB002',
        'name': 'Replace Brake Pads',
        'description': 'Remove old brake pads and install new ones',
        'time_spent_seconds': 0,
        'is_running': 0,
        'last_start_time': null,
      },
      {
        'id': 'task_004',
        'job_id': 'JOB002',
        'name': 'Oil Change',
        'description': 'Drain old oil and replace with new oil and filter',
        'time_spent_seconds': 0,
        'is_running': 0,
        'last_start_time': null,
      },
    ];

    for (var task in tasks) {
      await db.insert('job_tasks', task);
    }

    // Insert sample parts
    final parts = [
      {
        'id': 'part_001',
        'job_id': 'JOB002',
        'name': 'Brake Pads (Front)',
        'quantity': 1,
        'price': 89.99,
      },
      {
        'id': 'part_002',
        'job_id': 'JOB002',
        'name': 'Engine Oil (5W-30)',
        'quantity': 1,
        'price': 24.99,
      },
      {
        'id': 'part_003',
        'job_id': 'JOB002',
        'name': 'Oil Filter',
        'quantity': 1,
        'price': 12.99,
      },
    ];

    for (var part in parts) {
      await db.insert('job_parts', part);
    }

    // Insert sample service records
    final serviceRecords = [
      {
        'id': 'service_001',
        'job_id': 'JOB001',
        'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'description': 'Regular maintenance check',
        'technician': 'Mike Johnson',
        'cost': 150.00,
      },
    ];

    for (var record in serviceRecords) {
      await db.insert('service_records', record);
    }
  }

  // Mechanic operations
  Future<Map<String, dynamic>?> authenticateMechanic(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'mechanics',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getMechanicById(String id) async {
    final db = await database;
    final result = await db.query(
      'mechanics',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Job operations
  Future<List<Job>> getAllJobs() async {
    final db = await database;
    final jobMaps = await db.query('jobs', orderBy: 'created_at DESC');
    
    List<Job> jobs = [];
    for (var jobMap in jobMaps) {
      final job = await _buildJobFromMap(jobMap);
      jobs.add(job);
    }
    
    return jobs;
  }

  Future<Job?> getJobById(String id) async {
    final db = await database;
    final result = await db.query(
      'jobs',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return await _buildJobFromMap(result.first);
    }
    return null;
  }

  Future<List<Job>> getTodaysJobs() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    final jobMaps = await db.query(
      'jobs',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'created_at DESC',
    );
    
    List<Job> jobs = [];
    for (var jobMap in jobMaps) {
      final job = await _buildJobFromMap(jobMap);
      jobs.add(job);
    }
    
    return jobs;
  }

  Future<List<Job>> getThisWeeksJobs() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    final jobMaps = await db.query(
      'jobs',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    
    List<Job> jobs = [];
    for (var jobMap in jobMaps) {
      final job = await _buildJobFromMap(jobMap);
      jobs.add(job);
    }
    
    return jobs;
  }

  Future<Job> _buildJobFromMap(Map<String, dynamic> jobMap) async {
    final db = await database;
    
    // Get tasks
    final taskMaps = await db.query(
      'job_tasks',
      where: 'job_id = ?',
      whereArgs: [jobMap['id']],
    );
    
    List<JobTask> tasks = taskMaps.map((taskMap) {
      return JobTask(
        id: taskMap['id'] as String,
        name: taskMap['name'] as String,
        description: taskMap['description'] as String,
        timeSpentSeconds: taskMap['time_spent_seconds'] as int,
        isRunning: (taskMap['is_running'] as int) == 1,
        lastStartTime: taskMap['last_start_time'] != null 
            ? DateTime.parse(taskMap['last_start_time'] as String)
            : null,
      );
    }).toList();
    
    // Get parts
    final partMaps = await db.query(
      'job_parts',
      where: 'job_id = ?',
      whereArgs: [jobMap['id']],
    );
    
    List<JobPart> parts = partMaps.map((partMap) {
      return JobPart(
        id: partMap['id'] as String,
        name: partMap['name'] as String,
        quantity: partMap['quantity'] as int,
        price: partMap['price'] as double,
      );
    }).toList();
    
    // Get service records
    final serviceMaps = await db.query(
      'service_records',
      where: 'job_id = ?',
      whereArgs: [jobMap['id']],
    );
    
    List<ServiceRecord> serviceHistory = serviceMaps.map((serviceMap) {
      return ServiceRecord(
        id: serviceMap['id'] as String,
        date: DateTime.parse(serviceMap['date'] as String),
        description: serviceMap['description'] as String,
        technician: serviceMap['technician'] as String,
        cost: serviceMap['cost'] as double,
      );
    }).toList();
    
    // Get notes
    final noteMaps = await db.query(
      'job_notes',
      where: 'job_id = ?',
      whereArgs: [jobMap['id']],
    );
    
    List<JobNote> notes = noteMaps.map((noteMap) {
      return JobNote(
        id: noteMap['id'] as String,
        content: noteMap['content'] as String,
        createdAt: DateTime.parse(noteMap['created_at'] as String),
        photoPath: noteMap['photo_path'] as String?,
      );
    }).toList();
    
    return Job(
      id: jobMap['id'] as String,
      customerId: jobMap['customer_id'] as String,
      customerName: jobMap['customer_name'] as String,
      customerPhone: jobMap['customer_phone'] as String,
      vehicleModel: jobMap['vehicle_model'] as String,
      vehiclePlate: jobMap['vehicle_plate'] as String,
      description: jobMap['description'] as String,
      status: JobStatus.values.firstWhere(
        (e) => e.toString().split('.').last == jobMap['status'],
      ),
      createdAt: DateTime.parse(jobMap['created_at'] as String),
      tasks: tasks,
      parts: parts,
      serviceHistory: serviceHistory,
      notes: notes,
    );
  }

  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final db = await database;
    await db.update(
      'jobs',
      {'status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }

  Future<void> addJobNote(String jobId, JobNote note) async {
    final db = await database;
    await db.insert('job_notes', {
      'id': note.id,
      'job_id': jobId,
      'content': note.content,
      'created_at': note.createdAt.toIso8601String(),
      'photo_path': note.photoPath,
    });
  }

  Future<void> updateTask(JobTask task) async {
    final db = await database;
    await db.update(
      'job_tasks',
      {
        'time_spent_seconds': task.timeSpentSeconds,
        'is_running': task.isRunning ? 1 : 0,
        'last_start_time': task.lastStartTime?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
