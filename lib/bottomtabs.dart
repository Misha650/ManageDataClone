import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manage_data/view/home_page.dart';

import 'view/ProjectTable/show_project_title_page.dart';
import 'view/profile/profile_page.dart';
import 'view/admin/users_detail_page.dart';

class Bottomtabs extends StatefulWidget {
  @override
  State<Bottomtabs> createState() => _BottomtabsState();
}

class _BottomtabsState extends State<Bottomtabs> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _userRole = doc.data()?['role'];
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _userRole == 'owner';

    final List<Widget> pages = [
      HomeProjectPageCard(),
      ShowProjectPage(),
      ProfilePage(),
      if (isAdmin) const UsersDetailPage(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Projects',
          ),
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Summary',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group_rounded),
              label: 'Users',
            ),
        ],
      ),
    );
  }
}
