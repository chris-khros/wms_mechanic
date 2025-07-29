import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';

class JobNotesWidget extends StatefulWidget {
  final Job job;

  const JobNotesWidget({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  State<JobNotesWidget> createState() => _JobNotesWidgetState();
}

class _JobNotesWidgetState extends State<JobNotesWidget> {
  final TextEditingController _noteController = TextEditingController();
  String? _selectedImagePath;
  bool _isAddingNote = false;
  
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
  
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // Request permission
    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      _showPermissionDialog('Camera');
      return false;
    }
    
    return status.isGranted;
  }
  
  Future<bool> _requestPhotosPermission() async {
    // For Android 13+, check for photos permission
    if (Platform.isAndroid) {
      var status = await Permission.photos.status;
      
      if (status.isGranted) {
        return true;
      }
      
      // Request permission
      status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        _showPermissionDialog('Photos');
        return false;
      }
      
      return status.isGranted;
    }
    
    // For iOS, check photo library permission
    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      
      if (status.isGranted) {
        return true;
      }
      
      status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        _showPermissionDialog('Photos');
        return false;
      }
      
      return status.isGranted;
    }
    
    return true; // Default for other platforms
  }
  
  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'To use this feature, you need to enable $permissionType permission in app settings.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _takePhoto() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (photo != null) {
        if (!mounted) return;
        setState(() {
          _selectedImagePath = photo.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _pickPhoto() async {
    final hasPermission = await _requestPhotosPermission();
    if (!hasPermission) {
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (!mounted) return;
        setState(() {
          _selectedImagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error selecting photo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _addNote() {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if selected image path is valid before proceeding
    String? photoPath = _selectedImagePath;
    if (photoPath != null) {
      final file = File(photoPath);
      if (!file.existsSync()) {
        // If file doesn't exist, don't use it
        photoPath = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo file not accessible. Saving note without photo.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
    
    final jobsProvider = Provider.of<JobsProvider>(context, listen: false);
    jobsProvider.addJobNote(widget.job.id, note, photoPath);
    
    // Clear the inputs
    _noteController.clear();
    setState(() {
      _selectedImagePath = null;
      _isAddingNote = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notes & Photos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (!_isAddingNote)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Note'),
                    onPressed: () {
                      setState(() {
                        _isAddingNote = true;
                      });
                    },
                  ),
              ],
            ),
            if (_isAddingNote) _buildAddNoteForm(),
            const SizedBox(height: 16),
            _buildNotesList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddNoteForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Enter note',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              onPressed: _takePhoto,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              onPressed: _pickPhoto,
            ),
          ],
        ),
        if (_selectedImagePath != null) 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildImagePreview(_selectedImagePath!),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedImagePath = null;
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isAddingNote = false;
                  _selectedImagePath = null;
                  _noteController.clear();
                });
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addNote,
              child: const Text('Save Note'),
            ),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }
  
  Widget _buildImagePreview(String imagePath) {
    final file = File(imagePath);
    
    try {
      // Check if file exists and is accessible
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Handle image loading errors
              return const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        );
      } else {
        return const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        );
      }
    } catch (e) {
      // Handle any errors during file checking
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }
  
  Widget _buildNotesList() {
    if (widget.job.notes.isEmpty) {
      return const Center(
        child: Text('No notes added yet'),
      );
    }
    
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.job.notes.length,
      itemBuilder: (ctx, index) {
        final note = widget.job.notes[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.comment, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(note.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(note.content),
            ),
            if (note.photoPath != null) 
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 8.0),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildImagePreview(note.photoPath!),
                ),
              ),
            const Divider(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
} 