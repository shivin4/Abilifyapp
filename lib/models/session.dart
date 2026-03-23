import 'package:cloud_firestore/cloud_firestore.dart';

class SessionItem {
  final String id;
  final String channelId;
  final String therapistId;
  final String therapistName;
  final String parentId;
  final String parentName;
  final String clientName;
  final DateTime start;
  final String mode;
  final String status;

  const SessionItem({
    required this.id,
    required this.channelId,
    required this.therapistId,
    required this.therapistName,
    required this.parentId,
    required this.parentName,
    required this.clientName,
    required this.start,
    this.mode = 'video',
    this.status = 'scheduled',
  });

  factory SessionItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    final ts = m['startTime'];
    DateTime start;
    if (ts is Timestamp) {
      start = ts.toDate();
    } else if (m['start_time'] is String) {
      start = DateTime.parse(m['start_time'] as String);
    } else {
      start = DateTime.now();
    }
    return SessionItem(
      id: doc.id,
      channelId: (m['channelId'] ?? doc.id) as String,
      therapistId: (m['therapistId'] ?? '') as String,
      therapistName: (m['therapistName'] ?? 'Therapist') as String,
      parentId: (m['parentId'] ?? '') as String,
      parentName: (m['parentName'] ?? 'Parent') as String,
      clientName: (m['clientName'] ?? 'Client') as String,
      start: start,
      mode: (m['mode'] ?? 'video') as String,
      status: (m['status'] ?? 'scheduled') as String,
    );
  }

  /// Legacy map parser
  factory SessionItem.fromMap(Map<String, dynamic> m) => SessionItem(
        id: m['id'].toString(),
        channelId: (m['channelId'] ?? m['id']).toString(),
        therapistId: (m['therapistId'] ?? '') as String,
        therapistName: (m['therapistName'] ?? 'Therapist') as String,
        parentId: (m['parentId'] ?? '') as String,
        parentName: (m['parentName'] ?? 'Parent') as String,
        clientName: (m['client_name'] ?? m['clientName'] ?? 'Client') as String,
        start: m['startTime'] is Timestamp
            ? (m['startTime'] as Timestamp).toDate()
            : DateTime.parse(m['start_time'] as String? ?? DateTime.now().toIso8601String()),
        mode: (m['mode'] ?? 'video') as String,
        status: (m['status'] ?? 'scheduled') as String,
      );
}
