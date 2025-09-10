import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';

class StatusUpdateWidget extends StatelessWidget {
  final Job job;

  const StatusUpdateWidget({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.update,
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Update Job Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusDropdown(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JobStatus>(
          value: job.status,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
          ),
          elevation: 16,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w500,
          ),
          onChanged: (JobStatus? newValue) {
            if (newValue != null && newValue != job.status) {
              _updateJobStatus(context, newValue);
            }
          },
          items: JobStatus.values.map<DropdownMenuItem<JobStatus>>((JobStatus value) {
            return DropdownMenuItem<JobStatus>(
              value: value,
              child: Row(
                children: [
                  _buildStatusIndicator(value),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusText(value),
                    style: const TextStyle(
                      color: Color(0xFF2D3748),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(JobStatus status) {
    Color color = _getStatusColor(status);
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _updateJobStatus(BuildContext context, JobStatus newStatus) {
    final jobsProvider = Provider.of<JobsProvider>(context, listen: false);
    jobsProvider.updateJobStatus(job.id, newStatus);
    
    // Show a snackbar to confirm the change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job status updated to ${_getStatusText(newStatus)}'),
        backgroundColor: _getStatusColor(newStatus),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return 'Accepted';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.onHold:
        return 'On Hold';
      case JobStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return const Color(0xFF3B82F6); // Blue
      case JobStatus.inProgress:
        return const Color(0xFF10B981); // Green
      case JobStatus.onHold:
        return const Color(0xFFF59E0B); // Amber
      case JobStatus.completed:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
} 