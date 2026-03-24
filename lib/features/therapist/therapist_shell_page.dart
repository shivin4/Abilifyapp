import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'schedule_calendar_page.dart';
import 'therapist_profile_setup_page.dart';

class TherapistShellPage extends StatefulWidget {
  const TherapistShellPage({super.key});

  @override
  State<TherapistShellPage> createState() => _TherapistShellPageState();
}

class _TherapistShellPageState extends State<TherapistShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TherapistDashboardPage(),
          ScheduleCalendarPage(),
          TherapistProfileSetupPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.badge_outlined), label: 'Listing'),
        ],
      ),
    );
  }
}
