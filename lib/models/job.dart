enum JobStatus {
  accepted,
  inProgress,
  onHold,
  completed
}

class JobNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final String? photoPath;
  
  JobNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.photoPath,
  });
}

class Job {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleModel;
  final String vehiclePlate;
  final String description;
  final List<JobTask> tasks;
  final List<JobPart> parts;
  final List<ServiceRecord> serviceHistory;
  final List<JobNote> notes;
  String? customerSignature;
  String? customerSignatureImageData; // Base64 encoded image data
  DateTime? signatureDate;
  String? signatureBy; // Who signed (customer name)
  bool isSignedOff;
  JobStatus status;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.description,
    required this.tasks,
    required this.parts,
    required this.serviceHistory,
    this.notes = const [],
    this.customerSignature,
    this.customerSignatureImageData,
    this.signatureDate,
    this.signatureBy,
    this.isSignedOff = false,
    required this.status,
    required this.createdAt,
  });
}

class JobTask {
  final String id;
  final String name;
  final String description;
  int timeSpentSeconds;
  bool isRunning;
  DateTime? lastStartTime;

  JobTask({
    required this.id,
    required this.name,
    required this.description,
    this.timeSpentSeconds = 0,
    this.isRunning = false,
    this.lastStartTime,
  });

  void startTimer() {
    if (!isRunning) {
      isRunning = true;
      lastStartTime = DateTime.now();
    }
  }

  void pauseTimer() {
    if (isRunning && lastStartTime != null) {
      isRunning = false;
      final now = DateTime.now();
      timeSpentSeconds += now.difference(lastStartTime!).inSeconds;
      lastStartTime = null;
    }
  }

  void stopTimer() {
    pauseTimer();
    timeSpentSeconds = 0;
  }
}

class JobPart {
  final String id;
  final String name;
  final int quantity;
  final double price;

  JobPart({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class ServiceRecord {
  final String id;
  final DateTime date;
  final String description;
  final String technician;
  final double cost;

  ServiceRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.technician,
    required this.cost,
  });
} 