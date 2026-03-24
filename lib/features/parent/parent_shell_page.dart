import 'package:flutter/material.dart';
import 'community_page.dart';
import 'parent_home_tab.dart';
import 'parent_profile_page.dart';
import 'parent_sessions_tab.dart';

class ParentShellPage extends StatefulWidget {
  const ParentShellPage({super.key});

  @override
  State<ParentShellPage> createState() => _ParentShellPageState();
}

class _ParentShellPageState extends State<ParentShellPage> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.event_note_rounded, label: 'Sessions'),
    (icon: Icons.groups_rounded, label: 'Community'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          ParentHomeTab(),
          ParentSessionsTab(),
          CommunityPage(),
          ParentProfilePage(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}
