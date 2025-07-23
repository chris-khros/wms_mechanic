import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';
import '../widgets/task_timer_widget.dart';
import '../widgets/status_update_widget.dart';
import '../widgets/job_notes_widget.dart';
import '../widgets/signature_pad_widget.dart';

class JobDetailsScreen extends StatelessWidget {
  static const routeName = '/job-details';

  const JobDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;
    final jobsProvider = Provider.of<JobsProvider>(context);
    final job = jobsProvider.getJobById(jobId);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Job Not Found'),
        ),
        body: const Center(
          child: Text('The job you requested was not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Job ${job.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            _buildStatusIndicator(job),
            const SizedBox(height: 24),
            
            // Status Update Section
            StatusUpdateWidget(job: job),
            const SizedBox(height: 24),
            
            // Customer Information Section
            _buildSectionTitle('Customer Information'),
            _buildCustomerInfo(job),
            const SizedBox(height: 24),
            
            // Vehicle Information Section
            _buildSectionTitle('Vehicle Information'),
            _buildVehicleInfo(job),
            const SizedBox(height: 24),
            
            // Job Description Section
            _buildSectionTitle('Job Description'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(job.description),
              ),
            ),
            const SizedBox(height: 24),
            
            // Requested Services Section with Time Tracking
            _buildSectionTitle('Requested Services'),
            _buildTasksListWithTimers(context, job),
            const SizedBox(height: 24),
            
            // Parts Section
            _buildSectionTitle('Parts'),
            _buildPartsList(job),
            const SizedBox(height: 24),
            
            // Service History Section
            _buildSectionTitle('Service History'),
            _buildServiceHistory(job),
            const SizedBox(height: 24),
            
            // Notes & Photos Section
            JobNotesWidget(job: job),
            const SizedBox(height: 24),
            
            // Customer Sign-off Section
            SignaturePadWidget(job: job),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Job job) {
    Color statusColor;
    String statusText;
    
    switch (job.status) {
      case JobStatus.accepted:
        statusColor = Colors.blue;
        statusText = 'Accepted';
        break;
      case JobStatus.inProgress:
        statusColor = Colors.green;
        statusText = 'In Progress';
        break;
      case JobStatus.onHold:
        statusColor = Colors.orange;
        statusText = 'On Hold';
        break;
      case JobStatus.completed:
        statusColor = Colors.purple;
        statusText = 'Completed';
        break;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: statusColor),
          const SizedBox(width: 8),
          Text(
            'Status: $statusText',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Job job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', job.customerName),
            const SizedBox(height: 8),
            _buildInfoRow('Phone', job.customerPhone),
            const SizedBox(height: 8),
            _buildInfoRow('Customer ID', job.customerId),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(Job job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Model', job.vehicleModel),
            const SizedBox(height: 8),
            _buildInfoRow('Plate Number', job.vehiclePlate),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(Job job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: job.tasks.map((task) => _buildTaskItem(task)).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskItem(JobTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(task.description),
          const Divider(),
        ],
      ),
    );
  }
  
  Widget _buildTasksListWithTimers(BuildContext context, Job job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: job.tasks.map((task) => _buildTaskItemWithTimer(context, job, task)).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskItemWithTimer(BuildContext context, Job job, JobTask task) {
    final jobsProvider = Provider.of<JobsProvider>(context, listen: false);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(task.description),
              const SizedBox(height: 12),
              
              // Timer Widget
              TaskTimerWidget(
                task: task,
                jobId: job.id,
                onTaskUpdated: (updatedTask) {
                  jobsProvider.updateTaskTimer(job.id, task.id, updatedTask);
                },
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPartsList(Job job) {
    if (job.parts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('No parts assigned to this job.'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Table Header
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Part Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Qty',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const Divider(),
            // Table Content
            ...job.parts.map((part) => _buildPartRow(part)).toList(),
            const Divider(),
            // Total Price Row
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 5,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${_calculateTotalPartsPrice(job.parts).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalPartsPrice(List<JobPart> parts) {
    return parts.fold(0.0, (total, part) => total + (part.price * part.quantity));
  }

  Widget _buildPartRow(JobPart part) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(part.name),
          ),
          Expanded(
            flex: 1,
            child: Text('${part.quantity}'),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${(part.price * part.quantity).toStringAsFixed(2)}',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistory(Job job) {
    if (job.serviceHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('No service history available for this vehicle.'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: job.serviceHistory.map((record) => _buildServiceRecord(record)).toList(),
        ),
      ),
    );
  }

  Widget _buildServiceRecord(ServiceRecord record) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateFormat.format(record.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${record.cost.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(record.description),
        const SizedBox(height: 4),
        Text('Technician: ${record.technician}'),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
} 