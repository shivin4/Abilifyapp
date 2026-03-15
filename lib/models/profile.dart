class Profile {
  final String id;
  final String role; // 'therapist' | 'parent'
  final String? fullName;
  final String? avatarUrl;

  const Profile({required this.id, required this.role, this.fullName, this.avatarUrl});

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        role: (map['role'] ?? 'parent') as String,
        fullName: map['full_name'] as String?,
        avatarUrl: map['avatar_url'] as String?,
      );
}
