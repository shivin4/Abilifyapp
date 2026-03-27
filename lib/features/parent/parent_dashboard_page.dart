import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/bootstrap.dart';
import '../../core/theme.dart';
import '../../models/session.dart';
import '../../services/app_repository.dart';
import 'widgets/service_directory.dart';

enum ServiceCategory {
  therapist('Therapists', Icons.psychology, AppColors.primary),
  schools('Schools', Icons.school, AppColors.green),
  medical('Medical', Icons.local_hospital, AppColors.blue),
  caregivers('Caregivers', Icons.favorite, AppColors.amber);

  const ServiceCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class ParentDashboardPage extends ConsumerStatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  ConsumerState<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends ConsumerState<ParentDashboardPage> {
  ServiceCategory selected = ServiceCategory.therapist;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Directory'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Profile',
            icon: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('My Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                if (AppBootstrap.firebaseEnabled) {
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (_) {}
                }
                if (!context.mounted) return;
                context.go('/login');
              } else if (value == 'profile') {
                if (context.mounted) context.push('/p/profile');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find trusted care for you and your child',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2)],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search therapists by name or specialty…',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            if (uid != null) ...[
              const SizedBox(height: 20),
              const Text('My Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: AppRepository.instance.sessionsForParent(uid),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Sessions: ${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('No bookings yet — book a therapist below', style: TextStyle(color: AppColors.textLight)),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final session = SessionItem.fromDoc(docs[i]);
                        final f = DateFormat('EEE, MMM d • hh:mm a');
                        return SizedBox(
                          width: 220,
                          child: Card(
                            margin: const EdgeInsets.only(right: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(session.therapistName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(f.format(session.start), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                                  const SizedBox(height: 6),
                                  Text(
                                    session.channelId,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (session.status == 'scheduled')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 28),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: session.channelId));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Channel ID copied — paste on therapist device')),
                                              );
                                            },
                                            child: const Text('Copy ID', style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 28),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () => context.push('/p/session', extra: {'channelId': session.channelId}),
                                            child: const Text('Join video', style: TextStyle(fontSize: 12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Categories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: ServiceCategory.values
                    .map((cat) => _CategoryTile(
                          category: cat,
                          selected: selected == cat,
                          onTap: () => setState(() => selected = cat),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selected == ServiceCategory.therapist
                  ? ServiceDirectory(searchQuery: _searchQuery)
                  : const Center(child: Text('Coming Soon')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ServiceCategory category;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: selected ? category.color : category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(category.icon, color: selected ? Colors.white : category.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? category.color : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
