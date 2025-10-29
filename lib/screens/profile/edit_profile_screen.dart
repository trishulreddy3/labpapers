import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({super.key, required this.userProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _collegeController = TextEditingController();
  
  final FirebaseService _firebaseService = FirebaseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  String? _photoUrl;
  File? _imageFile;
  bool _isLoading = false;
  String? _selectedBranch;
  int? _selectedYear;
  String? _selectedSemester;

  final List<String> _branches = [
    'AI',
    'AIML',
    'CSE',
    'ECE',
    'EEE',
    'Civil',
    'Mech',
  ];

  final List<int> _years = [1, 2, 3, 4];

  final List<String> _semesters = ['1st Semester', '2nd Semester'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userProfile.name;
    _phoneController.text = widget.userProfile.phone ?? '';
    _bioController.text = widget.userProfile.bio ?? '';
    _collegeController.text = widget.userProfile.college ?? '';
    _selectedBranch = widget.userProfile.branch;
    _selectedYear = widget.userProfile.year;
    _selectedSemester = widget.userProfile.semester;
    _photoUrl = widget.userProfile.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    _setLoading(true);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final uploadedUrl = await _cloudinaryService.uploadFile(_imageFile!, fileName);
    
    if (uploadedUrl != null) {
      setState(() {
        _photoUrl = uploadedUrl;
        _imageFile = null;
      });
    }
    
    _setLoading(false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);

    // Upload image if selected
    String? finalPhotoUrl = _photoUrl;
    if (_imageFile != null) {
      finalPhotoUrl = await _cloudinaryService.uploadFile(
        _imageFile!,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final updatedProfile = widget.userProfile.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      bio: _bioController.text,
      college: _collegeController.text,
      branch: _selectedBranch,
      year: _selectedYear,
      semester: _selectedSemester,
      photoUrl: finalPhotoUrl,
      updatedAt: DateTime.now(),
    );

    final success = await _firebaseService.updateUserProfile(updatedProfile);

    _setLoading(false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.shade300, width: 3),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : _photoUrl != null && _photoUrl!.isNotEmpty
                                ? Image.network(_photoUrl!, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.blue.shade50,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.blue.shade300,
                                    ),
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue.shade600,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_imageFile != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Upload Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Name Field
              Text(
                'Name',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),

              const SizedBox(height: 20),

              // Phone Field
              Text(
                'Phone',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // Bio Field
              Text(
                'Bio',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us about yourself',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // College Field
              Text(
                'College',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _collegeController,
                decoration: InputDecoration(
                  hintText: 'Enter your college name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
              ),

              const SizedBox(height: 20),

              // Branch Field
              Text(
                'Branch',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.code_outlined),
                ),
                items: _branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedBranch = value);
                },
              ),

              const SizedBox(height: 24),

              // Year
              Text(
                'Year',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  hintText: 'Select Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                items: _years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text('Year $year'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedYear = value);
                },
              ),

              const SizedBox(height: 24),

              // Semester
              Text(
                'Semester',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  hintText: 'Select Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.event_outlined),
                ),
                items: _semesters.map((semester) {
                  return DropdownMenuItem(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSemester = value);
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
