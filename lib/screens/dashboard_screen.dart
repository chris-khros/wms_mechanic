import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
          expandedHeight: 360.0,
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
                                  AppLocalizations.of(context).welcome + ',',
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
                          Row(
                            children: [
                              Consumer<LocaleProvider>(
                                builder: (context, localeProvider, child) {
                                  return GestureDetector(
                                    onTap: () => _showLanguageSelector(context, localeProvider),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.language,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      themeProvider.toggleTheme();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        themeProvider.isDarkMode 
                                            ? Icons.light_mode 
                                            : Icons.dark_mode,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Stats Cards
                      _buildStatsCards(),
                      const SizedBox(height: 20),
                      
                      // Quick Actions
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                tabs: [
                  Tab(text: AppLocalizations.of(context).activeJobs),
                  Tab(text: AppLocalizations.of(context).completedJobs),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
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
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.work_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a break or check upcoming jobs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Task Management',
            'Manage your tasks',
            Icons.task_alt,
            const Color(0xFF667eea),
            () {
              Navigator.of(context).pushNamed('/tasks');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'Add Task',
            'Create new task',
            Icons.add_task,
            const Color(0xFF38ef7d),
            () {
              Navigator.of(context).pushNamed('/add-task');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, LocaleProvider localeProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).language,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...LocaleProvider.supportedLocales.map((locale) {
              final isSelected = localeProvider.locale.languageCode == locale.languageCode;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                title: Text(LocaleProvider.languageNames[locale.languageCode] ?? locale.languageCode),
                onTap: () {
                  localeProvider.setLocale(locale);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}