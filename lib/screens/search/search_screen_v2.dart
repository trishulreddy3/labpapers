import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/paper_provider.dart';
import '../../widgets/paper_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCollege;
  int? _selectedYear;
  String? _selectedBranch;
  String? _selectedExamType;

  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'AI', 'AIML', 'AI & DS'];
  final List<String> _examTypes = ['Mid-1 Papers', 'Mid-2 Papers', 'Sem Paper', 'Lab Manual', 'Assignments'];
  final List<int> _years = [1, 2, 3, 4];
  final List<String> _yearLabels = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> _colleges = [
    'VJIT', 'JBIT', 'VNR VJIET', 'Vardhaman', 'MGIT', 'CBIT', 'JNTU',
    'Mallareddy', 'Narayanamma', 'Mahendra University', 'Nalla Malla Reddy',
    'KL University', 'Guru Nanak GNIT', 'KG Reddy',
  ];

  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(PaperProvider paperProvider, String query) {
    if (query.isEmpty) {
      paperProvider.clearFilters();
      return;
    }

    final allPapers = paperProvider.allPapers;
    final searchLower = query.toLowerCase();

    final filtered = allPapers.where((paper) {
      return paper.title.toLowerCase().contains(searchLower) ||
          (paper.subject?.toLowerCase().contains(searchLower) ?? false) ||
          paper.collegeName.toLowerCase().contains(searchLower) ||
          paper.branch.toLowerCase().contains(searchLower) ||
          paper.examinationType.toLowerCase().contains(searchLower) ||
          (paper.description?.toLowerCase().contains(searchLower) ?? false);
    }).toList();

    paperProvider.setFilteredPapers(filtered);
  }

  void _applyFilters(PaperProvider paperProvider) {
    final allPapers = paperProvider.allPapers;
    
    var filtered = allPapers.where((paper) {
      if (_selectedCollege != null && paper.collegeName != _selectedCollege) return false;
      if (_selectedYear != null && paper.year != _selectedYear) return false;
      if (_selectedBranch != null && paper.branch != _selectedBranch) return false;
      if (_selectedExamType != null && paper.examinationType != _selectedExamType) return false;
      return true;
    }).toList();

    // Also apply search query if exists
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      filtered = filtered.where((paper) {
        return paper.title.toLowerCase().contains(searchLower) ||
            (paper.subject?.toLowerCase().contains(searchLower) ?? false) ||
            paper.collegeName.toLowerCase().contains(searchLower) ||
            paper.branch.toLowerCase().contains(searchLower) ||
            paper.examinationType.toLowerCase().contains(searchLower) ||
            (paper.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    paperProvider.setFilteredPapers(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaperProvider>(
      builder: (context, paperProvider, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              // Search Bar Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search papers by title, subject, college, branch...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey.shade400),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFilters(paperProvider);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onChanged: (value) => _performSearch(paperProvider, value),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 12),

                    // Filter Toggle Button
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _showFilters = !_showFilters);
                            },
                            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
                            label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.blue.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedCollege = null;
                              _selectedYear = null;
                              _selectedBranch = null;
                              _selectedExamType = null;
                              _searchController.clear();
                            });
                            paperProvider.clearFilters();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear All'),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideY(begin: -0.2, end: 0, duration: 500.ms, delay: 100.ms),

                    // MODERN FILTERS SECTION
                    if (_showFilters)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.blue.shade200, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade100.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade600, Colors.indigo.shade600],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.filter_alt,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Filter Papers',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      Text(
                                        'Refine your search results',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Modern Dropdowns with Icons
                            _buildModernDropdown(
                              label: 'College/University',
                              icon: Icons.school,
                              value: _selectedCollege,
                              items: _colleges,
                              onChanged: (value) {
                                setState(() => _selectedCollege = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            _buildModernDropdown(
                              label: 'Engineering Branch',
                              icon: Icons.code,
                              value: _selectedBranch,
                              items: _branches,
                              onChanged: (value) {
                                setState(() => _selectedBranch = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            _buildModernDropdownYear(
                              label: 'Academic Year',
                              icon: Icons.calendar_today,
                              value: _selectedYear,
                              onChanged: (value) {
                                setState(() => _selectedYear = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            _buildModernDropdown(
                              label: 'Examination Type',
                              icon: Icons.description,
                              value: _selectedExamType,
                              items: _examTypes,
                              onChanged: (value) {
                                setState(() => _selectedExamType = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            
                            // Active Filters Chips
                            if (_selectedCollege != null || _selectedBranch != null || _selectedYear != null || _selectedExamType != null) ...[
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.filter_alt, size: 18, color: Colors.blue.shade800),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Active Filters',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_selectedCollege != null)
                                    _buildFilterChip('College: $_selectedCollege', () {
                                      setState(() => _selectedCollege = null);
                                      _applyFilters(paperProvider);
                                    }),
                                  if (_selectedBranch != null)
                                    _buildFilterChip('Branch: $_selectedBranch', () {
                                      setState(() => _selectedBranch = null);
                                      _applyFilters(paperProvider);
                                    }),
                                  if (_selectedYear != null)
                                    _buildFilterChip('Year $_selectedYear', () {
                                      setState(() => _selectedYear = null);
                                      _applyFilters(paperProvider);
                                    }),
                                  if (_selectedExamType != null)
                                    _buildFilterChip(_selectedExamType!, () {
                                      setState(() => _selectedExamType = null);
                                      _applyFilters(paperProvider);
                                    }),
                                ],
                              ),
                            ],
                          ],
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                  ],
                ),
              ),

              // Results Section
              Expanded(
                child: paperProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : paperProvider.filteredPapers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No papers found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: paperProvider.filteredPapers.length,
                            itemBuilder: (context, index) {
                              final paper = paperProvider.filteredPapers[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: PaperCard(paper: paper),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: value != null 
                ? LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                  )
                : null,
            color: value == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value != null ? Colors.blue.shade300 : Colors.grey.shade300,
              width: value != null ? 2 : 1,
            ),
            boxShadow: value != null
                ? [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue.shade600, size: 20),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  'All ${label.split(' ')[0]}',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ...items.map((item) {
                final isSelected = item == value;
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : const SizedBox(width: 16, height: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdownYear({
    required String label,
    required IconData icon,
    required int? value,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: value != null 
                ? LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                  )
                : null,
            color: value == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value != null ? Colors.blue.shade300 : Colors.grey.shade300,
              width: value != null ? 2 : 1,
            ),
            boxShadow: value != null
                ? [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<int>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue.shade600, size: 20),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  'All Years',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ...List.generate(_years.length, (index) {
                final isSelected = _years[index] == value;
                return DropdownMenuItem(
                  value: _years[index],
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : const SizedBox(width: 16, height: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _yearLabels[index],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      avatar: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        radius: 12,
        child: Icon(Icons.check, size: 14, color: Colors.blue.shade700),
      ),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade300),
    );
  }
}


