import 'package:flutter/material.dart';

class PreferencesWidget extends StatelessWidget {
  final Map<String, dynamic> preferences;

  const PreferencesWidget({
    Key? key,
    required this.preferences,
  }) : super(key: key);

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
              ...preferences.entries.map((entry) => _buildPreferenceRow(entry.key, entry.value)),
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
              onChanged: null, // Read-only for now
              activeColor: Colors.blue,
            )
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