class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePicturePath;
  final String? employeeId;
  final String? department;
  final String? position;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime? hireDate;
  final List<String> skills;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePicturePath,
    this.employeeId,
    this.department,
    this.position,
    this.address,
    this.dateOfBirth,
    this.hireDate,
    this.skills = const [],
    this.preferences = const {},
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicturePath,
    String? employeeId,
    String? department,
    String? position,
    String? address,
    DateTime? dateOfBirth,
    DateTime? hireDate,
    List<String>? skills,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      position: position ?? this.position,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hireDate: hireDate ?? this.hireDate,
      skills: skills ?? this.skills,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicturePath': profilePicturePath,
      'employeeId': employeeId,
      'department': department,
      'position': position,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'hireDate': hireDate?.toIso8601String(),
      'skills': skills,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      profilePicturePath: json['profilePicturePath'],
      employeeId: json['employeeId'],
      department: json['department'],
      position: json['position'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      hireDate: json['hireDate'] != null 
          ? DateTime.parse(json['hireDate']) 
          : null,
      skills: List<String>.from(json['skills'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      name: '',
      email: '',
    );
  }
} 