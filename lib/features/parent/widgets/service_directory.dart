import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/therapist.dart';
import '../../../services/app_repository.dart';
import 'filter_sheet.dart';

class ServiceDirectory extends StatefulWidget {
  final String searchQuery;
  const ServiceDirectory({super.key, this.searchQuery = ''});

  @override
  State<ServiceDirectory> createState() => _ServiceDirectoryState();
}

class _ServiceDirectoryState extends State<ServiceDirectory> {
  String _location = 'All Locations';
  Set<String> _languages = {};
  String _availability = 'both';
  List<Therapist> _therapists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ServiceDirectory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) setState(() {});
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await AppRepository.instance.fetchAvailableTherapists();
    if (mounted) setState(() {
      _therapists = list;
      _loading = false;
    });
  }

  List<Therapist> get _filtered {
    final q = widget.searchQuery.trim().toLowerCase();
    return _therapists.where((t) {
      if (q.isNotEmpty &&
          !t.name.toLowerCase().contains(q) &&
          !t.expertiseLabel.toLowerCase().contains(q) &&
          !(t.bio ?? '').toLowerCase().contains(q)) {
        return false;
      }
      if (_location != 'All Locations' && t.location != _location) return false;
      if (_languages.isNotEmpty && !_languages.every((l) => t.languages.contains(l))) return false;
      if (_availability != 'both' && t.availability != 'both' && t.availability != _availability) {
        return false;
      }
      return true;
    }).toList();
  }

  String _chatId(String therapistId) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final ids = [uid, therapistId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filtered;

    if (_therapists.isEmpty) {
      return AppEmptyState(
        icon: Icons.psychology_outlined,
        title: 'No therapists available yet',
        message: 'Therapists can list themselves from the therapist app. Check back soon.',
        actionLabel: 'Refresh',
        onAction: _load,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _DropdownPill(
                label: _location,
                onTap: () async {
                  final v = await showMenu<String>(
                    context: context,
                    position: const RelativeRect.fromLTRB(20, 120, 20, 0),
                    items: const [
                      PopupMenuItem(value: 'All Locations', child: Text('All Locations')),
                      PopupMenuItem(value: 'Delhi', child: Text('Delhi')),
                      PopupMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                      PopupMenuItem(value: 'Bangalore', child: Text('Bangalore')),
                      PopupMenuItem(value: 'Chennai', child: Text('Chennai')),
                      PopupMenuItem(value: 'Pune', child: Text('Pune')),
                    ],
                  );
                  if (v != null) setState(() => _location = v);
                },
              ),
              const SizedBox(width: 8),
              _DropdownPill(
                label: 'Filters',
                icon: Icons.tune,
                onTap: () async {
                  final res = await showModalBottomSheet<FilterResult>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => FilterSheet(
                      initialAvailability: _availability,
                      initialLanguages: _languages,
                    ),
                  );
                  if (res != null) {
                    setState(() {
                      _availability = res.availability;
                      _languages = res.languages;
                    });
                  }
                },
              ),
              const Spacer(),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh, size: 20)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const AppEmptyState(
                  icon: Icons.search_off,
                  title: 'No matches',
                  message: 'Try different filters or search terms.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => TherapistCard(
                      therapist: filtered[i],
                      chatId: _chatId(filtered[i].id),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _DropdownPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const _DropdownPill({required this.label, required this.onTap, this.icon});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 6)],
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class TherapistCard extends StatelessWidget {
  final Therapist therapist;
  final String chatId;
  const TherapistCard({super.key, required this.therapist, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final modeLabel = therapist.availability == 'online'
        ? 'Online'
        : therapist.availability == 'in_person'
            ? 'In-person'
            : 'Online & in-person';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.5)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: therapist.avatarUrl != null ? NetworkImage(therapist.avatarUrl!) : null,
                      child: therapist.avatarUrl == null
                          ? Text(therapist.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(therapist.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(therapist.expertiseLabel, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFFAF1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(modeLabel, style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _InfoChip(icon: Icons.location_on_outlined, text: therapist.location),
                    _InfoChip(icon: Icons.star, text: therapist.rating.toStringAsFixed(1)),
                    _InfoChip(icon: Icons.work_outline, text: '${therapist.experienceYears} yrs'),
                  ],
                ),
                if (therapist.languages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(therapist.languages.join(' • '), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
                if (therapist.bio != null && therapist.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(therapist.bio!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/chat', extra: {
                          'chatId': chatId,
                          'otherUserName': therapist.name,
                        }),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Message'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push('/p/book', extra: therapist),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Book session'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
