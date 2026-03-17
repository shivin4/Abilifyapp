import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Client: Aarav Sharma, 8y'),
            const SizedBox(height: 6),
            const Text('Condition: ADHD'),
            const SizedBox(height: 6),
            const Text('Mode: Video'),
            const SizedBox(height: 6),
            const Text('Date & Time: Today 4:00 PM'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/t/session', extra: {'channelId': 'demo_session_1'}),
                    child: const Text('Start Session'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cancel Session'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/t/notes'),
                    child: const Text('Add Notes'),
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
