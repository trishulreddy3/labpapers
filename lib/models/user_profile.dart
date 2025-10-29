class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? photoUrl;
  final String? college;
  final String? branch;
  final int? year;
  final String? semester;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.bio,
    this.photoUrl,
    this.college,
    this.branch,
    this.year,
    this.semester,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'photoUrl': photoUrl,
      'college': college,
      'branch': branch,
      'year': year,
      'semester': semester,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      college: map['college'],
      branch: map['branch'],
      year: map['year'],
      semester: map['semester'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Factory to create from Firebase User (need to add import at top)
  factory UserProfile.fromFirebaseUser(user) {
    return UserProfile(
      id: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? photoUrl,
    String? college,
    String? branch,
    int? year,
    String? semester,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
