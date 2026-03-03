import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/google_login.dart';
import '../../controller/teame_controller.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data ?? currentUser;

        if (user == null)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, firestoreSnapshot) {
            String? base64Image;
            String? displayName = user.displayName;

            if (firestoreSnapshot.hasData && firestoreSnapshot.data!.exists) {
              final data =
                  firestoreSnapshot.data!.data() as Map<String, dynamic>;
              base64Image = data['profileImage'] as String?;
              displayName = data['displayName'] as String? ?? displayName;
            }

            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Lavender Header
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC7C7F1), // Lavender color
                          ),
                        ),
                        // Edit icon
                        Positioned(
                          top: 40,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfilePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Overlapping Profile Image
                        Positioned(
                          bottom: -60,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: base64Image != null
                                    ? MemoryImage(base64Decode(base64Image))
                                    : (user.photoURL != null
                                          ? NetworkImage(user.photoURL!)
                                                as ImageProvider
                                          : null),
                                child:
                                    (base64Image == null &&
                                        user.photoURL == null)
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    // User Name
                    Text(
                      displayName ?? "user name",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact Details
                    _buildDetailRow("", user.email ?? "[EMAIL_ADDRESS]"),

                    const SizedBox(height: 30),
                    const Divider(height: 1),
                    // Menu List
                    _buildMenuTile(
                      icon: Icons.nightlight_round_outlined,
                      title: "Dark mode",
                      trailing: ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeController.themeNotifier,
                        builder: (_, mode, __) {
                          return Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: (bool value) {
                              ThemeController.themeNotifier.value = value
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
                          );
                        },
                      ),
                    ),

                    _buildMenuTile(
                      icon: Icons.feedback_outlined,
                      title: "Feedback",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Feedback feature coming soon!"),
                          ),
                        );
                      },
                    ),
                    _buildMenuTile(
                      icon: Icons.logout,
                      title: "Log out",
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoogleLoginPage(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 4,
          ),
          leading: Icon(icon, size: 28, color: Colors.black87),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 24),
      ],
    );
  }
}
