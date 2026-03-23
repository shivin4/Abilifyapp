import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    size: 52, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 28),

              Text(
                'Account Under Review',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your therapist account has been submitted and is awaiting admin approval. '
                'You\'ll receive access once your profile is verified.',
                style: TextStyle(
                    color: AppColors.textLight, fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Status steps
              _StatusStep(
                icon: Icons.check_circle,
                color: AppColors.green,
                label: 'Account created',
                done: true,
              ),
              _StatusStep(
                icon: Icons.pending,
                color: const Color(0xFFF59E0B),
                label: 'Admin verification in progress',
                done: false,
              ),
              _StatusStep(
                icon: Icons.lock_open_outlined,
                color: Colors.grey.shade400,
                label: 'Access granted',
                done: false,
              ),

              const SizedBox(height: 40),

              // Info box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If you\'ve been waiting for a while, contact us at support@abilify.com '
                        'or reach out to your onboarding coordinator.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool done;

  const _StatusStep(
      {required this.icon,
      required this.color,
      required this.label,
      required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: done ? AppColors.textDark : AppColors.textLight,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
