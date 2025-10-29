import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../about_us/about_us_screen.dart';
import '../contact_us/contact_us_screen.dart';
import '../help_support/help_support_screen.dart';
import '../developer_info/developer_info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          children: [
            // Profile Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.user;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.indigo.shade800],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade300.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(Icons.person, size: 35, color: Colors.blue.shade600)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'User',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'No email',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0);
              },
            ),
            
            const SizedBox(height: 24),

            // Account Settings
            _buildSectionHeader('Account Settings').animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () => _navigateToProfile(context),
              delay: 2,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.notifications_active,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () => _showNotificationsSettings(context),
              delay: 3,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: 'Privacy & Security',
              subtitle: 'Control your data and privacy',
              onTap: () => _showPrivacySettings(context),
              delay: 4,
            ),

            const SizedBox(height: 24),

            // App Settings
            _buildSectionHeader('App Settings').animate().fadeIn(duration: 500.ms, delay: 300.ms),
            const SizedBox(height: 12),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return _buildSettingTile(
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  subtitle: 'Light',
                  onTap: () => _showThemeDialog(context),
                  delay: 5,
                );
              },
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () => _showLanguageDialog(context),
              delay: 6,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.storage,
              title: 'Storage',
              subtitle: 'Manage app data',
              onTap: () => _showStorageDialog(context),
              delay: 7,
            ),

            const SizedBox(height: 24),

            // Support & Information
            _buildSectionHeader('Support & Information').animate().fadeIn(duration: 500.ms, delay: 400.ms),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and support',
              onTap: () => _navigateToHelp(context),
              delay: 8,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'About Us',
              subtitle: 'Learn more about the app',
              onTap: () => _navigateToAbout(context),
              delay: 9,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.contact_support,
              title: 'Contact Us',
              subtitle: 'Get in touch with us',
              onTap: () => _navigateToContact(context),
              delay: 10,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.code,
              title: 'Developer Info',
              subtitle: 'Meet the developer',
              onTap: () => _navigateToDeveloper(context),
              delay: 11,
            ),

            const SizedBox(height: 24),

            // Legal
            _buildSectionHeader('Legal').animate().fadeIn(duration: 500.ms, delay: 500.ms),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.description,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms of service',
              onTap: () => _showTermsDialog(context),
              delay: 12,
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Our privacy policy',
              onTap: () => _showPrivacyPolicyDialog(context),
              delay: 13,
            ),

            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionHeader('Account Actions').animate().fadeIn(duration: 500.ms, delay: 600.ms),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out from your account',
              onTap: () => _showLogoutDialog(context),
              delay: 14,
              isDestructive: true,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.shade100
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.blue.shade600,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red.shade700 : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (50 * delay).ms)
        .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: (50 * delay).ms);
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to edit your profile')),
        );
        return;
      }

      final firebaseService = FirebaseService();
      UserProfile? userProfile = await firebaseService.getUserProfile(user.uid);
      
      if (userProfile == null) {
        // Create a basic profile if it doesn't exist
        userProfile = UserProfile.fromFirebaseUser(user);
        await firebaseService.createUserProfile(userProfile);
      }

      if (context.mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(userProfile: userProfile!),
          ),
        );
        
        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  void _showNotificationsSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Settings',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text('Push Notifications', style: GoogleFonts.poppins()),
              subtitle: Text('Receive push notifications', style: GoogleFonts.poppins(fontSize: 12)),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('Email Notifications', style: GoogleFonts.poppins()),
              subtitle: Text('Receive email updates', style: GoogleFonts.poppins(fontSize: 12)),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('New Paper Alerts', style: GoogleFonts.poppins()),
              subtitle: Text('Get notified about new papers', style: GoogleFonts.poppins(fontSize: 12)),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Privacy & Security',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Change Password', style: GoogleFonts.poppins()),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Password feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.devices),
              title: Text('Connected Devices', style: GoogleFonts.poppins()),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connected Devices feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete Account', style: GoogleFonts.poppins(color: Colors.red)),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete Account feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Theme', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text('Light', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings_brightness),
              title: Text('System Default', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.language),
              title: Text('English', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Hindi', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Telugu', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Management', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('App Data: 150 MB', style: GoogleFonts.poppins()),
            Text('Cache: 25 MB', style: GoogleFonts.poppins()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully!')),
                );
              },
              child: const Text('Clear Cache'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
    );
  }

  void _navigateToContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactUsScreen()),
    );
  }

  void _navigateToDeveloper(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeveloperInfoScreen()),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'By using this application, you agree to our terms and conditions. You are responsible for maintaining the confidentiality of your account...',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and protect your information...',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out?', style: GoogleFonts.poppins()),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    }
  }
}

