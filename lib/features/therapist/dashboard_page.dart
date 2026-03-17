import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class TherapistDashboardPage extends StatelessWidget {
  const TherapistDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Good ${now.hour < 12 ? 'morning' : 'evening'}, Therapist'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: const [
              _StatCard(label: "Today's Sessions", value: '3'),
              SizedBox(width: 12),
              _StatCard(label: 'Pending Notes', value: '1'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _StatCard(label: 'Earnings This Week', value: '₹8,200'),
              SizedBox(width: 12),
              _StatCard(label: 'Rating', value: '4.8★'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () => context.go('/t/schedule'), child: const Text('View schedule')),
            ],
          ),
          ...List.generate(3, (i) => _SessionTile(index: i)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/t/schedule'),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('View Schedule'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.group),
                  label: const Text('Manage Clients'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.currency_rupee),
                  label: const Text('View Earnings'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textLight)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final int index;
  const _SessionTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final start = DateTime.now().add(Duration(hours: index + 1));
    final f = DateFormat('hh:mm a');
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('C${index + 1}')),
        title: Text('Client ${index + 1} • Video'),
        subtitle: Text('${f.format(start)} today'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/t/session', extra: {
          'channelId': 'test_channel',
        }),
      ),
    );
  }
}
