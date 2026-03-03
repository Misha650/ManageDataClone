import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:manage_data/view/add_detal/ProjectPageCard.dart';
import '../controller/teame_controller.dart';

class HomeProjectPageCard extends StatelessWidget {
  const HomeProjectPageCard({super.key});

  Future<void> _addProject(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final titleController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("New Project"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: "Project Title",
                      hintText: "Enter project name",
                    ),
                  ),
                  TextField(
                    controller: descController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          setState(() => isSaving = true);

                          try {
                            // Check for duplicate name
                            final query = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('projects')
                                .where('title', isEqualTo: title)
                                .get();

                            if (query.docs.isNotEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "A project with this name already exists!",
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              setState(() => isSaving = false);
                              return;
                            }

                            // Add project
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('projects')
                                .add({
                                  'title': title,
                                  'description': descController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            setState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProject(BuildContext context, String projectId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?"),
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
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeNotifier,
            builder: (_, mode, __) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.light
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                ),
                onPressed: () {
                  ThemeController.themeNotifier.value = mode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProject(context),
        label: const Text("New Project"),
        icon: const Icon(Icons.add, size: 24),
      ),
      body: Stack(
        children: [
          // Background soft decoration
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('projects')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_off_rounded,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No projects found",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.7,
                          ),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the + button to create one",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.5,
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final projects = snapshot.data!.docs;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final p = projects[index];
                  final title = p['title'] ?? 'Untitled';
                  final desc = p['description'] ?? '';

                  // List of icons and colors for variety
                  final List<IconData> variedIcons = [
                    Icons.inventory_2_rounded,
                    Icons.folder_rounded,
                    Icons.assignment_rounded,
                    Icons.business_center_rounded,
                    Icons.analytics_rounded,
                    Icons.account_tree_rounded,
                    Icons.layers_rounded,
                  ];

                  final List<Color> variedColors = isDark
                      ? [
                          Colors.purpleAccent.shade100,
                          Colors.blueAccent.shade100,
                          Colors.indigoAccent.shade100,
                          Colors.deepPurpleAccent.shade100,
                          theme.colorScheme.primary,
                        ]
                      : [
                          const Color(0xFF8E8ECA),
                          const Color(0xFF7E7EBA),
                          const Color(0xFF9E9EDA),
                          const Color(0xFFA1A1E1),
                          theme.colorScheme.primary,
                        ];

                  // Use project ID to pick a stable icon and color
                  final int pickIndex = p.id.hashCode.abs();
                  final IconData icon =
                      variedIcons[pickIndex % variedIcons.length];
                  final Color iconColor =
                      variedColors[pickIndex % variedColors.length];

                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubProjectPageCard(projectId: p.id),
                          ),
                        );
                      },
                      onLongPress: () => _deleteProject(context, p.id),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(icon, size: 28, color: iconColor),
                            ),
                            const Spacer(),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc.isEmpty ? "No description" : desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
