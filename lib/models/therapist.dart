class Therapist {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating; // 0-5
  final String location; // city
  final List<String> languages;
  final String availability; // 'online', 'in_person', 'both'
  final int experienceYears;
  final String? bio;

  const Therapist({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating = 0,
    this.location = 'All',
    this.languages = const [],
    this.availability = 'both',
    this.experienceYears = 0,
    this.bio,
  });

  factory Therapist.fromMap(Map<String, dynamic> m) => Therapist(
        id: m['id'].toString(),
        name: (m['name'] ?? 'Therapist') as String,
        avatarUrl: m['avatar_url'] as String?,
        rating: (m['rating'] ?? 0).toDouble(),
        location: (m['city'] ?? m['location'] ?? 'All') as String,
        languages: ((m['languages'] ?? []) as List).map((e) => e.toString()).toList(),
        availability: (m['availability'] ?? 'both') as String,
        experienceYears: (m['experience_years'] ?? 0) as int,
        bio: m['bio'] as String?,
      );
}
