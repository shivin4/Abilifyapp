import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';

class ScheduleCalendarPage extends StatefulWidget {
  const ScheduleCalendarPage({super.key});

  @override
  State<ScheduleCalendarPage> createState() => _ScheduleCalendarPageState();
}

class _ScheduleCalendarPageState extends State<ScheduleCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.week: 'Week',
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: const [
                _Legend(color: AppColors.blue, label: 'Booked'),
                SizedBox(width: 12),
                _Legend(color: AppColors.green, label: 'Completed'),
                SizedBox(width: 12),
                _Legend(color: Colors.grey, label: 'Available'),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditAvailability(context),
        label: const Text('Edit Availability'),
        icon: const Icon(Icons.edit_calendar),
      ),
    );
  }

  Future<void> _showEditAvailability(BuildContext context) async {
    final days = <String>['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final selected = <int>{0,1,2,3,4};
    TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 18, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edit Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (int i = 0; i < days.length; i++) ChoiceChip(
                        label: Text(days[i]),
                        selected: selected.contains(i),
                        onSelected: (v) => setModal(() {
                          v ? selected.add(i) : selected.remove(i);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _TimeTile(label: 'Start', time: start, onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: start);
                        if (t != null) setModal(() => start = t);
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: _TimeTile(label: 'End', time: end, onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: end);
                        if (t != null) setModal(() => end = t);
                      })),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.link, size: 18),
                    const SizedBox(width: 8),
                    const Text('Sync with Google Calendar'),
                    const Spacer(),
                    Switch(value: false, onChanged: (v) {}),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Save'),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label),
    ]);
  }
}

class _TimeTile extends StatelessWidget {
  final String label; final TimeOfDay time; final VoidCallback onTap;
  const _TimeTile({required this.label, required this.time, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text(label),
            const Spacer(),
            Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.access_time, size: 18),
          ],
        ),
      ),
    );
  }
}
