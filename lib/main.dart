import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:provider/provider.dart';
import 'providers/jobs_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/job_details_screen.dart';
import 'screens/job_sections_screen.dart';
import 'screens/vehicle_info_screen.dart';
import 'screens/job_status_screen.dart';
import 'screens/signature_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/task_details_screen.dart';
import 'screens/add_task_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SQLite for desktop using FFI
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Initialize SQLite for Web using FFI worker
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'WMS Mechanic',
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              // Clamp text scale to avoid pixel overflow on very large accessibility sizes
              final clampedTextScaler = TextScaler.linear(mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2));
              return MediaQuery(
                data: mediaQuery.copyWith(textScaler: clampedTextScaler),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AuthWrapper(),
            routes: {
              LoginScreen.routeName: (ctx) => const LoginScreen(),
              '/dashboard': (ctx) => const TaskListScreen(),
              '/jobs': (ctx) => const DashboardScreen(),
              JobDetailsScreen.routeName: (ctx) => const JobDetailsScreen(),
              JobSectionsScreen.routeName: (ctx) => const JobSectionsScreen(),
              VehicleInfoScreen.routeName: (ctx) => const VehicleInfoScreen(),
              JobStatusScreen.routeName: (ctx) => const JobStatusScreen(),
              SignatureScreen.routeName: (ctx) => const SignatureScreen(),
              NotesScreen.routeName: (ctx) => const NotesScreen(),
              ProfileScreen.routeName: (ctx) => const ProfileScreen(),
              EditProfileScreen.routeName: (ctx) => const EditProfileScreen(),
              TaskListScreen.routeName: (ctx) => const TaskListScreen(),
              TaskDetailsScreen.routeName: (ctx) => TaskDetailsScreen(taskId: ModalRoute.of(ctx)?.settings.arguments as String),
              AddTaskScreen.routeName: (ctx) => const AddTaskScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Container(
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Initializing WMS Mechanic...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const TaskListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
