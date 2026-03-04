import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manage_data/auth/google_login.dart';
import 'package:manage_data/controller/teame_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String? profileImageBase64;
          String displayName = currentUser.displayName ?? "User Name";

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            profileImageBase64 = data?['profileImage'];
            if (data?['displayName'] != null &&
                data!['displayName'].toString().isNotEmpty) {
              displayName = data['displayName'];
            }
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 70,
                pinned: true,
                backgroundColor: theme.appBarTheme.backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: theme.appBarTheme.backgroundColor,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.appBarTheme.foregroundColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.appBarTheme.backgroundColor,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profileImageBase64 != null
                              ? MemoryImage(base64Decode(profileImageBase64))
                              : currentUser.photoURL != null
                              ? NetworkImage(currentUser.photoURL!)
                              : null,
                          child:
                              (profileImageBase64 == null &&
                                  currentUser.photoURL == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentUser.email ?? "",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.6,
                          ),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildMenuTile(
                        context,
                        icon: Icons.shield_outlined,
                        title: "Privacy Policy",
                        onTap: () {},
                      ),
                      _buildMenuTile(
                        context,
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        onTap: () {},
                      ),
                      _buildMenuTile(
                        context,
                        icon: Icons.settings_outlined,
                        title: "Settings",
                        onTap: () {},
                      ),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeController.themeNotifier,
                        builder: (context, ThemeMode mode, _) {
                          final isDark = mode == ThemeMode.dark;
                          return _buildMenuTile(
                            context,
                            icon: isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            title: "Appearance",
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isDark ? "Dark" : "Light",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch.adaptive(
                                  value: isDark,
                                  onChanged: (val) {
                                    ThemeController.themeNotifier.value = val
                                        ? ThemeMode.dark
                                        : ThemeMode.light;
                                  },
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                            onTap: () {
                              ThemeController.themeNotifier.value = isDark
                                  ? ThemeMode.light
                                  : ThemeMode.dark;
                            },
                          );
                        },
                      ),

                      _buildMenuTile(
                        context,
                        icon: Icons.logout,
                        title: "Sign Out",
                        color: Colors.redAccent,
                        onTap: () async {
                          await GoogleSignIn().signOut();
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GoogleLoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: theme.cardTheme.color,
      ),
    );
  }
}
