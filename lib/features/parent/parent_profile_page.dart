import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/bootstrap.dart';

class ParentProfilePage extends StatelessWidget {
  const ParentProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    if (AppBootstrap.firebaseEnabled) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('You'),
              subtitle: Text('Beta user'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
