import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _imageFile;
  String? _currentBase64;
  bool _isLoading = false;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController.text = _user?.displayName ?? "";
    _fetchCurrentProfile();
  }

  Future<void> _fetchCurrentProfile() async {
    if (_user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['profileImage'] != null) {
          setState(() {
            _currentBase64 = data['profileImage'] as String?;
            if (data['displayName'] != null && _nameController.text.isEmpty) {
              _nameController.text = data['displayName'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? base64Image;

      // 1. Convert image to Base64 if selected
      if (_imageFile != null) {
        final bytes = await File(_imageFile!.path).readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // 2. Update Firestore User Document
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid);

      Map<String, dynamic> updateData = {
        'displayName': _nameController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (base64Image != null) {
        updateData['profileImage'] = base64Image;
      }

      await userDoc.set(updateData, SetOptions(merge: true));

      // 3. Update Firebase Auth Profile (for name consistency)
      await _user.updateDisplayName(_nameController.text.trim());
      await _user.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 240, // Height of header (180) + half of avatar (60)
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Lavender Header
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFFC7C7F1)),
                  ),
                  // Overlapping Profile Image Picker
                  Positioned(
                    bottom:
                        0, // Position at the very bottom of the 240px container
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _imageFile != null
                                    ? FileImage(File(_imageFile!.path))
                                    : (_currentBase64 != null
                                          ? MemoryImage(
                                              base64Decode(_currentBase64!),
                                            )
                                          : (_user?.photoURL != null
                                                ? NetworkImage(_user!.photoURL!)
                                                      as ImageProvider
                                                : null)),
                                child:
                                    (_imageFile == null &&
                                        _user?.photoURL == null &&
                                        _currentBase64 == null)
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ), // Reduced since SizedBox already provides spacing
            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Full Name",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFC7C7F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Note: Your email address cannot be changed here.",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom SAVE button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7C7F1),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.black87)
                : const Text(
                    "SAVE CHANGES",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
