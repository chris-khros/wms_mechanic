import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';
import 'job_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Mechanic'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Today's Jobs"),
            Tab(text: "This Week's Jobs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodaysJobsList(),
          _buildWeeksJobsList(),
        ],
      ),
    );
  }

  Widget _buildTodaysJobsList() {
    return Consumer<JobsProvider>(
      builder: (ctx, jobsProvider, _) {
        final todaysJobs = jobsProvider.todaysJobs;
        return _buildJobList(todaysJobs, 'No jobs scheduled for today');
      },
    );
  }

  Widget _buildWeeksJobsList() {
    return Consumer<JobsProvider>(
      builder: (ctx, jobsProvider, _) {
        final weeksJobs = jobsProvider.thisWeeksJobs;
        return _buildJobList(weeksJobs, 'No jobs scheduled for this week');
      },
    );
  }

  Widget _buildJobList(List<Job> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: jobs.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (ctx, index) {
        final job = jobs[index];
        return JobCard(
          job: job,
          onTap: () {
            Navigator.of(context).pushNamed(
              JobDetailsScreen.routeName,
              arguments: job.id,
            );
          },
        );
      },
    );
  }
} 