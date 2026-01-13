import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/google_login.dart';
import '../../controller/teame_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          // ✅ Dark Mode Switch
          ValueListenableBuilder<ThemeMode>(
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
          //         IconButton(onPressed: () {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => ShowProjectPage()));
          // }  , icon: Icon(Icons.add)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GoogleLoginPage()),
              );
            },
          ),
        ],
      ),

      body: Center(child: Text("Home Page")),
    );
  }
}
