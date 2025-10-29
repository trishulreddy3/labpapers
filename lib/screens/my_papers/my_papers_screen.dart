import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/paper_provider.dart';
import '../../widgets/paper_card.dart';

class MyPapersScreen extends StatefulWidget {
  const MyPapersScreen({super.key});

  @override
  State<MyPapersScreen> createState() => _MyPapersScreenState();
}

class _MyPapersScreenState extends State<MyPapersScreen> {
  @override
  void initState() {
    super.initState();
    // Defer the call to after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<PaperProvider>(context, listen: false)
            .loadMyPapers(authProvider.user!.email!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Papers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Consumer2<PaperProvider, AuthProvider>(
        builder: (context, paperProvider, authProvider, _) {
          if (paperProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final papers = paperProvider.myPapers;

          if (papers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No papers uploaded yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your first paper!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
    );
  }
}
