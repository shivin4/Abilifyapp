import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/therapist.dart';
import '../../services/app_repository.dart';

class BookSessionPage extends StatefulWidget {
  final Therapist therapist;
  const BookSessionPage({super.key, required this.therapist});

  @override
  State<BookSessionPage> createState() => _BookSessionPageState();
}

class _BookSessionPageState extends State<BookSessionPage> {
  DateTime _slot = DateTime.now().add(const Duration(hours: 2));
  bool _loading = false;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _slot,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_slot),
    );
    if (time == null || !mounted) return;
    setState(() {
      _slot = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await AppRepository.instance.bookSession(
        therapist: widget.therapist,
        startTime: _slot,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session booked! Check the Sessions tab.')),
      );
      context.go('/p/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('EEE, MMM d • hh:mm a');
    return Scaffold(
      appBar: AppBar(title: const Text('Book session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: widget.therapist.avatarUrl != null
                          ? NetworkImage(widget.therapist.avatarUrl!)
                          : null,
                      child: widget.therapist.avatarUrl == null
                          ? Text(widget.therapist.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.therapist.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                          Text(widget.therapist.expertiseLabel, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Session type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(Icons.videocam, color: AppColors.green, size: 18),
              label: const Text('Video therapy session'),
              backgroundColor: const Color(0xFFEFFAF1),
            ),
            const SizedBox(height: 20),
            const Text('Date & time', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(f.format(_slot), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.edit_calendar, size: 20, color: AppColors.textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            AppPrimaryButton(
              label: 'Confirm booking',
              loading: _loading,
              onPressed: _confirm,
              backgroundColor: AppColors.green,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}
