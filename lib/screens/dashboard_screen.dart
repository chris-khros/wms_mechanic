import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';
import 'job_sections_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              _buildSliverAppBar(),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTodaysJobsList(),
              _buildWeeksJobsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SliverAppBar(
          expandedHeight: 280.0,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with profile
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.mechanicName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(ProfileScreen.routeName);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Stats Cards
                      _buildStatsCards(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF667eea),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF667eea),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: "Today's Jobs"),
                  Tab(text: "This Week's Jobs"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer<JobsProvider>(
      builder: (context, jobsProvider, child) {
        final todaysJobs = jobsProvider.todaysJobs;
        final completedToday = todaysJobs.where((job) => job.status == JobStatus.completed).length;
        final inProgressToday = todaysJobs.where((job) => job.status == JobStatus.inProgress).length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Jobs',
                          todaysJobs.length.toString(),
                          Icons.today,
                          const Color(0xFF11998e),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'In Progress',
                          inProgressToday.toString(),
                          Icons.play_circle_outline,
                          const Color(0xFFffecd2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Completed',
                          completedToday.toString(),
                          Icons.check_circle_outline,
                          const Color(0xFF38ef7d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Today\'s Jobs',
                    todaysJobs.length.toString(),
                    Icons.today,
                    const Color(0xFF11998e),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'In Progress',
                    inProgressToday.toString(),
                    Icons.play_circle_outline,
                    const Color(0xFFffecd2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    completedToday.toString(),
                    Icons.check_circle_outline,
                    const Color(0xFF38ef7d),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaysJobsList() {
    return Consumer<JobsProvider>(
      builder: (ctx, jobsProvider, _) {
        if (jobsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }

        final todaysJobs = jobsProvider.todaysJobs;
        return _buildJobList(todaysJobs, 'No jobs scheduled for today');
      },
    );
  }

  Widget _buildWeeksJobsList() {
    return Consumer<JobsProvider>(
      builder: (ctx, jobsProvider, _) {
        if (jobsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }

        return _buildJobList(jobsProvider.thisWeeksJobs, 'No jobs scheduled for this week');
      },
    );
  }

  Widget _buildJobList(List<Job> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.work_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a break or check upcoming jobs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<JobsProvider>(context, listen: false).refreshJobs();
      },
      color: const Color(0xFF667eea),
      child: ListView.builder(
        itemCount: jobs.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (ctx, index) {
          final job = jobs[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: JobCard(
                      job: job,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          JobSectionsScreen.routeName,
                          arguments: job.id,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}