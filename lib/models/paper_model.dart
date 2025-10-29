class Paper {
  final String id;
  final String title;
  final String collegeName;
  final int year;
  final String branch;
  final String examinationType;
  final String? subject;
  final String? description;
  final String uploadedBy;
  final String uploadedByEmail;
  final String fileUrl;
  final String pdfUrl;
  final DateTime uploadedAt;
  final int downloads;
  final int likes;
  final List<String> likedBy; // List of user emails who liked
  final List<String> downloadedBy; // List of user emails who downloaded

  Paper({
    required this.id,
    required this.title,
    required this.collegeName,
    required this.year,
    required this.branch,
    required this.examinationType,
    this.subject,
    this.description,
    required this.uploadedBy,
    required this.uploadedByEmail,
    required this.fileUrl,
    required this.pdfUrl,
    required this.uploadedAt,
    this.downloads = 0,
    this.likes = 0,
    this.likedBy = const [],
    this.downloadedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'collegeName': collegeName,
      'year': year,
      'branch': branch,
      'examinationType': examinationType,
      'subject': subject,
      'description': description,
      'uploadedBy': uploadedBy,
      'uploadedByEmail': uploadedByEmail,
      'fileUrl': fileUrl,
      'pdfUrl': pdfUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'downloads': downloads,
      'likes': likes,
      'likedBy': likedBy,
      'downloadedBy': downloadedBy,
    };
  }

  factory Paper.fromMap(Map<String, dynamic> map) {
    return Paper(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      collegeName: map['collegeName'] ?? '',
      year: map['year'] ?? 0,
      branch: map['branch'] ?? '',
      examinationType: map['examinationType'] ?? '',
      subject: map['subject'],
      description: map['description'],
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedByEmail: map['uploadedByEmail'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      uploadedAt: DateTime.parse(map['uploadedAt']),
      downloads: map['downloads'] ?? 0,
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      downloadedBy: List<String>.from(map['downloadedBy'] ?? []),
    );
  }

  Paper copyWith({
    String? id,
    String? title,
    String? collegeName,
    int? year,
    String? branch,
    String? examinationType,
    String? subject,
    String? description,
    String? uploadedBy,
    String? uploadedByEmail,
    String? fileUrl,
    String? pdfUrl,
    DateTime? uploadedAt,
    int? downloads,
    int? likes,
    List<String>? likedBy,
    List<String>? downloadedBy,
  }) {
    return Paper(
      id: id ?? this.id,
      title: title ?? this.title,
      collegeName: collegeName ?? this.collegeName,
      year: year ?? this.year,
      branch: branch ?? this.branch,
      examinationType: examinationType ?? this.examinationType,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByEmail: uploadedByEmail ?? this.uploadedByEmail,
      fileUrl: fileUrl ?? this.fileUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      downloads: downloads ?? this.downloads,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      downloadedBy: downloadedBy ?? this.downloadedBy,
    );
  }
}
