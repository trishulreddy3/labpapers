import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/paper_model.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: '1083681645977-fje0ac5f1qba1f91g48ocujuevaj1but.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up
  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await cred.user?.updateDisplayName(name);
      
      await _firestore.collection('users').doc(cred.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign in
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return 'Sign in cancelled';
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential cred = await _auth.signInWithCredential(credential);
      
      // Save user info to Firestore if new user
      if (cred.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(cred.user?.uid).set({
          'name': cred.user?.displayName ?? '',
          'email': cred.user?.email ?? '',
          'photoUrl': cred.user?.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Upload Paper
  Future<String?> uploadPaper(Paper paper) async {
    try {
      await _firestore.collection('papers').doc(paper.id).set(paper.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Get all papers
  Stream<List<Paper>> getAllPapers() {
    return _firestore
        .collection('papers')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Paper.fromMap(doc.data()))
            .toList());
  }

  // Get user papers
  Stream<List<Paper>> getUserPapers(String userEmail) {
    return _firestore
        .collection('papers')
        .where('uploadedByEmail', isEqualTo: userEmail)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Paper.fromMap(doc.data()))
            .toList());
  }

  // Search papers
  Stream<List<Paper>> searchPapers({
    String? college,
    int? year,
    String? branch,
    String? examType,
  }) {
    Query query = _firestore.collection('papers');
    
    if (college != null && college.isNotEmpty) {
      query = query.where('collegeName', isEqualTo: college);
    }
    if (year != null && year > 0) {
      query = query.where('year', isEqualTo: year);
    }
    if (branch != null && branch.isNotEmpty) {
      query = query.where('branch', isEqualTo: branch);
    }
    if (examType != null && examType.isNotEmpty) {
      query = query.where('examinationType', isEqualTo: examType);
    }
    
    return query.orderBy('uploadedAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Paper.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Update download count (only once per user)
  Future<bool> incrementDownload(String paperId, String userEmail) async {
    try {
      final doc = await _firestore.collection('papers').doc(paperId).get();
      final data = doc.data()!;
      final downloadedBy = List<String>.from(data['downloadedBy'] ?? []);
      
      // Check if user has already downloaded
      if (downloadedBy.contains(userEmail)) {
        return false; // Already downloaded
      }
      
      // Add to downloadedBy list and increment count
      await _firestore.collection('papers').doc(paperId).update({
        'downloadedBy': FieldValue.arrayUnion([userEmail]),
        'downloads': FieldValue.increment(1),
      });
      
      return true;
    } catch (e) {
      debugPrint('Error incrementing download: $e');
      return false;
    }
  }

  // Like/unlike paper
  Future<bool> toggleLike(String paperId, String userEmail) async {
    try {
      final doc = await _firestore.collection('papers').doc(paperId).get();
      final data = doc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      
      if (likedBy.contains(userEmail)) {
        // Unlike
        await _firestore.collection('papers').doc(paperId).update({
          'likedBy': FieldValue.arrayRemove([userEmail]),
          'likes': FieldValue.increment(-1),
        });
        return false; // Unlike
      } else {
        // Like
        await _firestore.collection('papers').doc(paperId).update({
          'likedBy': FieldValue.arrayUnion([userEmail]),
          'likes': FieldValue.increment(1),
        });
        return true; // Like
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      return false;
    }
  }

  // Get uploader email for a paper
  Future<String?> getPaperUploader(String paperId) async {
    try {
      final doc = await _firestore.collection('papers').doc(paperId).get();
      return doc.data()?['uploadedByEmail'];
    } catch (e) {
      debugPrint('Error getting uploader: $e');
      return null;
    }
  }

  // Delete paper
  Future<void> deletePaper(String paperId) async {
    await _firestore.collection('papers').doc(paperId).delete();
  }

  // User Profile Methods
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<bool> createUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).set(profile.toMap());
      return true;
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).update({
        ...profile.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }
}
