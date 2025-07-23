import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/jobs_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/job_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobsProvider()),
      ],
      child: MaterialApp(
        title: 'WMS Mechanic',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.blueAccent,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const DashboardScreen(),
        routes: {
          '/dashboard': (ctx) => const DashboardScreen(),
          JobDetailsScreen.routeName: (ctx) => const JobDetailsScreen(),
        },
      ),
    );
  }
}
