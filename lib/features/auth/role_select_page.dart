import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class RoleSelectPage extends StatefulWidget {
  final String name;
  final String phone;

  const RoleSelectPage({super.key, required this.name, required this.phone});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  String? _selectedRole; // 'parent' | 'therapist'
  bool _loading = false;

  Future<void> _confirm() async {
    if (_selectedRole == null) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final role =
          _selectedRole == 'therapist' ? 'therapist_pending' : 'parent';

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .set({
        'role': role,
        'fullName': widget.name,
        'phone': widget.phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      if (role == 'parent') {
        context.go('/p/home');
      } else {
        context.go('/pending');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi ${widget.name.split(' ').first} 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'How will you be using Abilify?',
                style: TextStyle(color: AppColors.textLight, fontSize: 15),
              ),
              const SizedBox(height: 40),

              // Parent card
              _RoleCard(
                icon: Icons.family_restroom,
                iconColor: AppColors.primary,
                bgColor: const Color(0xFFF0EDFF),
                title: 'I\'m a Parent / Caregiver',
                subtitle:
                    'Find verified therapists, track progress, and connect with a support community.',
                selected: _selectedRole == 'parent',
                onTap: () => setState(() => _selectedRole = 'parent'),
              ),
              const SizedBox(height: 16),

              // Therapist card
              _RoleCard(
                icon: Icons.psychology_outlined,
                iconColor: AppColors.blue,
                bgColor: const Color(0xFFEBF3FF),
                title: 'I\'m a Therapist',
                subtitle:
                    'Manage your sessions, notes, and client relationships. Requires admin verification.',
                selected: _selectedRole == 'therapist',
                onTap: () => setState(() => _selectedRole = 'therapist'),
                badge: 'Pending Approval',
              ),

              const Spacer(),

              // Info for therapist
              if (_selectedRole == 'therapist')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Therapist accounts require admin approval before gaining access. '
                          'You\'ll see a waiting screen after registration.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedRole == null || _loading) ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _selectedRole == null
                              ? 'Select your role'
                              : _selectedRole == 'parent'
                                  ? 'Continue as Parent'
                                  : 'Register as Therapist',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? iconColor : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: iconColor.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFF59E0B),
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? iconColor : Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
