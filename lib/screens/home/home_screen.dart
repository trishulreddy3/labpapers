import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/paper_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/notification_service.dart';
import '../all_papers/all_papers_screen.dart';
import '../my_papers/my_papers_screen.dart';
import '../upload/upload_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../about_us/about_us_screen.dart';
import '../developer_info/developer_info_screen.dart';
import '../contact_us/contact_us_screen.dart';
import '../help_support/help_support_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/paper_card.dart';
import '../../widgets/animated_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationsProvider = Provider.of<NotificationsProvider>(context, listen: false);
    
    if (authProvider.user != null && !_notificationsInitialized) {
      _initializeForLoggedInUser(authProvider.user!.uid, notificationsProvider);
    }
  }

  Future<void> _initializeForLoggedInUser(String userId, NotificationsProvider notificationsProvider) async {
    // Initialize notification service
    await NotificationService.initialize(userId);
    
    // Load notifications
    notificationsProvider.loadNotifications(userId);
    
    setState(() {
      _notificationsInitialized = true;
    });
  }

  List<Widget> get _screens => [
    HomeContentScreen(onBrowsePapersTap: () => _onTabChanged(1)),
    const AllPapersScreen(),
    const ProfileScreen(),
    const SearchScreen(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    Provider.of<AuthProvider>(context, listen: false).removeListener(_onAuthStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.user == null) {
          return const LoginScreen();
        }

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.purple.shade600],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          authProvider.user?.displayName?[0].toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.user?.displayName ?? 'User',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '| Main',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  selected: _currentIndex == 0,
                  onTap: () {
                    _onTabChanged(0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_books_outlined),
                  title: const Text('Browse Papers'),
                  selected: _currentIndex == 1,
                  onTap: () {
                    _onTabChanged(1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('My Papers'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPapersScreen()),
                    );
                  },
                ),
                // Only show Login if not authenticated
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.user != null) return const SizedBox.shrink();
                    return ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Login'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    );
                  },
                ),
                
                const Divider(),
                
                // Information Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    '| Information',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Us'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_mail_outlined),
                  title: const Text('Contact Us'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                    );
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: const Text('Upload Paper'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  selected: _currentIndex == 2,
                  onTap: () {
                    _onTabChanged(2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.search_outlined),
                  title: const Text('Search'),
                  selected: _currentIndex == 3,
                  onTap: () {
                    _onTabChanged(3);
                    Navigator.pop(context);
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                
                ListTile(
                  leading: const Icon(Icons.developer_mode),
                  title: const Text('Developer Info'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeveloperInfoScreen()),
                    );
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.logout_outlined),
                  title: const Text('Logout'),
                  onTap: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: Text(
              _getTitle(),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.upload_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadScreen()),
                  );
                },
              ),
            ],
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabChanged,
          ),
        );
      },
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'All Papers';
      case 2:
        return 'Profile';
      case 3:
        return 'Search';
      default:
        return 'Question Papers';
    }
  }
}

class HomeContentScreen extends StatelessWidget {
  final VoidCallback onBrowsePapersTap;
  
  const HomeContentScreen({super.key, required this.onBrowsePapersTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
          // Hero Section with Statistics
          Consumer<PaperProvider>(
            builder: (context, paperProvider, _) {
              // Calculate real statistics
              final papers = paperProvider.allPapers;
              final uniqueUniversities = papers.map((p) => p.collegeName).toSet().length;
              final uniqueBranches = papers.map((p) => p.branch).toSet().length;
              final uniqueYears = papers.map((p) => p.year).toSet().length;
              final totalPapers = papers.length;

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.indigo.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                      child: Column(
                        children: [
                          Text(
                      'EduPapers',
                            style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                              color: Colors.white,
                        letterSpacing: 1.5,
                            ),
                          ),
                    const SizedBox(height: 8),
                          Text(
                      'Academic Excellence',
                            style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Statistics Grid
                    Row(
                      children: [
                        Expanded(child: _buildModernStat('$uniqueUniversities${uniqueUniversities > 0 ? '+' : ''}', 'Universities', Icons.school)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModernStat('$uniqueBranches', 'Branches', Icons.code)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildModernStat('$uniqueYears', 'Years', Icons.calendar_today)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModernStat('$totalPapers${totalPapers > 0 ? '+' : ''}', 'Papers', Icons.library_books)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Quick Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Protected Content',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Access thousands of previous year question papers from top engineering universities',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Universities Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Top Universities',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onBrowsePapersTap,
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Universities Horizontal Scroll
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildModernUniversity('VJIT', 'Vignan\'s'),
                const SizedBox(width: 12),
                _buildModernUniversity('JBIT', 'Jyothishmathi'),
                const SizedBox(width: 12),
                _buildModernUniversity('JNTU', 'Jawaharlal Nehru'),
                const SizedBox(width: 12),
                _buildModernUniversity('MGIT', 'Mahatma Gandhi'),
                const SizedBox(width: 12),
                _buildModernUniversity('VNRVJIT', 'VNR Vignana'),
                const SizedBox(width: 12),
                _buildModernUniversity('Vardhaman', 'Vardhaman'),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Branches Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Engineering Branches',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Comprehensive coverage for all major disciplines',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Branches Grid - 2 columns responsive
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Builder(
              builder: (context) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildModernBranch(context, 'CSE', 'Computer Science', 0),
                  _buildModernBranch(context, 'ECE', 'Electronics', 1),
                  _buildModernBranch(context, 'AI', 'Artificial Intelligence', 2),
                  _buildModernBranch(context, 'AIML', 'AI & ML', 3),
                  _buildModernBranch(context, 'AIDS', 'AI & Data Science', 4),
                  _buildModernBranch(context, 'EEE', 'Electrical', 5),
                  _buildModernBranch(context, 'MECH', 'Mechanical', 6),
                  _buildModernBranch(context, 'CIVIL', 'Civil', 7),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Recent Papers Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Papers',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onBrowsePapersTap,
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Consumer<PaperProvider>(
              builder: (context, paperProvider, _) {
                if (paperProvider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                );
                }
                
                final papers = paperProvider.allPapers.take(5).toList();
                
                if (papers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No papers available',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                            fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: PaperCard(paper: papers[index]),
                    );
                  },
                );
              },
            ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildModernStat(String count, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernUniversity(String abbreviation, String shortName) {
    final colors = [
      [Colors.purple, Colors.deepPurple],
      [Colors.blue, Colors.indigo],
      [Colors.teal, Colors.cyan],
      [Colors.orange, Colors.deepOrange],
      [Colors.green, Colors.teal],
      [Colors.pink, Colors.red],
    ];
    final colorPair = colors[abbreviation.length % colors.length];
    
    return Container(
      width: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorPair[0].shade100, colorPair[1].shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorPair[0].shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorPair[0].shade600, colorPair[1].shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            abbreviation,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorPair[0].shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shortName,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildModernBranch(BuildContext context, String branch, String fullName, int index) {
    final colors = [
      [Colors.blue, Colors.indigo],
      [Colors.purple, Colors.deepPurple],
      [Colors.teal, Colors.cyan],
      [Colors.orange, Colors.amber],
      [Colors.green, Colors.lightGreen],
      [Colors.pink, Colors.red],
      [Colors.red, Colors.deepOrange],
      [Colors.indigo, Colors.blue],
    ];
    final colorPair = colors[index % colors.length];
    
    return Container(
      width: (MediaQuery.of(context).size.width - 50) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorPair[0].shade50, colorPair[1].shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorPair[0].shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorPair[0].shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              branch,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorPair[0].shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
