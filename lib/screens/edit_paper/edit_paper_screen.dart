import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/paper_model.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firebase_service.dart';

class EditPaperScreen extends StatefulWidget {
  final Paper paper;

  const EditPaperScreen({super.key, required this.paper});

  @override
  State<EditPaperScreen> createState() => _EditPaperScreenState();
}

class _EditPaperScreenState extends State<EditPaperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _collegeController = TextEditingController();
  
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseService _firebaseService = FirebaseService();
  
  String? _selectedBranch;
  String? _selectedExamType;
  int? _selectedYear;
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  final List<String> _branches = ['AI', 'AIML', 'CSE', 'ECE', 'EEE', 'Civil', 'Mech'];
  final List<String> _examTypes = ['Midterm', 'Final', 'Quiz', 'Assignment', 'Other'];
  final List<int> _years = [2025, 2024, 2023, 2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.paper.title;
    _collegeController.text = widget.paper.collegeName;
    
    // Ensure branch exists in the list
    _selectedBranch = _branches.contains(widget.paper.branch) 
        ? widget.paper.branch 
        : _branches.first;
    
    // Ensure exam type exists in the list
    _selectedExamType = _examTypes.contains(widget.paper.examinationType) 
        ? widget.paper.examinationType 
        : _examTypes.first;
    
    // Ensure the year exists in the list
    if (_years.contains(widget.paper.year)) {
      _selectedYear = widget.paper.year;
    } else {
      _selectedYear = _years.first;
    }
    
    _imageUrl = widget.paper.fileUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = null;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = null;
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrl ?? widget.paper.fileUrl;
      
      // Upload new image if selected
      if (_imageFile != null) {
        final imageUrl = await _cloudinaryService.uploadFile(_imageFile!, 'paper_${DateTime.now().millisecondsSinceEpoch}.jpg');
        if (imageUrl != null) {
          finalImageUrl = imageUrl;
        }
      }

      final updatedPaper = widget.paper.copyWith(
        title: _titleController.text.trim(),
        collegeName: _collegeController.text.trim(),
        branch: _selectedBranch!,
        examinationType: _selectedExamType!,
        year: _selectedYear!,
        fileUrl: finalImageUrl,
        pdfUrl: finalImageUrl, // Using same URL for now
      );

      await _firebaseService.uploadPaper(updatedPaper);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paper updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating paper: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Paper',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Image
              if (widget.paper.fileUrl.isNotEmpty || _imageFile != null)
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                          )
                        : Image.network(
                            widget.paper.fileUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Change Image Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showImagePicker,
                  icon: const Icon(Icons.photo),
                  label: const Text('Change Image'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Paper Title',
                  hintText: 'Enter paper title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // College
              TextFormField(
                controller: _collegeController,
                decoration: InputDecoration(
                  labelText: 'College Name',
                  hintText: 'Enter college name',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter college name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Year Dropdown
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Year',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text('$year'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedYear = value);
                },
                validator: (value) => value == null ? 'Please select a year' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Branch Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: InputDecoration(
                  labelText: 'Branch',
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                validator: (value) => value == null ? 'Please select a branch' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Exam Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedExamType,
                decoration: InputDecoration(
                  labelText: 'Examination Type',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _examTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedExamType = value);
                },
                validator: (value) => value == null ? 'Please select exam type' : null,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save Changes',
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
