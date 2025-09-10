import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_picture_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  static const routeName = '/edit-profile';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _employeeIdController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedHireDate;
  List<String> _skills = [];
  Timer? _autoSaveTimer;
  final List<String> _availableSkills = [
    'Engine Repair',
    'Transmission Service',
    'Brake Systems',
    'Electrical Diagnostics',
    'HVAC Systems',
    'Hydraulic Systems',
    'Welding',
    'Diagnostic Tools',
    'Preventive Maintenance',
    'Customer Service',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = context.read<ProfileProvider>().userProfile;
    if (profile != null) {
      _nameController = TextEditingController(text: profile.name);
      _emailController = TextEditingController(text: profile.email);
      _phoneController = TextEditingController(text: profile.phoneNumber ?? '');
      _addressController = TextEditingController(text: profile.address ?? '');
      _employeeIdController = TextEditingController(text: profile.employeeId ?? '');
      _departmentController = TextEditingController(text: profile.department ?? '');
      _positionController = TextEditingController(text: profile.position ?? '');
      _selectedDateOfBirth = profile.dateOfBirth;
      _selectedHireDate = profile.hireDate;
      _skills = List.from(profile.skills);
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
      _employeeIdController = TextEditingController();
      _departmentController = TextEditingController();
      _positionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        ProfilePictureWidget(
                          profilePicturePath: profileProvider.userProfile?.profilePicturePath,
                          onTap: () => _showProfilePictureOptions(context, profileProvider),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showProfilePictureOptions(context, profileProvider),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Change Photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information Section
                  _buildSectionTitle('Basic Information', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Date of Birth',
                    icon: Icons.cake,
                    selectedDate: _selectedDateOfBirth,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDateOfBirth = date;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Professional Information Section
                  _buildSectionTitle('Professional Information', Icons.work),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _employeeIdController,
                    label: 'Employee ID',
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _departmentController,
                    label: 'Department',
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _positionController,
                    label: 'Position',
                    icon: Icons.work,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Hire Date',
                    icon: Icons.event,
                    selectedDate: _selectedHireDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedHireDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Skills Section
                  _buildSectionTitle('Skills & Expertise', Icons.psychology),
                  const SizedBox(height: 16),
                  _buildSkillsSelector(),
                  const SizedBox(height: 24),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: (value) {
        // Auto-save on text change with debouncing
        _debounceAutoSave();
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
          _debounceAutoSave();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your skills:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSkills.map((skill) {
            final isSelected = _skills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _skills.add(skill);
                  } else {
                    _skills.remove(skill);
                  }
                });
                _debounceAutoSave();
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
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

  void _debounceAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      _autoSaveProfile();
    });
  }

  void _autoSaveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final currentProfile = profileProvider.userProfile;
    
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      employeeId: _employeeIdController.text.trim().isEmpty ? null : _employeeIdController.text.trim(),
      department: _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim(),
      position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
      dateOfBirth: _selectedDateOfBirth,
      hireDate: _selectedHireDate,
      skills: _skills,
    );

    await profileProvider.updateProfile(updatedProfile);
    
    // Silent auto-save - no success message or navigation
  }
} 