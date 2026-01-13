import 'package:flutter/material.dart';

import 'ShowProjectGridListPage/show_project_title_page.dart';

class ShowProjectPage extends StatelessWidget {
  const ShowProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Summary"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ShowProjectTitlePage()),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text("Summary Content Here")),
    );
  }
}
