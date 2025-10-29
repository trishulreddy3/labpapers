import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/paper_model.dart';
import '../services/firebase_service.dart';
import '../services/cloudinary_service.dart';
import '../services/notification_service.dart';

class PaperProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<Paper> _allPapers = [];
  List<Paper> _filteredPapers = [];
  List<Paper> _myPapers = [];
  bool _isLoading = false;
  String? _error;

  List<Paper> get allPapers => _allPapers;
  List<Paper> get filteredPapers => _filteredPapers;
  List<Paper> get myPapers => _myPapers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filters
  String? _selectedCollege;
  int? _selectedYear;
  String? _selectedBranch;
  String? _selectedExamType;

  String? get selectedCollege => _selectedCollege;
  int? get selectedYear => _selectedYear;
  String? get selectedBranch => _selectedBranch;
  String? get selectedExamType => _selectedExamType;

  PaperProvider() {
    loadAllPapers();
  }

  void loadAllPapers() {
    _setLoading(true);
    _firebaseService.getAllPapers().listen((papers) {
      _allPapers = papers;
      _filteredPapers = papers;
      _setLoading(false);
      notifyListeners();
    });
  }

  void loadMyPapers(String userEmail) {
    _setLoading(true);
    _firebaseService.getUserPapers(userEmail).listen((papers) {
      _myPapers = papers;
      _setLoading(false);
      notifyListeners();
    });
  }

  Future<bool> uploadPaper({
    required String title,
    required String subject, // Will be required for new uploads
    String? description,
    required String collegeName,
    required int year,
    required String branch,
    required String examinationType,
    required String uploadedBy,
    required String uploadedByEmail,
    required File file,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Upload file to Cloudinary
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final fileUrl = await _cloudinaryService.uploadFile(file, fileName);

      if (fileUrl == null) {
        _error = 'Failed to upload file';
        _setLoading(false);
        return false;
      }

      // Create paper document
      final paper = Paper(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        subject: subject,
        description: description,
        collegeName: collegeName,
        year: year,
        branch: branch,
        examinationType: examinationType,
        uploadedBy: uploadedBy,
        uploadedByEmail: uploadedByEmail,
        fileUrl: fileUrl,
        pdfUrl: fileUrl,
        uploadedAt: DateTime.now(),
      );

      // Save to Firestore
      final error = await _firebaseService.uploadPaper(paper);
      
      if (error != null) {
        _error = error;
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void applyFilters({
    String? college,
    int? year,
    String? branch,
    String? examType,
  }) {
    _selectedCollege = college;
    _selectedYear = year;
    _selectedBranch = branch;
    _selectedExamType = examType;

    List<Paper> filtered = _allPapers;

    if (college != null && college.isNotEmpty) {
      filtered = filtered.where((p) => p.collegeName.contains(college)).toList();
    }
    if (year != null && year > 0) {
      filtered = filtered.where((p) => p.year == year).toList();
    }
    if (branch != null && branch.isNotEmpty) {
      filtered = filtered.where((p) => p.branch == branch).toList();
    }
    if (examType != null && examType.isNotEmpty) {
      filtered = filtered.where((p) => p.examinationType == examType).toList();
    }

    _filteredPapers = filtered;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCollege = null;
    _selectedYear = null;
    _selectedBranch = null;
    _selectedExamType = null;
    _filteredPapers = _allPapers;
    notifyListeners();
  }

  void setFilteredPapers(List<Paper> papers) {
    _filteredPapers = papers;
    notifyListeners();
  }

  Future<bool> incrementDownload(String paperId, String userEmail) async {
    final success = await _firebaseService.incrementDownload(paperId, userEmail);
    
    // Send notification to uploader
    if (success) {
      try {
        final paper = _allPapers.firstWhere((p) => p.id == paperId);
        if (paper.uploadedByEmail != userEmail) {
          await NotificationService.createNotification(
            userId: paper.uploadedBy, // Use UID
            title: 'New Download',
            body: '$userEmail downloaded your paper "${paper.title}"',
            type: 'download',
            paperId: paperId,
            paperTitle: paper.title,
            data: {'action': 'view_paper', 'paperId': paperId},
          );
        }
      } catch (e) {
        debugPrint('Error sending download notification: $e');
      }
    }
    
    return success;
  }

  Future<bool> toggleLike(String paperId, String userEmail) async {
    final liked = await _firebaseService.toggleLike(paperId, userEmail);
    
    // Send notification to uploader if liked (not unliked)
    if (liked) {
      try {
        final paper = _allPapers.firstWhere((p) => p.id == paperId);
        if (paper.uploadedByEmail != userEmail) {
          await NotificationService.createNotification(
            userId: paper.uploadedBy, // Use UID
            title: 'New Like',
            body: '$userEmail liked your paper "${paper.title}"',
            type: 'like',
            paperId: paperId,
            paperTitle: paper.title,
            data: {'action': 'view_paper', 'paperId': paperId},
          );
        }
      } catch (e) {
        debugPrint('Error sending like notification: $e');
      }
    }
    
    return liked;
  }

  Future<void> deletePaper(String paperId) async {
    await _firebaseService.deletePaper(paperId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
