import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/bootstrap.dart';

class RoleGatePage extends StatefulWidget {
  const RoleGatePage({super.key});

  @override
  State<RoleGatePage> createState() => _RoleGatePageState();
}

class _RoleGatePageState extends State<RoleGatePage> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (!AppBootstrap.firebaseEnabled) {
      if (mounted) context.go('/p/dashboard');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    // 1) Try to read role from profiles
    String? role;
    try {
      final doc = await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();
      if (doc.exists) {
        role = doc.data()?['role'] as String?;
      }
    } catch (_) {}

    // 2) Fallback: if role not found, infer from therapists collection
    if (role == null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('therapists').doc(user.uid).get();
        if (doc.exists) role = 'therapist';
      } catch (_) {}
    }

    // Default to parent if still unknown
    role ??= 'parent';

    if (!mounted) return;
    if (role == 'therapist') {
      context.go('/t/dashboard');
    } else {
      context.go('/p/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
