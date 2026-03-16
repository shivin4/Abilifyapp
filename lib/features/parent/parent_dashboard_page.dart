import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'widgets/service_directory.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/bootstrap.dart';

enum ServiceCategory { 
  therapist('Therapists', Icons.psychology, AppColors.primary), 
  schools('Schools', Icons.school, AppColors.green), 
  medical('Medical', Icons.local_hospital, AppColors.blue), 
  caregivers('Caregivers', Icons.favorite, AppColors.amber);

  const ServiceCategory(this.label, this.icon, this.color);
  final String label; final IconData icon; final Color color;
}

class ParentDashboardPage extends ConsumerStatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  ConsumerState<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends ConsumerState<ParentDashboardPage> {
  ServiceCategory selected = ServiceCategory.therapist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Directory'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Profile',
            icon: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('My Profile')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                if (AppBootstrap.firebaseEnabled) {
                  try { await FirebaseAuth.instance.signOut(); } catch (_) {}
                }
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                context.go('/login');
              } else if (value == 'profile') {
                if (mounted) context.push('/p/profile');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find trusted care for you and your child',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 2)],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search services, specialists ...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: ServiceCategory.values.map((cat) => _CategoryTile(
                  category: cat,
                  selected: selected == cat,
                  onTap: () => setState(() => selected = cat),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selected == ServiceCategory.therapist
                  ? const ServiceDirectory()
                  : const Center(child: Text('Coming Soon')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ServiceCategory category; final bool selected; final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: selected ? category.color : category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(category.icon, color: selected ? Colors.white : category.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? category.color : AppColors.textDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
