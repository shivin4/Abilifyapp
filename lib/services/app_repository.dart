import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_post.dart';
import '../models/session.dart';
import '../models/therapist.dart';

class AppRepository {
  AppRepository._();
  static final instance = AppRepository._();

  final _db = FirebaseFirestore.instance;

  Future<List<Therapist>> fetchAvailableTherapists() async {
    final snap = await _db
        .collection('therapists')
        .where('isAvailable', isEqualTo: true)
        .get();
    return snap.docs.map((d) {
      final data = Map<String, dynamic>.from(d.data());
      data['id'] = d.id;
      return Therapist.fromMap(data);
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  Future<Therapist?> getTherapist(String uid) async {
    final doc = await _db.collection('therapists').doc(uid).get();
    if (!doc.exists) return null;
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return Therapist.fromMap(data);
  }

  Future<void> saveTherapistProfile({
    required String uid,
    required String name,
    required String bio,
    required String city,
    required List<String> languages,
    required List<String> expertise,
    required String availability,
    required int experienceYears,
    required bool isAvailable,
    String? avatarUrl,
  }) async {
    await _db.collection('therapists').doc(uid).set({
      'name': name,
      'bio': bio,
      'city': city,
      'location': city,
      'languages': languages,
      'expertise': expertise,
      'availability': availability,
      'experience_years': experienceYears,
      'experienceYears': experienceYears,
      'isAvailable': isAvailable,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'userId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final doc = await _db.collection('therapists').doc(uid).get();
    if (!doc.exists || doc.data()?['rating'] == null) {
      await _db.collection('therapists').doc(uid).set({'rating': 5.0}, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final doc = await _db.collection('profiles').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  Future<String> bookSession({
    required Therapist therapist,
    required DateTime startTime,
    String mode = 'video',
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final profile = await getProfile(user.uid);
    final parentName = profile?['fullName'] as String? ?? 'Parent';
    final ref = _db.collection('sessions').doc();
    final channelId = ref.id;

    await ref.set({
      'channelId': channelId,
      'therapistId': therapist.id,
      'therapistName': therapist.name,
      'parentId': user.uid,
      'parentName': parentName,
      'clientName': profile?['childName'] as String? ?? 'Child',
      'startTime': Timestamp.fromDate(startTime),
      'status': 'scheduled',
      'mode': mode,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final chatId = _chatIdFor(user.uid, therapist.id);
    await _db.collection('chats').doc(chatId).set({
      'participants': [user.uid, therapist.id],
      'therapistName': therapist.name,
      'parentName': parentName,
      'lastMessage': 'Session booked for ${startTime.toIso8601String()}',
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return ref.id;
  }

  String _chatIdFor(String a, String b) {
    final ids = [a, b]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> sessionsForParent(String parentId) {
    return _db.collection('sessions').where('parentId', isEqualTo: parentId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> sessionsForTherapist(String therapistId) {
    return _db.collection('sessions').where('therapistId', isEqualTo: therapistId).snapshots();
  }

  Future<SessionItem?> getSession(String sessionId) async {
    final doc = await _db.collection('sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    return SessionItem.fromDoc(doc);
  }

  Future<void> updateSessionStatus(String sessionId, String status) async {
    await _db.collection('sessions').doc(sessionId).update({'status': status});
  }

  Stream<List<CommunityPost>> communityPostsStream() {
    return _db
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityPost.fromDoc).toList());
  }

  Future<void> addCommunityPost(String text) async {
    final user = FirebaseAuth.instance.currentUser!;
    final profile = await getProfile(user.uid);
    final name = profile?['fullName'] as String? ?? 'Parent';
    await _db.collection('community_posts').add({
      'authorId': user.uid,
      'authorName': name,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
