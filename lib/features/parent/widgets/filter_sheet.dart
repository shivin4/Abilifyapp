import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class FilterResult {
  final String availability; // 'both' | 'online' | 'in_person'
  final Set<String> languages;
  const FilterResult({required this.availability, required this.languages});
}

class FilterSheet extends StatefulWidget {
  final String initialAvailability; final Set<String> initialLanguages;
  const FilterSheet({super.key, required this.initialAvailability, required this.initialLanguages});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _availability = widget.initialAvailability;
  late final Set<String> _languages = {...widget.initialLanguages};

  final List<String> langs = const ['English','Hindi','Bengali','Punjabi','Tamil','Marathi','Gujarati'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Availability', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                _radio('both', 'Both online and in-person'),
                _radio('online', 'Online only'),
                _radio('in_person', 'In-person only'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Languages', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                for (final l in langs)
                  FilterChip(
                    label: Text(l),
                    selected: _languages.contains(l),
                    onSelected: (v) => setState(() => v ? _languages.add(l) : _languages.remove(l)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() { _availability = 'both'; _languages.clear(); }),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => Navigator.pop(context, FilterResult(availability: _availability, languages: _languages)),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _radio(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ignore: deprecated_member_use
        Radio<String>(value: value, groupValue: _availability, onChanged: (v) => setState(() => _availability = v!)),
        Text(label),
      ],
    );
  }
}
