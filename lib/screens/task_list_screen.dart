import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/task_card.dart';
import '../l10n/app_localizations.dart';
import 'add_task_screen.dart';
import 'task_details_screen.dart';
import 'profile_screen.dart';

class TaskListScreen extends StatefulWidget {
  static const routeName = '/tasks';
  
  final String? jobId; // Optional: if viewing tasks for a specific job

  const TaskListScreen({Key? key, this.jobId}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            _buildSliverAppBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(TaskStatus.pending),
            _buildTaskList(TaskStatus.inProgress),
            _buildTaskList(TaskStatus.completed),
            _buildAllTasksList(),
          ],
        ),
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isTablet = screenWidth > 600;
          final isDesktop = screenWidth > 1200;
          
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: isDesktop ? 24 : (isTablet ? 22 : 20),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _navigateToAddTask(),
              backgroundColor: const Color(0xFF667eea),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
              ),
              child: Icon(
                Icons.add, 
                color: Colors.white, 
                size: isDesktop ? 32 : (isTablet ? 30 : 28),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final isDesktop = screenWidth > 1200;
        
        return SliverAppBar(
          expandedHeight: isDesktop ? 320.0 : (isTablet ? 340.0 : 360.0),
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
                  padding: EdgeInsets.all(isDesktop ? 32.0 : (isTablet ? 24.0 : 20.0)),
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
                                  AppLocalizations.of(context).welcome,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.mechanicName,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
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
                                      padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.language,
                                        color: Colors.white,
                                        size: isDesktop ? 28 : (isTablet ? 26 : 24),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      themeProvider.toggleTheme();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        themeProvider.isDarkMode 
                                            ? Icons.light_mode 
                                            : Icons.dark_mode,
                                        color: Colors.white,
                                        size: isDesktop ? 28 : (isTablet ? 26 : 24),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(ProfileScreen.routeName);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: isDesktop ? 28 : (isTablet ? 26 : 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Task Management Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.task_alt,
                              color: Colors.white,
                              size: isDesktop ? 28 : (isTablet ? 26 : 24),
                            ),
                          ),
                          SizedBox(width: isDesktop ? 20 : (isTablet ? 18 : 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.jobId != null ? AppLocalizations.of(context).jobTasks : AppLocalizations.of(context).taskManagement,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.jobId != null 
                                      ? AppLocalizations.of(context).tasksForThisJob
                                      : AppLocalizations.of(context).manageTasksEfficiently,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70), // Increased height for better text visibility
            child: Container(
              height: 70, // Increased height to prevent text truncation
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false, // Disable scrolling to keep tabs fixed
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3, // Fixed indicator weight
                indicatorSize: TabBarIndicatorSize.label, // Fixed indicator size
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                tabAlignment: TabAlignment.fill, // Always fill available space
                tabs: [
                  Tab(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Text(
                        AppLocalizations.of(context).pending,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Text(
                        AppLocalizations.of(context).inProgress,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Text(
                        AppLocalizations.of(context).completed,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Text(
                        AppLocalizations.of(context).allTasks,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : (isTablet ? 18 : 16)),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isDesktop ? 12 : (isTablet ? 10 : 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: Colors.black87,
          fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchTasks,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(isDesktop ? 16 : (isTablet ? 14 : 12)),
            padding: EdgeInsets.all(isDesktop ? 12 : (isTablet ? 10 : 8)),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search,
              color: const Color(0xFF667eea),
              size: isDesktop ? 26 : (isTablet ? 24 : 22),
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(12),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      Provider.of<TasksProvider>(context, listen: false)
                          .setSearchQuery('');
                    },
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          Provider.of<TasksProvider>(context, listen: false).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildTaskList(TaskStatus? status) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        if (tasksProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }

        List<Task> tasks = tasksProvider.filteredTasks;
        
        // Filter by job ID if specified
        if (widget.jobId != null) {
          tasks = tasks.where((task) => task.jobId == widget.jobId).toList();
        }
        
        // Filter by status if specified
        if (status != null) {
          tasks = tasks.where((task) => task.status == status).toList();
        }

        if (tasks.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await tasksProvider.refreshTasks();
          },
          color: const Color(0xFF667eea),
          child: _buildResponsiveTaskList(tasks),
        );
      },
    );
  }

  Widget _buildAllTasksList() {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        if (tasksProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }

        List<Task> tasks = tasksProvider.filteredTasks;
        
        // Filter by job ID if specified
        if (widget.jobId != null) {
          tasks = tasks.where((task) => task.jobId == widget.jobId).toList();
        }

        if (tasks.isEmpty) {
          return _buildEmptyState(null);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await tasksProvider.refreshTasks();
          },
          color: const Color(0xFF667eea),
          child: _buildResponsiveTaskList(tasks),
        );
      },
    );
  }

  Widget _buildResponsiveTaskList(List<Task> tasks) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    // Calculate cross axis count based on screen size
    int crossAxisCount = 1; // Mobile
    if (isDesktop) {
      crossAxisCount = 3; // Desktop: 3 columns
    } else if (isTablet) {
      crossAxisCount = 2; // Tablet: 2 columns
    }
    
    if (crossAxisCount == 1) {
      // Use ListView for mobile
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : (isTablet ? 900 : 700)),
          child: ListView.builder(
            padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildAnimatedTaskCard(task, index);
            },
          ),
        ),
      );
    } else {
      // Use GridView for tablet and desktop
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1300 : 1100),
          child: GridView.builder(
            padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: isDesktop ? 1.1 : 1.0,
              crossAxisSpacing: isDesktop ? 20 : (isTablet ? 16 : 12),
              mainAxisSpacing: isDesktop ? 20 : (isTablet ? 16 : 12),
            ),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildAnimatedTaskCard(task, index);
            },
          ),
        ),
      );
    }
  }

  Widget _buildAnimatedTaskCard(Task task, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TaskCard(
              task: task,
              onTap: () => _showTaskDetails(task),
              onEdit: () => _editTask(task),
              onDelete: () => _deleteTask(task),
              onStatusChanged: (newStatus) => _updateTaskStatus(task, newStatus),
              onPriorityChanged: (newPriority) => _updateTaskPriority(task, newPriority),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TaskStatus? status) {
    String message;
    IconData icon;
    
    if (widget.jobId != null) {
      message = AppLocalizations.of(context).noTasksForJob;
      icon = Icons.work_off;
    } else {
      switch (status) {
        case TaskStatus.pending:
          message = AppLocalizations.of(context).noPendingTasks;
          icon = Icons.schedule;
          break;
        case TaskStatus.inProgress:
          message = AppLocalizations.of(context).noInProgressTasks;
          icon = Icons.play_circle_outline;
          break;
        case TaskStatus.completed:
          message = AppLocalizations.of(context).noCompletedTasks;
          icon = Icons.check_circle_outline;
          break;
        default:
          message = AppLocalizations.of(context).noTasks;
          icon = Icons.task_alt;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final isDesktop = screenWidth > 1200;
        
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 40 : 32)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 48 : (isTablet ? 40 : 32)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: isDesktop ? 96 : (isTablet ? 84 : 72),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: isDesktop ? 40 : (isTablet ? 36 : 32)),
            Text(
              message,
              style: TextStyle(
                fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
            Text(
              widget.jobId != null 
                  ? AppLocalizations.of(context).addTasksToJob
                  : AppLocalizations.of(context).createFirstTask,
              style: TextStyle(
                fontSize: isDesktop ? 18 : (isTablet ? 17 : 16),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? 40 : (isTablet ? 36 : 32)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _navigateToAddTask,
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  AppLocalizations.of(context).addTask,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  void _navigateToAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(jobId: widget.jobId),
      ),
    );
  }

  void _showTaskDetails(Task task) {
    Navigator.of(context).pushNamed(
      TaskDetailsScreen.routeName,
      arguments: task.id,
    );
  }

  void _editTask(Task task) {
    // Placeholder for edit task functionality
    // In a real implementation, this would navigate to an edit task screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit task functionality would be implemented here'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Provider.of<TasksProvider>(context, listen: false).deleteTask(task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    try {
      await Provider.of<TasksProvider>(context, listen: false)
          .updateTaskStatus(task.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to ${_getStatusDisplayName(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTaskPriority(Task task, TaskPriority newPriority) async {
    try {
      await Provider.of<TasksProvider>(context, listen: false)
          .updateTaskPriority(task.id, newPriority);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task priority updated to ${_getPriorityDisplayName(newPriority)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task priority: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusDisplayName(TaskStatus status) {
    final t = AppLocalizations.of(context);
    switch (status) {
      case TaskStatus.pending:
        return t.pending;
      case TaskStatus.inProgress:
        return t.inProgress;
      case TaskStatus.completed:
        return t.completed;
      case TaskStatus.cancelled:
        return t.cancelled;
    }
  }

  String _getPriorityDisplayName(TaskPriority priority) {
    final t = AppLocalizations.of(context);
    switch (priority) {
      case TaskPriority.low:
        return t.low;
      case TaskPriority.medium:
        return t.medium;
      case TaskPriority.high:
        return t.high;
      case TaskPriority.urgent:
        return t.urgent;
    }
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