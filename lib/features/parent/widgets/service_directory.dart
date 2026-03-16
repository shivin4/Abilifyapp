import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'filter_sheet.dart';

class ServiceDirectory extends StatefulWidget {
  const ServiceDirectory({super.key});

  @override
  State<ServiceDirectory> createState() => _ServiceDirectoryState();
}

class _ServiceDirectoryState extends State<ServiceDirectory> {
  String _location = 'All Locations';
  Set<String> _languages = {};
  String _availability = 'both';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _DropdownPill(
              label: _location,
              onTap: () async {
                final v = await showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(20, 80, 20, 0),
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
                if (res != null) setState(() { _availability = res.availability; _languages = res.languages;});
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => const TherapistCard(),
          ),
        ),
      ],
    );
  }
}

class _DropdownPill extends StatelessWidget {
  final String label; final VoidCallback onTap; final IconData? icon;
  const _DropdownPill({required this.label, required this.onTap, this.icon});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(label),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class TherapistCard extends StatelessWidget {
  const TherapistCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 26, backgroundImage: NetworkImage('https://i.pravatar.cc/80')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Jaya Saini', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Expertise: Speech Therapy • Sensory Processing', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Color(0xFFEFFAF1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Online', style: TextStyle(color: AppColors.green, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE5E7EB)),
              ),
              child: const Text('Available via: Chat, Video, Voice\nNext online slot: Wed, 4 May 9:00 AM', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                const Text('4.9'),
                const Spacer(),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/chat', extra: {
                      'chatId': 'test_chat_parent_therapist',
                      'otherUserName': 'Jaya Saini',
                    }),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white),
                    child: const Text('BOOK'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
