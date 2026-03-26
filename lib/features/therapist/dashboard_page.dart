import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/bootstrap.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/session.dart';
import '../../services/app_repository.dart';

class TherapistDashboardPage extends StatelessWidget {
  const TherapistDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    if (AppBootstrap.firebaseEnabled) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Column(
      children: [
        AppGradientHeader(
          title: '$greeting 👋',
          subtitle: 'Manage sessions and connect with families',
          trailing: IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ),
        Expanded(
          child: uid.isEmpty
              ? const Center(child: Text('Not signed in'))
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: AppRepository.instance.sessionsForTherapist(uid),
                  builder: (context, snap) {
                    final sessions = snap.hasData
                        ? (snap.data!.docs.map(SessionItem.fromDoc).toList()
                          ..sort((a, b) => a.start.compareTo(b.start)))
                        : <SessionItem>[];
                    final upcoming = sessions.where((s) => s.status == 'scheduled').toList();
                    final todayCount = upcoming.where((s) {
                      final t = DateTime.now();
                      final d = s.start;
                      return d.year == t.year && d.month == t.month && d.day == t.day;
                    }).length;

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          children: [
                            _StatCard(
                              label: "Today's sessions",
                              value: '$todayCount',
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              label: 'Upcoming',
                              value: '${upcoming.length}',
                              color: AppColors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const AppSectionTitle(title: 'Booked sessions'),
                        const SizedBox(height: 8),
                        if (snap.hasError)
                          Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)),
                        if (!snap.hasData)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ))
                        else if (upcoming.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(Icons.event_busy, size: 40, color: AppColors.textLight),
                                  SizedBox(height: 12),
                                  Text('No upcoming bookings', style: TextStyle(fontWeight: FontWeight.w600)),
                                  SizedBox(height: 6),
                                  Text(
                                    'Turn on availability in the Listing tab so parents can find you.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...upcoming.map((s) => _SessionCard(session: s)),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionItem session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('EEE, MMM d • hh:mm a');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    session.clientName.isNotEmpty ? session.clientName[0] : 'C',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.clientName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Parent: ${session.parentName}', style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                      Text(f.format(session.start), style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/t/appointment', extra: {'sessionId': session.id}),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/t/session', extra: {'channelId': session.channelId}),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
                    icon: const Icon(Icons.videocam_rounded, size: 20),
                    label: const Text('Start video'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
