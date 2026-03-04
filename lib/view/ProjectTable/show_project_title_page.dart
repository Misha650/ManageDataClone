import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ShowProjectGridListPage/show_project_title_page.dart';
import 'ShowProjectGridListPage/showtable/show_total_project_table_page.dart';

class ShowProjectPage extends StatelessWidget {
  const ShowProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view project summary")),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Project Summary"),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.list_alt_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ShowProjectTitlePage()),
                    );
                  },
                ),
              ],
            ),
            body: const Center(child: Text("No projects found")),
          );
        }

        final recentProject = snapshot.data!.docs.first;
        final projectId = recentProject.id;
        final projectName = recentProject['title'] ?? "Untitled";

        return Stack(
          children: [
            ShowTotalProjectTablePage(
              projectId: projectId,
              projectName: projectName,
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 5,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.list_alt_rounded),
                  tooltip: "All Projects",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ShowProjectTitlePage()),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
