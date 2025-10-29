import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 80,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // FAQ Items
            _buildFAQItem(
              'How do I upload a question paper?',
              'Go to Upload Paper from the sidebar, fill in all the required details (title, college, year, branch, exam type), select your PDF file, and tap Upload. Make sure all information is accurate before submitting.',
            ),
            _buildFAQItem(
              'Can I download papers without logging in?',
              'No, you need to create an account and log in to download question papers. This helps us maintain the quality and track usage.',
            ),
            _buildFAQItem(
              'How do I search for specific papers?',
              'Use the Search feature to filter papers by college name, branch, year, or examination type. You can also use multiple filters together for precise results.',
            ),
            _buildFAQItem(
              'Can I edit or delete my uploaded papers?',
              'Yes, you can edit or delete papers you have uploaded. Simply open the paper details and tap the edit icon that appears if you are the owner.',
            ),
            _buildFAQItem(
              'What file formats are supported?',
              'Currently, we support PDF format (.pdf) for question papers. The file size limit is 10MB per upload.',
            ),
            _buildFAQItem(
              'How do I report a problem or bug?',
              'You can contact us through the Contact Us section or send an email to garena1144q@gmail.com with details about the issue you\'re experiencing.',
            ),
            
            const SizedBox(height: 32),
            
            // Support Contact
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still Need Help?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our support team is ready to assist you. Contact us via:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickContact(
                      Icons.phone,
                      '+91 7386986921',
                      Colors.green,
                      () async {
                        final phone = Uri.parse('tel:+917386986921');
                        if (await canLaunchUrl(phone)) {
                          await launchUrl(phone);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildQuickContact(
                      Icons.email,
                      'garena1144q@gmail.com',
                      Colors.red,
                      () async {
                        final email = Uri.parse('mailto:garena1144q@gmail.com');
                        if (await canLaunchUrl(email)) {
                          await launchUrl(email);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tips Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips for Best Experience',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Use specific keywords when searching for better results'),
                    _buildTip('Keep your uploads organized with clear, descriptive titles'),
                    _buildTip('Share papers you found helpful to help other students'),
                    _buildTip('Report inappropriate or incorrect content immediately'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContact(IconData icon, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
