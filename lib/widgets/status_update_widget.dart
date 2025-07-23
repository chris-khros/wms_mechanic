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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Job Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusDropdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JobStatus>(
          value: job.status,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
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
                  const SizedBox(width: 8),
                  Text(_getStatusText(value)),
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
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
        return Colors.blue;
      case JobStatus.inProgress:
        return Colors.green;
      case JobStatus.onHold:
        return Colors.orange;
      case JobStatus.completed:
        return Colors.purple;
    }
  }
} 