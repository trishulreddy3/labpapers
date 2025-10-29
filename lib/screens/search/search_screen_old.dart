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

                    // Filters Section
                    if (_showFilters)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Filter Papers',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedCollege,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                labelText: 'College',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              hint: const Text('All Colleges'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Colleges'),
                                ),
                                ..._colleges.map((college) {
                                  return DropdownMenuItem(
                                    value: college,
                                    child: Text(college),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedCollege = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedBranch,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                labelText: 'Branch',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              hint: const Text('All Branches'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Branches'),
                                ),
                                ..._branches.map((branch) {
                                  return DropdownMenuItem(
                                    value: branch,
                                    child: Text(branch),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedBranch = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedYear,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                labelText: 'Academic Year',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              hint: const Text('All Years'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Years'),
                                ),
                                ...List.generate(_years.length, (index) {
                                  return DropdownMenuItem(
                                    value: _years[index],
                                    child: Text(_yearLabels[index]),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedYear = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedExamType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                labelText: 'Exam Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              hint: const Text('All Exam Types'),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Exam Types'),
                                ),
                                ..._examTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedExamType = value);
                                _applyFilters(paperProvider);
                              },
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.2, end: 0, duration: 400.ms),
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
}
