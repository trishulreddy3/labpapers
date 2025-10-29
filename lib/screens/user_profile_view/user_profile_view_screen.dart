import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_profile.dart';

class UserProfileViewScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const UserProfileViewScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<UserProfileViewScreen> createState() => _UserProfileViewScreenState();
}

class _UserProfileViewScreenState extends State<UserProfileViewScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  int _userPapersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserPapers();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get user ID from email (Firebase Auth UID or email)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          _userProfile = UserProfile.fromMap(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPapers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('papers')
          .where('uploadedByEmail', isEqualTo: widget.userEmail)
          .get();

      setState(() {
        _userPapersCount = querySnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Error loading user papers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'User Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Use profile data or fallback to auth data
    final displayName = _userProfile?.name ?? widget.userName;
    final email = _userProfile?.email ?? widget.userEmail;
    final phone = _userProfile?.phone ?? '';
    final bio = _userProfile?.bio ?? '';
    final photoUrl = _userProfile?.photoUrl;
    final college = _userProfile?.college ?? '';
    final branch = _userProfile?.branch ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => _buildDefaultAvatar(displayName),
                            )
                          : _buildDefaultAvatar(displayName),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),
                  const SizedBox(height: 20),
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms),
                  ],
                ],
              ),
            ),

            // Statistics Cards
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Uploaded Papers',
                      '$_userPapersCount',
                      Icons.upload_outlined,
                      Colors.purple,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 500.ms)
                        .slideX(begin: -0.2, end: 0, duration: 600.ms, delay: 500.ms),
                  ),
                ],
              ),
            ),

            // Personal Information
            if (bio.isNotEmpty || college.isNotEmpty || branch.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Me',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms),
                    const SizedBox(height: 16),
                    if (bio.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.purple.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  bio,
                                  style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 700.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 700.ms),
                    if (college.isNotEmpty || branch.isNotEmpty) ...[
                      if (bio.isNotEmpty) const SizedBox(height: 12),
                      if (college.isNotEmpty)
                        _buildInfoItem(Icons.school, 'College', college)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 800.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 800.ms),
                      if (branch.isNotEmpty) ...[
                        if (college.isNotEmpty) const SizedBox(height: 12),
                        _buildInfoItem(Icons.code, 'Branch', branch)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 900.ms)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 900.ms),
                      ],
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.white, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: GoogleFonts.poppins(
            fontSize: 48,
            color: Colors.purple.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purple.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
