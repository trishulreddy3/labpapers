import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/paper_provider.dart';
import '../../widgets/paper_card.dart';

class AllPapersScreen extends StatelessWidget {
  const AllPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaperProvider>(
      builder: (context, paperProvider, _) {
        if (paperProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final papers = paperProvider.allPapers;

        if (papers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No papers available',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey.shade600,
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
    );
  }
}
