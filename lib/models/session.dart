class SessionItem {
  final String id;
  final String clientName;
  final DateTime start;
  final String mode; // 'video' | 'in_person'

  const SessionItem({
    required this.id,
    required this.clientName,
    required this.start,
    this.mode = 'video',
  });

  factory SessionItem.fromMap(Map<String, dynamic> m) => SessionItem(
        id: m['id'].toString(),
        clientName: (m['client_name'] ?? 'Client') as String,
        start: DateTime.parse(m['start_time'] as String),
        mode: (m['mode'] ?? 'video') as String,
      );
}
