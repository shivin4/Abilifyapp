import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/bootstrap.dart';
import '../services/app_repository.dart';

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
      if (mounted) context.go('/p/home');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    String? role;
    try {
      final doc = await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();
      if (doc.exists) {
        role = doc.data()?['role'] as String?;
      }
    } catch (_) {}

    if (role == null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('therapists').doc(user.uid).get();
        if (doc.exists) role = 'therapist';
      } catch (_) {}
    }

    if (!mounted) return;

    switch (role) {
      case 'therapist':
        final listing = await AppRepository.instance.getTherapist(user.uid);
        if (listing == null || !listing.isAvailable) {
          context.go('/t/profile-setup');
        } else {
          context.go('/t/home');
        }
      case 'therapist_pending':
        context.go('/pending');
      case 'parent':
        context.go('/p/home');
      case null:
        context.go('/login');
      default:
        context.go('/p/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
