import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/community_post.dart';
import '../../services/app_repository.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _postCtrl = TextEditingController();
  bool _posting = false;

  Future<void> _submitPost() async {
    final text = _postCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      await AppRepository.instance.addCommunityPost(text);
      _postCtrl.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not post: $e')));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        const AppGradientHeader(
          title: 'Parent Community',
          subtitle: 'Share experiences, tips, and support with other caregivers',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _postCtrl,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question or share something helpful…',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: _posting ? null : _submitPost,
                  icon: _posting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CommunityPost>>(
            stream: AppRepository.instance.communityPostsStream(),
            builder: (context, snap) {
              if (snap.hasError) {
                return AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load posts',
                  message: '${snap.error}',
                );
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = snap.data!;
              if (posts.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Be the first to post',
                  message: 'Start a conversation — other parents are here to support you.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _PostCard(post: posts[i], isMine: posts[i].authorId == uid),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final bool isMine;

  const _PostCard({required this.post, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('MMM d • hh:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isMine ? AppColors.primary : AppColors.primaryLight,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'P',
                    style: TextStyle(
                      color: isMine ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(f.format(post.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                ),
                if (isMine)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('You', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.text, style: const TextStyle(height: 1.5, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
