import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/session.dart';
import '../../services/app_repository.dart';

class ParentSessionsTab extends StatelessWidget {
  const ParentSessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Please sign in'));
    }

    return Column(
      children: [
        const AppGradientHeader(
          title: 'My Sessions',
          subtitle: 'Upcoming and past therapy bookings',
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: AppRepository.instance.sessionsForParent(uid),
            builder: (context, snap) {
              if (snap.hasError) {
                return AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error loading sessions',
                  message: '${snap.error}',
                );
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final sessions = snap.data!.docs.map(SessionItem.fromDoc).toList()
                ..sort((a, b) => b.start.compareTo(a.start));

              if (sessions.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.event_available,
                  title: 'No sessions yet',
                  message: 'Book a therapist from the Home tab to schedule your first session.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  final f = DateFormat('EEE, MMM d • hh:mm a');
                  final isUpcoming = s.status == 'scheduled' && s.start.isAfter(DateTime.now());

                  return Card(
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
                                  s.therapistName.isNotEmpty ? s.therapistName[0] : 'T',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.therapistName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                    Text(f.format(s.start), style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                                  ],
                                ),
                              ),
                              _StatusChip(status: s.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Client: ${s.clientName}', style: const TextStyle(fontSize: 13)),
                          if (isUpcoming) ...[
                            const SizedBox(height: 16),
                            AppPrimaryButton(
                              label: 'Join video session',
                              icon: Icons.videocam_rounded,
                              backgroundColor: AppColors.green,
                              onPressed: () => context.push('/p/session', extra: {'channelId': s.channelId}),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'completed':
        bg = const Color(0xFFEFFAF1);
        fg = AppColors.green;
        label = 'Done';
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = Colors.red;
        label = 'Cancelled';
      default:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = 'Scheduled';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
