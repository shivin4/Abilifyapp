import 'package:flutter/material.dart';

class PostSessionNotesPage extends StatefulWidget {
  const PostSessionNotesPage({super.key});

  @override
  State<PostSessionNotesPage> createState() => _PostSessionNotesPageState();
}

class _PostSessionNotesPageState extends State<PostSessionNotesPage> {
  final _summaryCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _activitiesCtrl = TextEditingController();
  final _recoCtrl = TextEditingController();
  bool _shareWithParent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post-Session Notes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Summary of session'),
          const SizedBox(height: 6),
          TextField(controller: _summaryCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const Text('Observations'),
          const SizedBox(height: 6),
          TextField(controller: _obsCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const Text('Activities done'),
          const SizedBox(height: 6),
          TextField(controller: _activitiesCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 12),
          const Text('Recommendations for parent'),
          const SizedBox(height: 6),
          TextField(controller: _recoCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Share notes with parent'),
            value: _shareWithParent,
            onChanged: (v) => setState(() => _shareWithParent = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: () { Navigator.pop(context); }, child: const Text('Save Notes')),
          )
        ],
      ),
    );
  }
}
