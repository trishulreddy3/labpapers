import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/paper_provider.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../auth/login_screen.dart';
import '../my_papers/my_papers_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  UserProfile? _userProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      final profile = await _firebaseService.getUserProfile(user.uid);
      
      if (profile == null && user.email != null) {
        // Create initial profile
        final newProfile = UserProfile(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email!,
          phone: '',
          bio: '',
          photoUrl: user.photoURL,
          year: null,
          semester: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firebaseService.createUserProfile(newProfile);
        setState(() => _userProfile = newProfile);
      } else {
        setState(() => _userProfile = profile);
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PaperProvider>(
      builder: (context, authProvider, paperProvider, _) {
        final user = authProvider.user;
        
        if (user == null) {
          return const Center(child: Text('Not logged in'));
        }

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Use profile data or fallback to auth user data
        final displayName = _userProfile?.name ?? user.displayName ?? 'User';
        final email = _userProfile?.email ?? user.email ?? '';
        final phone = _userProfile?.phone ?? '';
        final bio = _userProfile?.bio ?? '';
        final photoUrl = _userProfile?.photoUrl ?? user.photoURL;
        final college = _userProfile?.college ?? '';
        final branch = _userProfile?.branch ?? '';
        final year = _userProfile?.year;
        final semester = _userProfile?.semester;
        
        // Check if user signed in with email/password
        final bool isEmailPasswordUser = user.providerData.first.providerId == 'password';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profile',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        userProfile: _userProfile ?? UserProfile(
                          id: user.uid,
                          name: displayName,
                          email: email,
                          phone: phone,
                          bio: bio,
                          photoUrl: photoUrl,
                          college: college,
                          branch: branch,
                        ),
                      ),
                    ),
                  );

                  if (result == true) {
                    _loadUserProfile();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Profile Header with Photo and Basic Info
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.indigo.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 60, bottom: 32, left: 24, right: 24),
                  child: Column(
                    children: [
                      // Profile Photo
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(displayName),
                                )
                              : _buildDefaultAvatar(displayName),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
                      const SizedBox(height: 16),
                      
                      // Name
                Text(
                        displayName,
                  style: GoogleFonts.poppins(
                          fontSize: 26,
                    fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 100.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 100.ms),
                      const SizedBox(height: 8),
                      
                      // Email
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, size: 16, color: Colors.white.withOpacity(0.9)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 200.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms),
                    ],
                  ),
                ),

                // Statistics Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          'Papers',
                          '${paperProvider.myPapers.length}',
                          Icons.article_outlined,
                          Colors.blue,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms)
                            .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: 300.ms),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernStatCard(
                          'Downloads',
                          '${paperProvider.myPapers.fold<int>(0, (sum, paper) => sum + paper.downloads)}',
                          Icons.download_outlined,
                          Colors.green,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 350.ms)
                            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 350.ms),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernStatCard(
                          'Likes',
                          '${paperProvider.myPapers.fold<int>(0, (sum, paper) => sum + paper.likes)}',
                          Icons.favorite_outline,
                          Colors.red,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms)
                            .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms),
                      ),
                    ],
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.folder_outlined,
                          label: 'My Papers',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyPapersScreen(),
                              ),
                            );
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 500.ms),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: Colors.orange,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  userProfile: _userProfile ?? UserProfile(
                                    id: user.uid,
                                    name: displayName,
                                    email: email,
                                    phone: phone,
                                    bio: bio,
                                    photoUrl: photoUrl,
                                    college: college,
                                    branch: branch,
                                    year: year,
                                    semester: semester,
                                  ),
                                ),
                              ),
                            );
                            if (result == true) {
                              _loadUserProfile();
                            }
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 550.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 550.ms),
                      ),
                    ],
                  ),
                ),

                // Personal Information Card
                if (bio.isNotEmpty || college.isNotEmpty || branch.isNotEmpty || year != null || semester != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_outline, color: Colors.blue.shade600, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Personal Information',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (college.isNotEmpty)
                              _buildInfoRow(Icons.school_outlined, 'College', college),
                            if (branch.isNotEmpty) ...[
                              if (college.isNotEmpty) const SizedBox(height: 12),
                              _buildInfoRow(Icons.code, 'Branch', branch),
                            ],
                            if (year != null) ...[
                              if (branch.isNotEmpty) const SizedBox(height: 12),
                              _buildInfoRow(Icons.calendar_today_outlined, 'Year', 'Year $year'),
                            ],
                            if (semester != null) ...[
                              if (year != null) const SizedBox(height: 12),
                              _buildInfoRow(Icons.event_outlined, 'Semester', semester),
                            ],
                            if (phone.isNotEmpty) ...[
                              if (semester != null) const SizedBox(height: 12),
                              _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
                            ],
                            if (bio.isNotEmpty) ...[
                const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bio,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 600.ms),
                  ),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.settings_outlined, color: Colors.grey.shade700, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Account Settings',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        
                        // Change Password (only for email/password users)
                        if (isEmailPasswordUser)
                          _buildSettingsItem(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            color: Colors.orange,
                            onTap: () => _showChangePasswordDialog(context, authProvider),
                          ),
                        
                        if (isEmailPasswordUser) const Divider(height: 1),
                        
                        // Delete Account
                        _buildSettingsItem(
                          icon: Icons.delete_outline,
                          title: 'Delete Account',
                          color: Colors.red,
                          onTap: () => _showDeleteAccountDialog(context, authProvider),
                        ),
                      ],
                    ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 700.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 700.ms),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(duration: 400.ms, delay: 800.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 800.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: GoogleFonts.poppins(
            fontSize: 48,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              // TODO: Implement change password logic
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password change feature coming soon!')),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Account?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. This will permanently delete your account and all associated data.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement delete account logic
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deletion feature coming soon!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}