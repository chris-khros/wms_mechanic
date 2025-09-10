import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class PreferencesWidget extends StatefulWidget {
  final Map<String, dynamic> preferences;

  const PreferencesWidget({
    Key? key,
    required this.preferences,
  }) : super(key: key);

  @override
  State<PreferencesWidget> createState() => _PreferencesWidgetState();
}

class _PreferencesWidgetState extends State<PreferencesWidget> {
  Timer? _autoSaveTimer;

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.preferences.entries.map((entry) => _buildPreferenceRow(entry.key, entry.value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceRow(String key, dynamic value) {
    String displayName = _getDisplayName(key);
    IconData icon = _getIcon(key);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value is bool)
            Switch(
              value: value,
              onChanged: (newValue) {
                _updatePreference(key, newValue);
              },
              activeColor: Colors.blue,
            )
          else if (key == 'language')
            _buildLanguageSelector(value)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(String currentLanguage) {
    return DropdownButton<String>(
      value: currentLanguage,
      onChanged: (String? newValue) {
        if (newValue != null) {
          _updatePreference('language', newValue);
        }
      },
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'zh', child: Text('中文')),
        DropdownMenuItem(value: 'ms', child: Text('Bahasa Malaysia')),
      ],
    );
  }

  void _updatePreference(String key, dynamic value) {
    setState(() {
      widget.preferences[key] = value;
    });
    _debounceAutoSave();
  }

  void _debounceAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      _autoSavePreferences();
    });
  }

  void _autoSavePreferences() async {
    try {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updatePreferences(widget.preferences);
      // Silent auto-save - no success message
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error auto-saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDisplayName(String key) {
    switch (key) {
      case 'notifications':
        return 'Push Notifications';
      case 'darkMode':
        return 'Dark Mode';
      case 'language':
        return 'Language';
      case 'autoSave':
        return 'Auto Save';
      default:
        return key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
    }
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'notifications':
        return Icons.notifications;
      case 'darkMode':
        return Icons.dark_mode;
      case 'language':
        return Icons.language;
      case 'autoSave':
        return Icons.save;
      default:
        return Icons.settings;
    }
  }
}