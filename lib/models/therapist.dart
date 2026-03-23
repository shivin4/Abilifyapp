class Therapist {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final String location;
  final List<String> languages;
  final List<String> expertise;
  final String availability;
  final int experienceYears;
  final String? bio;
  final bool isAvailable;

  const Therapist({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating = 5.0,
    this.location = '',
    this.languages = const [],
    this.expertise = const [],
    this.availability = 'both',
    this.experienceYears = 0,
    this.bio,
    this.isAvailable = false,
  });

  String get expertiseLabel =>
      expertise.isNotEmpty ? expertise.join(' • ') : (bio ?? 'Special needs therapy');

  factory Therapist.fromMap(Map<String, dynamic> m) => Therapist(
        id: m['id'].toString(),
        name: (m['name'] ?? 'Therapist') as String,
        avatarUrl: (m['avatar_url'] ?? m['avatarUrl']) as String?,
        rating: ((m['rating'] ?? 5.0) as num).toDouble(),
        location: (m['city'] ?? m['location'] ?? '') as String,
        languages: ((m['languages'] ?? []) as List).map((e) => e.toString()).toList(),
        expertise: ((m['expertise'] ?? []) as List).map((e) => e.toString()).toList(),
        availability: (m['availability'] ?? 'both') as String,
        experienceYears: ((m['experience_years'] ?? m['experienceYears'] ?? 0) as num).toInt(),
        bio: m['bio'] as String?,
        isAvailable: (m['isAvailable'] ?? false) as bool,
      );
}
