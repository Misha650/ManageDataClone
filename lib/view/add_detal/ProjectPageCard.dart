import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manage_data/view/add_detal/AddDetailInCardPage/AddDetailInCardPage.dart';
import 'package:manage_data/view/add_detal/AddOwnerDetailPage.dart';

class SubProjectPageCard extends StatelessWidget {
  final String projectId; // ✅ Store projectId properly

  const SubProjectPageCard({super.key, required this.projectId});

  Future<void> _addTask(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Subproject"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Subproject Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('projects')
                    .doc(projectId)
                    .collection('subprojects')
                    .add({
                      'title': titleController.text,
                      'description': descController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubProject(
    BuildContext context,
    String subProjectId,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Sub-project"),
        content: const Text(
          "Are you sure you want to delete this sub-project?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectId)
          .collection('subprojects')
          .doc(subProjectId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subproject'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [Colors.deepPurple.shade900, Colors.purple.shade900]
                  : [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(context),
        label: const Text("New Task"),
        icon: const Icon(Icons.add_task),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('projects')
            .doc(projectId)
            .collection('subprojects')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.hasData ? snapshot.data!.docs : [];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            // +1 for the Owner Card
            itemCount: projects.length + 1,
            itemBuilder: (context, index) {
              // 1. Owner Card at Index 0
              if (index == 0) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddOwnerDetailPage(projectId: projectId),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.8),
                            Theme.of(context).primaryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: const Text(
                          "Add Owner Detail",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(Icons.star, color: Colors.white70),
                      ),
                    ),
                  ),
                );
              }

              // 2. Subproject Cards (Offset by 1)
              final p = projects[index - 1];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    Icons.assignment_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    p['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle:
                      (p['description'] != null &&
                          p['description'].toString().isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            p['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : null,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddDetailInCardPage(
                          projectId: projectId,
                          subprojectId: p.id,
                        ),
                      ),
                    );
                  },
                  onLongPress: () => _deleteSubProject(context, p.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
