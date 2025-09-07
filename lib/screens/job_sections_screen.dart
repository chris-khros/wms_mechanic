import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import 'vehicle_info_screen.dart';
import 'job_status_screen.dart';
import 'signature_screen.dart';
import 'notes_screen.dart';

class JobSectionsScreen extends StatefulWidget {
  static const routeName = '/job-sections';

  const JobSectionsScreen({Key? key}) : super(key: key);

  @override
  State<JobSectionsScreen> createState() => _JobSectionsScreenState();
}

class _JobSectionsScreenState extends State<JobSectionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;
    final jobsProvider = Provider.of<JobsProvider>(context);
    final job = jobsProvider.getJobById(jobId);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Job Not Found'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('The job you requested was not found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Job ${job.id}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        flexibleSpace: Container(
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
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Job Overview Card
                _buildJobOverviewCard(job),
                const SizedBox(height: 32),
                
                // Section title with animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: const FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Select a section to manage:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Enhanced 2x2 Grid of sections
                _buildSectionsGrid(job),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobOverviewCard(job) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFffecd2),
                    Color(0xFFfcb69f),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.work,
                            color: Color(0xFF667eea),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job ${job.id}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              Text(
                                _getStatusText(job.status),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getStatusColor(job.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoChip(Icons.person, job.customerName),
                    const SizedBox(height: 12),
                    _buildInfoChip(Icons.directions_car, '${job.vehicleModel} (${job.vehiclePlate})'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsGrid(job) {
    final sections = [
      {
        'title': 'Vehicle Info',
        'icon': Icons.directions_car,
        'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
        'route': VehicleInfoScreen.routeName,
        'delay': 0,
      },
      {
        'title': 'Job Status',
        'icon': Icons.assignment_turned_in,
        'gradient': [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        'route': JobStatusScreen.routeName,
        'delay': 100,
      },
      {
        'title': 'Signature',
        'icon': Icons.draw,
        'gradient': [const Color(0xFF8360c3), const Color(0xFF2ebf91)],
        'route': SignatureScreen.routeName,
        'delay': 200,
      },
      {
        'title': 'Notes',
        'icon': Icons.note_add,
        'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
        'route': NotesScreen.routeName,
        'delay': 300,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (section['delay'] as int)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildModernSectionCard(
                  context,
                  section['title'] as String,
                  section['icon'] as IconData,
                  section['gradient'] as List<Color>,
                  () => Navigator.of(context).pushNamed(
                    section['route'] as String,
                    arguments: job.id,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(status) {
    switch (status.toString()) {
      case 'JobStatus.accepted':
        return 'Accepted';
      case 'JobStatus.inProgress':
        return 'In Progress';
      case 'JobStatus.onHold':
        return 'On Hold';
      case 'JobStatus.completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'JobStatus.accepted':
        return const Color(0xFF3182ce);
      case 'JobStatus.inProgress':
        return const Color(0xFF38a169);
      case 'JobStatus.onHold':
        return const Color(0xFFd69e2e);
      case 'JobStatus.completed':
        return const Color(0xFF805ad5);
      default:
        return Colors.grey;
    }
  }
}