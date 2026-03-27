import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/bootstrap.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/app_repository.dart';

class ParentProfilePage extends StatefulWidget {
  final bool embedded;
  const ParentProfilePage({super.key, this.embedded = false});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  final _nameCtrl = TextEditingController();
  final _childCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final profile = await AppRepository.instance.getProfile(user.uid);
    _nameCtrl.text = profile?['fullName'] as String? ?? '';
    _childCtrl.text = profile?['childName'] as String? ?? '';
    _phoneCtrl.text = profile?['phone'] as String? ?? user.phoneNumber ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set({
        'fullName': _nameCtrl.text.trim(),
        'childName': _childCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role': 'parent',
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    if (AppBootstrap.firebaseEnabled) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    if (context.mounted) context.go('/login');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _childCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'P',
              style: const TextStyle(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Your name')),
          const SizedBox(height: 12),
          TextFormField(controller: _childCtrl, decoration: const InputDecoration(labelText: "Child's name")),
          const SizedBox(height: 12),
          TextFormField(controller: _phoneCtrl, readOnly: true, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 24),
          AppPrimaryButton(label: 'Save profile', loading: _saving, onPressed: _save),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          const AppGradientHeader(title: 'My Profile', subtitle: 'Your family details'),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: body,
    );
  }
}
