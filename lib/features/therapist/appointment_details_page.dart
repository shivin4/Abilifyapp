import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/session.dart';
import '../../services/app_repository.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String? sessionId;
  const AppointmentDetailsPage({super.key, this.sessionId});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  SessionItem? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.sessionId == null) {
      setState(() => _loading = false);
      return;
    }
    final s = await AppRepository.instance.getSession(widget.sessionId!);
    if (mounted) setState(() {
      _session = s;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final s = _session;
    final channelId = s?.channelId ?? '';
    final f = DateFormat('EEE, MMM d • hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Session details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(label: 'Client', value: s?.clientName ?? '—'),
                    _DetailRow(label: 'Parent', value: s?.parentName ?? '—'),
                    _DetailRow(label: 'When', value: s != null ? f.format(s.start) : '—'),
                    _DetailRow(label: 'Mode', value: s?.mode ?? 'video'),
                    _DetailRow(label: 'Status', value: s?.status ?? 'scheduled'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (s?.status == 'scheduled') ...[
              AppPrimaryButton(
                label: 'Start video session',
                icon: Icons.videocam_rounded,
                backgroundColor: AppColors.green,
                onPressed: channelId.isEmpty
                    ? null
                    : () => context.push('/t/session', extra: {'channelId': channelId}),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              onPressed: () => context.go('/t/notes'),
              child: const Text('Add session notes'),
            ),
            if (widget.sessionId != null && s?.status == 'scheduled') ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await AppRepository.instance.updateSessionStatus(widget.sessionId!, 'completed');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Marked as completed')),
                    );
                    context.pop();
                  }
                },
                child: const Text('Mark as completed'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
