import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/app_repository.dart';

class TherapistProfileSetupPage extends StatefulWidget {
  const TherapistProfileSetupPage({super.key});

  @override
  State<TherapistProfileSetupPage> createState() => _TherapistProfileSetupPageState();
}

class _TherapistProfileSetupPageState extends State<TherapistProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _expCtrl = TextEditingController(text: '3');
  final _langsCtrl = TextEditingController(text: 'English, Hindi');
  final _expertiseCtrl = TextEditingController(text: 'Speech Therapy, ADHD');

  String _availability = 'both';
  bool _isAvailable = true;
  bool _loading = false;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final t = await AppRepository.instance.getTherapist(uid);
    if (t != null) {
      _nameCtrl.text = t.name;
      _bioCtrl.text = t.bio ?? '';
      _cityCtrl.text = t.location;
      _expCtrl.text = t.experienceYears.toString();
      _langsCtrl.text = t.languages.join(', ');
      _expertiseCtrl.text = t.expertise.join(', ');
      _availability = t.availability;
      _isAvailable = t.isAvailable;
    } else {
      final profile = await AppRepository.instance.getProfile(uid);
      _nameCtrl.text = profile?['fullName'] as String? ?? '';
    }
    if (mounted) setState(() => _initialLoading = false);
  }

  List<String> _splitCsv(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      await AppRepository.instance.saveTherapistProfile(
        uid: uid,
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        languages: _splitCsv(_langsCtrl.text),
        expertise: _splitCsv(_expertiseCtrl.text),
        availability: _availability,
        experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 0,
        isAvailable: _isAvailable,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAvailable
                ? 'You are now visible to parents'
                : 'Profile saved — turn on availability when ready'),
          ),
        );
        context.go('/t/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    _expCtrl.dispose();
    _langsCtrl.dispose();
    _expertiseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          const AppGradientHeader(
            title: 'Your therapist profile',
            subtitle: 'Parents will see this when searching for care',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available for bookings', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Show me in the parent therapist directory'),
                      value: _isAvailable,
                      activeThumbColor: AppColors.green,
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'About you',
                        hintText: 'Brief intro for parents…',
                      ),
                      validator: (v) => v == null || v.trim().length < 10 ? 'At least 10 characters' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _expertiseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Specializations (comma-separated)',
                        hintText: 'Speech Therapy, Autism, ADHD',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _langsCtrl,
                      decoration: const InputDecoration(labelText: 'Languages (comma-separated)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _expCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Years of experience'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Session mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'online', label: Text('Online')),
                        ButtonSegment(value: 'in_person', label: Text('In-person')),
                        ButtonSegment(value: 'both', label: Text('Both')),
                      ],
                      selected: {_availability},
                      onSelectionChanged: (s) => setState(() => _availability = s.first),
                    ),
                    const SizedBox(height: 28),
                    AppPrimaryButton(
                      label: 'Save & continue',
                      loading: _loading,
                      onPressed: _save,
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
