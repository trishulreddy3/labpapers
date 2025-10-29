import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../../models/paper_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/paper_provider.dart';
import '../edit_paper/edit_paper_screen.dart';
import '../user_profile_view/user_profile_view_screen.dart';

class PaperDetailsScreen extends StatefulWidget {
  final Paper paper;

  const PaperDetailsScreen({super.key, required this.paper});

  @override
  State<PaperDetailsScreen> createState() => _PaperDetailsScreenState();
}

class _PaperDetailsScreenState extends State<PaperDetailsScreen> {
  Map<String, dynamic>? uploaderData;

  @override
  void initState() {
    super.initState();
    _loadUploaderData();
  }

  Future<void> _loadUploaderData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.paper.uploadedByEmail)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          uploaderData = userDoc.data();
        });
      }
    } catch (e) {
      debugPrint('Error loading uploader data: $e');
    }
  }

  Future<void> _downloadFile() async {
    try {
      // For Android 15, permissions might not be needed for Downloads folder
      // Just start the download directly
      await _startDownload();
    } catch (e) {
      debugPrint('Error in download: $e');
      if (mounted) {
        // Show detailed error message
        final errorMsg = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $errorMsg'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _downloadFile(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _startDownload() async {
    String? savedFilePath;
    
    try {
      // Show download dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Downloading...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Download image file directly to Pictures folder
      final dio = Dio();
      
      // Use fileUrl for image, fallback to pdfUrl if needed
      final downloadUrl = widget.paper.fileUrl.isNotEmpty 
          ? widget.paper.fileUrl 
          : widget.paper.pdfUrl;
      
      debugPrint('Downloading image from: $downloadUrl');
      
      // Get Pictures directory on Android
      Directory? downloadDir;
      if (Platform.isAndroid) {
        // Try Pictures folder first (accessible by gallery)
        final picturesDir = Directory('/storage/emulated/0/Pictures');
        if (!await picturesDir.exists()) {
          picturesDir.createSync(recursive: true);
        }
        downloadDir = picturesDir;
      } else {
        // For other platforms, use downloads directory
        downloadDir = await getDownloadsDirectory();
      }
      
      if (downloadDir == null) {
        throw Exception('Could not access download directory');
      }
      
      // Create filename
      final cleanTitle = widget.paper.title.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final fileName = '${cleanTitle}_${widget.paper.id}.jpg';
      final filePath = '${downloadDir.path}/$fileName';
      savedFilePath = filePath;
      
      debugPrint('Saving to: $filePath');
      
      // Download and save file
      await dio.download(downloadUrl, filePath);
      
      debugPrint('Image saved successfully to: $filePath');
      
      // For Android, scan the file so it appears in the gallery
      if (Platform.isAndroid) {
        final file = File(filePath);
        if (await file.exists()) {
          debugPrint('File exists, size: ${await file.length()} bytes');
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Image Downloaded!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Image saved to gallery successfully!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 Location:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        savedFilePath ?? 'Gallery',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              if (savedFilePath != null)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await OpenFilex.open(savedFilePath!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                  ),
                  child: const Text('Open'),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paper Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final isOwner = authProvider.user?.email == widget.paper.uploadedByEmail;
              if (!isOwner) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPaperScreen(paper: widget.paper),
                    ),
                  );
                  
                  if (result == true && mounted) {
                    // Refresh the paper data
                    setState(() {});
                  }
                },
                tooltip: 'Edit Paper',
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Paper Image Section with Animations
              if (widget.paper.fileUrl.isNotEmpty)
                Hero(
                  tag: widget.paper.id,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 280,
                      maxHeight: 400,
                    ),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.paper.fileUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.indigo.shade600],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.indigo.shade600],
                          ),
                        ),
                        child: const Icon(Icons.image_outlined, size: 80, color: Colors.white),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0),

              // Modern Header Section with College Name
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.indigo.shade800],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade300.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branch Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            widget.paper.branch,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      widget.paper.title,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // College Name - PROMINENT
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.school, size: 20, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.paper.collegeName,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 100.ms),

              // Info Cards Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (widget.paper.subject != null)
                      _buildModernInfoCard(
                        Icons.book,
                        'Subject',
                        widget.paper.subject!,
                        Colors.teal,
                        0,
                      ),
                    if (widget.paper.subject != null) const SizedBox(height: 12),
                    _buildModernInfoCard(
                      Icons.calendar_today,
                      'Academic Year',
                      'Year ${widget.paper.year}',
                      Colors.orange,
                      1,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInfoCard(
                      Icons.description,
                      'Exam Type',
                      widget.paper.examinationType,
                      Colors.purple,
                      2,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInfoCard(
                      Icons.code,
                      'Branch',
                      widget.paper.branch,
                      Colors.blue,
                      3,
                    ),
                  ],
                ),
              ),

              // Description Section
              if (widget.paper.description != null && widget.paper.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes, color: Colors.indigo.shade600, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Description',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.paper.description!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 350.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 350.ms),

              const SizedBox(height: 24),

              // Uploader Card with Animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildModernUploaderCard()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms),
              ),

              const SizedBox(height: 24),

              // Statistics with Animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedStatCard(
                        Icons.download,
                        'Downloads',
                        '${widget.paper.downloads}',
                        Colors.blue,
                        2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAnimatedStatCard(
                        Icons.favorite,
                        'Likes',
                        '${widget.paper.likes}',
                        Colors.pink,
                        3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons with Animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildActionButtons()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 500.ms),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLiked = widget.paper.likedBy.contains(authProvider.user?.email ?? '');
        
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final paperProvider = Provider.of<PaperProvider>(context, listen: false);
                  final userEmail = authProvider.user?.email ?? '';
                  
                  final downloaded = await paperProvider.incrementDownload(widget.paper.id, userEmail);
                  
                  if (downloaded) {
                    // Start actual file download
                    await _downloadFile();
                  } else {
                    // If already downloaded, just download the file again
                    await _downloadFile();
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Paper'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final paperProvider = Provider.of<PaperProvider>(context, listen: false);
                  final userEmail = authProvider.user?.email ?? '';
                  await paperProvider.toggleLike(widget.paper.id, userEmail);
                },
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                label: Text(isLiked ? 'Liked' : 'Like'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isLiked ? Colors.red : Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final url = Uri.parse(widget.paper.pdfUrl);
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open URL: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Browser'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileViewScreen(
                        userEmail: widget.paper.uploadedByEmail,
                        userName: widget.paper.uploadedBy,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Text('View User Profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.purple),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernInfoCard(IconData icon, String label, String value, Color color, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (100 * index).ms)
        .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: (100 * index).ms);
  }

  Widget _buildModernUploaderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: uploaderData?['photoUrl'] != null
                  ? CachedNetworkImageProvider(uploaderData!['photoUrl'])
                  : null,
              child: uploaderData?['photoUrl'] == null
                  ? Text(
                      (uploaderData?['name']?.toString().isNotEmpty ?? false)
                          ? uploaderData!['name'][0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uploaderData?['name'] ?? widget.paper.uploadedBy,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.paper.uploadedByEmail,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uploaded ${DateFormat('MMM d, y • h:mm a').format(widget.paper.uploadedAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatCard(IconData icon, String label, String value, Color color, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (120 * index).ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms, delay: (120 * index).ms);
  }
}
