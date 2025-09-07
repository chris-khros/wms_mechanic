import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _currentMechanic;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  Map<String, dynamic>? get currentMechanic => _currentMechanic;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  String get mechanicName => _currentMechanic?['name'] ?? 'Unknown';
  String get mechanicEmail => _currentMechanic?['email'] ?? '';
  String get mechanicPhone => _currentMechanic?['phone'] ?? '';
  String get mechanicSpecialization => _currentMechanic?['specialization'] ?? '';
  int get mechanicExperience => _currentMechanic?['experience_years'] ?? 0;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ensure database is initialized and verified
      await _dbHelper.database;
      await _dbHelper.verifyDatabaseIntegrity();
      
      final prefs = await SharedPreferences.getInstance();
      final mechanicId = prefs.getString('mechanic_id');
      
      if (mechanicId != null) {
        final mechanic = await _dbHelper.getMechanicById(mechanicId);
        if (mechanic != null) {
          _currentMechanic = mechanic;
          _isAuthenticated = true;
          debugPrint('Auto-login successful for: ${mechanic['name']}');
        } else {
          // Clear invalid stored ID
          await prefs.remove('mechanic_id');
          debugPrint('Invalid stored mechanic ID, cleared');
        }
      } else {
        debugPrint('No stored mechanic ID found');
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ensure database is initialized and verified
      await _dbHelper.database;
      await _dbHelper.verifyDatabaseIntegrity();
      
      final mechanic = await _dbHelper.authenticateMechanic(email, password);
      
      if (mechanic != null) {
        _currentMechanic = mechanic;
        _isAuthenticated = true;
        
        // Store mechanic ID for auto-login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mechanic_id', mechanic['id']);
        
        debugPrint('Login successful for: ${mechanic['name']}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Login failed: Invalid credentials for $email');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mechanic_id');
      
      _currentMechanic = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String specialization,
    required int experienceYears,
  }) async {
    if (_currentMechanic == null) return false;

    try {
      // In a real app, you would update the database here
      // For now, we'll just update the local state
      _currentMechanic = {
        ..._currentMechanic!,
        'name': name,
        'phone': phone,
        'specialization': specialization,
        'experience_years': experienceYears,
      };
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Profile update error: $e');
      return false;
    }
  }
}
