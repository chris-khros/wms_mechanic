import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import 'auth_provider.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  AuthProvider? _authProvider;
  VoidCallback? _authListener;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _userProfile != null && _userProfile!.name.isNotEmpty;
  bool get isAuthenticated => _authProvider?.isAuthenticated ?? false;

  static const String _profileKey = 'user_profile';

  ProfileProvider() {
    _loadProfile();
  }

  void setAuthProvider(AuthProvider authProvider) {
    // Detach previous listener if any
    if (_authProvider != null && _authListener != null) {
      _authProvider!.removeListener(_authListener!);
    }

    _authProvider = authProvider;

    // Set up a listener so we react whenever auth state changes (login/logout)
    _authListener = _onAuthChanged;
    _authProvider!.addListener(_authListener!);

    // Try to sync immediately with the current auth state
    _syncWithAuthProvider();
  }

  Future<void> _loadProfile() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      if (profileJson != null) {
        final profileData = json.decode(profileJson);
        _userProfile = UserProfile.fromJson(profileData);
      } else {
        // Create profile from AuthProvider data if available
        await _createProfileFromAuth();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createProfileFromAuth() async {
    if (_authProvider?.isAuthenticated == true && _authProvider?.currentMechanic != null) {
      final mechanic = _authProvider!.currentMechanic!;
      
      _userProfile = UserProfile(
        id: mechanic['id'] ?? '1',
        name: mechanic['name'] ?? 'Unknown User',
        email: mechanic['email'] ?? '',
        phoneNumber: mechanic['phone'] ?? '',
        employeeId: mechanic['id'] ?? '',
        department: 'Mechanical Services',
        position: 'Mechanic',
        skills: _parseSkillsFromSpecialization(mechanic['specialization'] ?? ''),
        preferences: {
          'notifications': true,
          'darkMode': false,
          'language': 'en',
          'autoSave': true,
        },
      );
      await _saveProfile();
    } else {
      // Create a default profile for demo purposes if not authenticated
      _userProfile = UserProfile(
        id: '1',
        name: 'Demo User',
        email: 'demo@wms.com',
        phoneNumber: '+1 (555) 123-4567',
        employeeId: 'DEMO001',
        department: 'Mechanical Services',
        position: 'Demo Mechanic',
        address: '123 Workshop St, City, State 12345',
        dateOfBirth: DateTime(1990, 5, 15),
        hireDate: DateTime(2020, 3, 1),
        skills: [
          'Engine Repair',
          'Transmission Service',
          'Brake Systems',
          'Electrical Diagnostics',
          'HVAC Systems',
          'Hydraulic Systems',
        ],
        preferences: {
          'notifications': true,
          'darkMode': false,
          'language': 'en',
          'autoSave': true,
        },
      );
      await _saveProfile();
    }
  }

  void _onAuthChanged() {
    // When auth changes, rebuild profile from current mechanic or clear it on logout
    if (_authProvider?.isAuthenticated == true && _authProvider?.currentMechanic != null) {
      _createProfileFromAuth();
    } else {
      resetProfile();
    }
  }

  void _syncWithAuthProvider() {
    if (_authProvider?.isAuthenticated == true && _authProvider?.currentMechanic != null) {
      final mechanic = _authProvider!.currentMechanic!;
      
      // Update profile with current auth data
      if (_userProfile != null) {
        _userProfile = _userProfile!.copyWith(
          name: mechanic['name'] ?? _userProfile!.name,
          email: mechanic['email'] ?? _userProfile!.email,
          phoneNumber: mechanic['phone'] ?? _userProfile!.phoneNumber,
        );
        _saveProfile();
      } else {
        _createProfileFromAuth();
      }
    }
  }

  List<String> _parseSkillsFromSpecialization(String specialization) {
    if (specialization.isEmpty) {
      return [
        'Engine Repair',
        'Transmission Service',
        'Brake Systems',
        'Electrical Diagnostics',
      ];
    }
    
    // Parse specialization into skills
    return specialization.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_userProfile!.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      _error = 'Failed to save profile: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    try {
      _userProfile = updatedProfile;
      await _saveProfile();
      _error = null;
    } catch (e) {
      _error = 'Failed to update profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBasicInfo({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
  }) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> updateProfessionalInfo({
    String? employeeId,
    String? department,
    String? position,
    DateTime? hireDate,
  }) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(
      employeeId: employeeId,
      department: department,
      position: position,
      hireDate: hireDate,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> updateSkills(List<String> skills) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(skills: skills);
    await updateProfile(updatedProfile);
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(preferences: preferences);
    await updateProfile(updatedProfile);
  }

  Future<void> updateProfilePicture(String imagePath) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(profilePicturePath: imagePath);
    await updateProfile(updatedProfile);
  }

  Future<String?> pickAndSaveProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await updateProfilePicture(image.path);
        return image.path;
      }
      return null;
    } catch (e) {
      _error = 'Failed to pick image: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> takeAndSaveProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await updateProfilePicture(image.path);
      }
    } catch (e) {
      _error = 'Failed to take photo: $e';
      notifyListeners();
    }
  }

  Future<void> removeProfilePicture() async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(profilePicturePath: null);
    await updateProfile(updatedProfile);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> resetProfile() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      _userProfile = null;
      _error = null;
    } catch (e) {
      _error = 'Failed to reset profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    if (_authProvider != null && _authListener != null) {
      _authProvider!.removeListener(_authListener!);
    }
    super.dispose();
  }
} 