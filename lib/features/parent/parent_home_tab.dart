import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import 'widgets/service_directory.dart';

class ParentHomeTab extends StatefulWidget {
  const ParentHomeTab({super.key});

  @override
  State<ParentHomeTab> createState() => _ParentHomeTabState();
}

class _ParentHomeTabState extends State<ParentHomeTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppGradientHeader(
          title: 'Find care',
          subtitle: 'Verified therapists for children with special needs',
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 22),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AppSearchField(
            controller: _searchCtrl,
            hint: 'Search by name or specialty…',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _QuickPill(icon: Icons.verified_user, label: 'Verified'),
              const SizedBox(width: 8),
              _QuickPill(icon: Icons.videocam, label: 'Video sessions'),
              const SizedBox(width: 8),
              _QuickPill(icon: Icons.chat_bubble_outline, label: 'Chat'),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Available therapists', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
        Expanded(child: ServiceDirectory(searchQuery: _searchQuery)),
      ],
    );
  }
}

class _QuickPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
