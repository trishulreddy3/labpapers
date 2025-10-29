import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/paper_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newCollegeController = TextEditingController();
  
  String? _selectedBranch;
  int? _selectedYear;
  String? _selectedExamType;
  String? _selectedCollege;
  bool _isNewCollege = false;
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'AI', 'AIML', 'AI & DS'];
  final List<String> _examTypes = ['Mid-1 Papers', 'Mid-2 Papers', 'Sem Paper', 'Lab Manual', 'Assignments'];
  final List<int> _years = [1, 2, 3, 4];
  final List<String> _yearLabels = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> _colleges = [
    'VJIT',
    'JBIT',
    'VNR VJIET',
    'Vardhaman',
    'MGIT',
    'CBIT',
    'JNTU',
    'Mallareddy',
    'Narayanamma',
    'Mahendra University',
    'Nalla Malla Reddy',
    'KL University',
    'Guru Nanak GNIT',
    'KG Reddy',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _newCollegeController.dispose();
    super.dispose();
  }

  Future<void> _showFileSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _selectedFile = File(image.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _selectedFile = File(image.path));
    }
  }

  String? _validateCollege() {
    if (_isNewCollege) {
      if (_newCollegeController.text.trim().isEmpty) {
        return 'Please enter college name';
      }
    } else {
      if (_selectedCollege == null) {
        return 'Please select a college';
      }
    }
    return null;
  }

  Future<void> _uploadPaper() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paperProvider = Provider.of<PaperProvider>(context, listen: false);

    final collegeName = _isNewCollege 
        ? _newCollegeController.text.trim()
        : _selectedCollege!;

    final success = await paperProvider.uploadPaper(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      collegeName: collegeName,
      year: _selectedYear!,
      branch: _selectedBranch!,
      examinationType: _selectedExamType!,
      uploadedBy: authProvider.user?.displayName ?? 'Unknown',
      uploadedByEmail: authProvider.user?.email ?? '',
      file: _selectedFile!,
    );

    setState(() => _isUploading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paper uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paperProvider.error ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Papers',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // College/University Section
                _buildSectionCard(
                  Icons.school,
                  'College/University *',
                  Column(
                    children: [
                      RadioListTile<bool>(
                        value: false,
                        groupValue: _isNewCollege,
                        title: const Text('Select College/University'),
                        onChanged: (value) => setState(() => _isNewCollege = false),
                      ),
                      if (!_isNewCollege)
                        Padding(
                          padding: const EdgeInsets.only(left: 40, right: 16, bottom: 16),
                          child: DropdownButtonFormField<String>(
                            value: _selectedCollege,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            hint: const Text('Select College'),
                            items: _colleges.map((college) {
                              return DropdownMenuItem(
                                value: college,
                                child: Text(college),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedCollege = value),
                          ),
                        ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<bool>(
                        value: true,
                        groupValue: _isNewCollege,
                        title: const Text('Enter new college/university name'),
                        onChanged: (value) => setState(() => _isNewCollege = true),
                      ),
                      if (_isNewCollege)
                        Padding(
                          padding: const EdgeInsets.only(left: 40, right: 16, bottom: 16),
                          child: TextFormField(
                            controller: _newCollegeController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (_) => _validateCollege(),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Branch
                _buildSectionCard(
                  Icons.engineering,
                  'Engineering Branch *',
                  DropdownButtonFormField<String>(
                    value: _selectedBranch,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Select Branch'),
                    items: _branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedBranch = value),
                    validator: (value) {
                      if (value == null) return 'Please select a branch';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Academic Year
                _buildSectionCard(
                  Icons.calendar_today,
                  'Academic Year *',
                  DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Select Year'),
                    items: List.generate(_years.length, (index) {
                      return DropdownMenuItem(
                        value: _years[index],
                        child: Text(_yearLabels[index]),
                      );
                    }),
                    onChanged: (value) => setState(() => _selectedYear = value),
                    validator: (value) {
                      if (value == null) return 'Please select a year';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Examination Type
                _buildSectionCard(
                  Icons.quiz,
                  'Examination Type *',
                  DropdownButtonFormField<String>(
                    value: _selectedExamType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text('Select Exam Type'),
                    items: _examTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedExamType = value),
                    validator: (value) {
                      if (value == null) return 'Please select exam type';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // File Upload Section
                _buildSectionCard(
                  Icons.image,
                  'Question Paper Images *',
                  GestureDetector(
                    onTap: _showFileSourceDialog,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedFile == null ? Colors.grey.shade300 : Colors.green.shade300,
                          width: 2,
                          style: BorderStyle.values.firstWhere(
                            (style) => _selectedFile == null ? style == BorderStyle.solid : style == BorderStyle.solid,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFile == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                            size: 60,
                            color: _selectedFile == null ? Colors.grey.shade400 : Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile == null
                                ? 'No file chosen'
                                : _selectedFile!.path.split('/').last,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedFile == null ? Colors.grey.shade600 : Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile == null
                                ? 'Drag and drop your images here\nor click to browse'
                                : 'Tap to change file',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  subtitle: 'Supports: JPG, PNG, GIF (Max 10MB each) - Stored securely on Cloudinary',
                ),

                const SizedBox(height: 20),

                // Paper Title
                _buildSectionCard(
                  Icons.title,
                  'Paper Title *',
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'e.g., Data Structures - Mid-1 Exam',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter paper title';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Subject
                _buildSectionCard(
                  Icons.book,
                  'Subject *',
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'e.g., Data Structures',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter subject';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Description (Optional)
                _buildSectionCard(
                  Icons.description,
                  'Description (Optional)',
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Additional details about the question paper...',
                    ),
                    maxLines: 3,
                  ),
                  subtitle: 'Additional details about the question paper...',
                ),

                const SizedBox(height: 30),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadPaper,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Upload Papers',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(IconData icon, String title, Widget content, {String? subtitle}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
