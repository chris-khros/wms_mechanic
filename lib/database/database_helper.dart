import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/job.dart';
import '../models/task.dart';

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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        debugPrint('Database opened successfully');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Creating database tables...');
    
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

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        due_date TEXT,
        completed_at TEXT,
        assigned_to TEXT,
        job_id TEXT,
        estimated_duration_minutes INTEGER DEFAULT 0,
        actual_duration_minutes INTEGER DEFAULT 0,
        tags TEXT,
        notes TEXT,
        location TEXT,
        photos TEXT,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE SET NULL
      )
    ''');

    // Insert default mechanic
    await _insertDefaultMechanic(db);
    
    // Insert sample data
    await _insertSampleData(db);
    
    debugPrint('Database initialization completed successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      // Add tasks table for version 2
      await db.execute('''
        CREATE TABLE tasks (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          priority TEXT NOT NULL,
          status TEXT NOT NULL,
          category TEXT NOT NULL,
          created_at TEXT NOT NULL,
          due_date TEXT,
          completed_at TEXT,
          assigned_to TEXT,
          job_id TEXT,
          estimated_duration_minutes INTEGER DEFAULT 0,
          actual_duration_minutes INTEGER DEFAULT 0,
          tags TEXT,
          notes TEXT,
          location TEXT,
          photos TEXT,
          FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE SET NULL
        )
      ''');
      
      // Insert sample tasks
      await _insertSampleTasks(db);
      
      debugPrint('Tasks table created and sample data inserted');
    }
    
    if (oldVersion < 3) {
      // Add photos column to existing tasks table for version 3
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN photos TEXT');
        debugPrint('Added photos column to tasks table');
      } catch (e) {
        debugPrint('Photos column might already exist: $e');
      }
    }
  }

  Future<void> _insertSampleTasks(Database db) async {
    // Insert sample tasks
    final sampleTasks = [
      {
        'id': 'task_001',
        'title': 'Oil Change Service',
        'description': 'Perform routine oil change for customer vehicle',
        'priority': 'high',
        'status': 'pending',
        'category': 'maintenance',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': 'JOB002',
        'estimated_duration_minutes': 30,
        'actual_duration_minutes': 0,
        'tags': 'oil,maintenance,routine',
        'notes': 'Customer requested synthetic oil',
        'location': 'Bay 1',
        'photos': '',
      },
      {
        'id': 'task_002',
        'title': 'Engine Diagnostic Check',
        'description': 'Run comprehensive diagnostic on engine issues',
        'priority': 'urgent',
        'status': 'inProgress',
        'category': 'diagnostic',
        'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': 'JOB001',
        'estimated_duration_minutes': 60,
        'actual_duration_minutes': 25,
        'tags': 'engine,diagnostic,urgent',
        'notes': 'Customer reported strange noises',
        'location': 'Bay 2',
        'photos': '',
      },
      {
        'id': 'task_003',
        'title': 'Brake Pad Replacement',
        'description': 'Replace worn brake pads on front wheels',
        'priority': 'medium',
        'status': 'completed',
        'category': 'repair',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'due_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'completed_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'assigned_to': 'mech_001',
        'job_id': 'JOB002',
        'estimated_duration_minutes': 45,
        'actual_duration_minutes': 50,
        'tags': 'brakes,repair,front',
        'notes': 'Customer approved premium brake pads',
        'location': 'Bay 1',
        'photos': '',
      },
      {
        'id': 'task_004',
        'title': 'Transmission Fluid Service',
        'description': 'Replace transmission fluid and filter',
        'priority': 'medium',
        'status': 'pending',
        'category': 'maintenance',
        'created_at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 90,
        'actual_duration_minutes': 0,
        'tags': 'transmission,fluid,maintenance',
        'notes': 'High mileage vehicle - use premium fluid',
        'location': 'Bay 3',
        'photos': '',
      },
      {
        'id': 'task_005',
        'title': 'AC System Inspection',
        'description': 'Check AC system performance and refrigerant levels',
        'priority': 'low',
        'status': 'inProgress',
        'category': 'inspection',
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 45,
        'actual_duration_minutes': 15,
        'tags': 'ac,climate,inspection',
        'notes': 'Customer complains of weak cooling',
        'location': 'Bay 4',
        'photos': '',
      },
      {
        'id': 'task_006',
        'title': 'Battery Replacement',
        'description': 'Replace dead battery and test charging system',
        'priority': 'high',
        'status': 'completed',
        'category': 'repair',
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'due_date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'completed_at': DateTime.now().subtract(const Duration(days: 2, hours: 2)).toIso8601String(),
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 30,
        'actual_duration_minutes': 35,
        'tags': 'battery,electrical,replacement',
        'notes': 'Installed premium AGM battery',
        'location': 'Bay 1',
        'photos': '',
      },
      {
        'id': 'task_007',
        'title': 'Tire Rotation & Balance',
        'description': 'Rotate tires and balance all wheels',
        'priority': 'low',
        'status': 'pending',
        'category': 'maintenance',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 60,
        'actual_duration_minutes': 0,
        'tags': 'tires,rotation,balance',
        'notes': 'Regular maintenance service',
        'location': 'Bay 2',
        'photos': '',
      },
      {
        'id': 'task_008',
        'title': 'Spark Plug Replacement',
        'description': 'Replace all spark plugs and check ignition system',
        'priority': 'medium',
        'status': 'inProgress',
        'category': 'maintenance',
        'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 75,
        'actual_duration_minutes': 20,
        'tags': 'spark,plugs,ignition',
        'notes': 'V6 engine - 6 spark plugs needed',
        'location': 'Bay 3',
        'photos': '',
      },
      {
        'id': 'task_009',
        'title': 'Wheel Alignment Check',
        'description': 'Check and adjust wheel alignment settings',
        'priority': 'medium',
        'status': 'pending',
        'category': 'inspection',
        'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 45,
        'actual_duration_minutes': 0,
        'tags': 'alignment,wheels,suspension',
        'notes': 'Customer reports pulling to the right',
        'location': 'Bay 4',
        'photos': '',
      },
      {
        'id': 'task_010',
        'title': 'Timing Belt Replacement',
        'description': 'Replace timing belt and water pump',
        'priority': 'urgent',
        'status': 'pending',
        'category': 'repair',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 180,
        'actual_duration_minutes': 0,
        'tags': 'timing,belt,water,pump',
        'notes': 'High mileage - critical maintenance',
        'location': 'Bay 1',
        'photos': '',
      },
      {
        'id': 'task_011',
        'title': 'Customer Service Call',
        'description': 'Follow up with customer about service satisfaction',
        'priority': 'low',
        'status': 'completed',
        'category': 'customerService',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'due_date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'completed_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 15,
        'actual_duration_minutes': 12,
        'tags': 'customer,service,followup',
        'notes': 'Customer very satisfied with brake service',
        'location': 'Office',
        'photos': '',
      },
      {
        'id': 'task_012',
        'title': 'Inventory Update',
        'description': 'Update parts inventory and order supplies',
        'priority': 'medium',
        'status': 'pending',
        'category': 'administrative',
        'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'completed_at': null,
        'assigned_to': 'mech_001',
        'job_id': null,
        'estimated_duration_minutes': 120,
        'actual_duration_minutes': 0,
        'tags': 'inventory,parts,ordering',
        'notes': 'Need to order brake pads and filters',
        'location': 'Office',
        'photos': '',
      },
    ];

    for (var task in sampleTasks) {
      await db.insert('tasks', task);
    }
  }

  Future<void> _insertDefaultMechanic(Database db) async {
    debugPrint('Inserting default mechanic...');
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
    debugPrint('Default mechanic inserted successfully');
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

    // Insert sample job tasks
    final jobTasks = [
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

    for (var task in jobTasks) {
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

    // Insert sample tasks using the shared method
    await _insertSampleTasks(db);
  }

  // Mechanic operations
  Future<Map<String, dynamic>?> authenticateMechanic(String email, String password) async {
    final db = await database;
    debugPrint('Attempting to authenticate mechanic with email: $email');
    
    final result = await db.query(
      'mechanics',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (result.isNotEmpty) {
      debugPrint('Mechanic found: ${result.first['name']}');
      return result.first;
    } else {
      debugPrint('No mechanic found with email: $email');
      // Let's also check if the email exists at all
      final emailCheck = await db.query(
        'mechanics',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (emailCheck.isEmpty) {
        debugPrint('Email $email does not exist in database');
      } else {
        debugPrint('Email exists but password is incorrect');
      }
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

  Future<String?> registerMechanic({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required int experienceYears,
  }) async {
    final db = await database;
    debugPrint('Attempting to register new mechanic: $email');
    
    try {
      // Check if email already exists
      final existingMechanic = await db.query(
        'mechanics',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existingMechanic.isNotEmpty) {
        debugPrint('Email $email already exists');
        return null; // Email already exists
      }
      
      // Generate unique ID
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final createdAt = DateTime.now().toIso8601String();
      
      // Insert new mechanic
      await db.insert('mechanics', {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'specialization': specialization,
        'experience_years': experienceYears,
        'created_at': createdAt,
      });
      
      debugPrint('Mechanic registered successfully: $name ($email)');
      return id;
    } catch (e) {
      debugPrint('Error registering mechanic: $e');
      return null;
    }
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

  // Utility methods
  Future<bool> verifyDatabaseIntegrity() async {
    try {
      final db = await database;
      
      // Check if mechanics table exists and has data
      final mechanicsCount = await db.rawQuery('SELECT COUNT(*) as count FROM mechanics');
      final count = mechanicsCount.first['count'] as int;
      
      debugPrint('Database verification: Found $count mechanics');
      
      if (count == 0) {
        debugPrint('No mechanics found, reinitializing...');
        await _insertDefaultMechanic(db);
        return true;
      }
      
      return count > 0;
    } catch (e) {
      debugPrint('Database verification failed: $e');
      return false;
    }
  }

  Future<void> resetDatabase() async {
    try {
      final db = await database;
      await db.delete('mechanics');
      await db.delete('jobs');
      await db.delete('job_tasks');
      await db.delete('job_parts');
      await db.delete('service_records');
      await db.delete('job_notes');
      await db.delete('tasks');
      await _insertDefaultMechanic(db);
      await _insertSampleData(db);
      debugPrint('Database reset completed with sample tasks');
    } catch (e) {
      debugPrint('Database reset failed: $e');
    }
  }

  Future<void> recreateDatabase() async {
    try {
      // Close the current database
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Delete the database file
      String path = join(await getDatabasesPath(), 'wms_mechanic.db');
      await databaseFactory.deleteDatabase(path);
      
      // Recreate the database
      _database = await _initDatabase();
      debugPrint('Database recreated successfully');
    } catch (e) {
      debugPrint('Database recreation failed: $e');
    }
  }

  // Task operations
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final taskMaps = await db.query('tasks', orderBy: 'created_at DESC');
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return Task.fromMap(result.first);
    }
    return null;
  }

  Future<List<Task>> getTasksByJobId(String jobId) async {
    final db = await database;
    final taskMaps = await db.query(
      'tasks',
      where: 'job_id = ?',
      whereArgs: [jobId],
      orderBy: 'created_at DESC',
    );
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await database;
    final taskMaps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status.toString().split('.').last],
      orderBy: 'created_at DESC',
    );
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final db = await database;
    final taskMaps = await db.query(
      'tasks',
      where: 'priority = ?',
      whereArgs: [priority.toString().split('.').last],
      orderBy: 'created_at DESC',
    );
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final db = await database;
    final taskMaps = await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category.toString().split('.').last],
      orderBy: 'created_at DESC',
    );
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getOverdueTasks() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final taskMaps = await db.query(
      'tasks',
      where: 'due_date < ? AND status != ?',
      whereArgs: [now, TaskStatus.completed.toString().split('.').last],
      orderBy: 'due_date ASC',
    );
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getDueTodayTasks() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    final taskMaps = await db.query(
      'tasks',
      where: 'due_date >= ? AND due_date <= ? AND status != ?',
      whereArgs: [startOfDay, endOfDay, TaskStatus.completed.toString().split('.').last],
      orderBy: 'due_date ASC',
    );
    
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> updateTaskRecord(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final db = await database;
    final updateData = {
      'status': status.toString().split('.').last,
    };
    
    if (status == TaskStatus.completed) {
      updateData['completed_at'] = DateTime.now().toIso8601String();
    }
    
    await db.update(
      'tasks',
      updateData,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> updateTaskPriority(String taskId, TaskPriority priority) async {
    final db = await database;
    await db.update(
      'tasks',
      {'priority': priority.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> updateTaskDuration(String taskId, int actualDurationMinutes) async {
    final db = await database;
    await db.update(
      'tasks',
      {'actual_duration_minutes': actualDurationMinutes},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
