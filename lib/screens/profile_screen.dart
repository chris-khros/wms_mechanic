import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/skills_widget.dart';
import '../widgets/preferences_widget.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProfileScreen.routeName);
            },
            tooltip: 'Edit Profile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.routeName,
                      (route) => false,
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    profileProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.clearError();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userProfile = profileProvider.userProfile;
          if (userProfile == null) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: ProfilePictureWidget(
                    profilePicturePath: userProfile.profilePicturePath,
                    onTap: () => _showProfilePictureOptions(context, profileProvider),
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Information
                ProfileInfoCard(
                  title: 'Basic Information',
                  icon: Icons.person,
                  children: [
                    _buildInfoRow('Name', userProfile.name),
                    _buildInfoRow('Email', userProfile.email),
                    if (userProfile.phoneNumber != null)
                      _buildInfoRow('Phone', userProfile.phoneNumber!),
                    if (userProfile.address != null)
                      _buildInfoRow('Address', userProfile.address!),
                    if (userProfile.dateOfBirth != null)
                      _buildInfoRow('Date of Birth', 
                        '${userProfile.dateOfBirth!.day}/${userProfile.dateOfBirth!.month}/${userProfile.dateOfBirth!.year}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Professional Information
                ProfileInfoCard(
                  title: 'Professional Information',
                  icon: Icons.work,
                  children: [
                    if (userProfile.employeeId != null)
                      _buildInfoRow('Employee ID', userProfile.employeeId!),
                    if (userProfile.department != null)
                      _buildInfoRow('Department', userProfile.department!),
                    if (userProfile.position != null)
                      _buildInfoRow('Position', userProfile.position!),
                    if (userProfile.hireDate != null)
                      _buildInfoRow('Hire Date', 
                        '${userProfile.hireDate!.day}/${userProfile.hireDate!.month}/${userProfile.hireDate!.year}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Skills Section
                if (userProfile.skills.isNotEmpty)
                  SkillsWidget(skills: userProfile.skills),
                const SizedBox(height: 16),

                // Preferences Section
                PreferencesWidget(preferences: userProfile.preferences),
                const SizedBox(height: 24),

                // Action Buttons
                Center(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(EditProfileScreen.routeName);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => _showResetDialog(context, profileProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Profile'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfilePictureOptions(BuildContext context, ProfileProvider profileProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                profileProvider.takeAndSaveProfilePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                profileProvider.pickAndSaveProfilePicture();
              },
            ),
            if (profileProvider.userProfile?.profilePicturePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  profileProvider.removeProfilePicture();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text('Are you sure you want to reset your profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              profileProvider.resetProfile();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
} 