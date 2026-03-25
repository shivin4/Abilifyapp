import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory CommunityPost.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    final ts = m['createdAt'];
    return CommunityPost(
      id: doc.id,
      authorId: (m['authorId'] ?? '') as String,
      authorName: (m['authorName'] ?? 'Parent') as String,
      text: (m['text'] ?? '') as String,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
