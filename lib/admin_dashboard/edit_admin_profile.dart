import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditAdminProfile extends StatefulWidget {
  const EditAdminProfile({super.key});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  File? selectedImage;
  String? profileImageUrl;
  final ImagePicker picker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  // pick image
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // save profile
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null &&
        (profileImageUrl == null || profileImageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile picture")),
      );
      return;
    }

    if (user == null) return;

    try {
      String? photoUrl = profileImageUrl;

      // Upload new image if user selected one
      if (selectedImage != null) {
        photoUrl = await uploadProfileImage();
      }

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "photoUrl": photoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
        "isProfileCompleted": true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // load profile
  Future<void> loadUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (!doc.exists) {
      setState(() => isLoading = false);
      return;
    }

    final data = doc.data()!;
    profileImageUrl = data["photoUrl"] ?? "";
    firstNameController.text = data["firstName"] ?? "";
    lastNameController.text = data["lastName"] ?? "";
    usernameController.text = data["username"] ?? "";
    emailController.text = data["email"] ?? "";
    phoneController.text = data["phone"] ?? "";

    if (data["birthDate"] != null) {}

    setState(() {
      isLoading = false;
    });
  }

  //upload profile image
  Future<String?> uploadProfileImage() async {
    if (selectedImage == null || user == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user!.uid}.jpg");

      await ref.putFile(selectedImage!);

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : (profileImageUrl != null &&
                                            profileImageUrl!.isNotEmpty
                                        ? NetworkImage(profileImageUrl!)
                                        : null)
                                    as ImageProvider?,

                          child:
                              selectedImage == null &&
                                  (profileImageUrl == null ||
                                      profileImageUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 55)
                              : null,
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.deepOrange,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Profile Photo *",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "Change Profile Photo",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: firstNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "First name is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "First Name",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: lastNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Last name is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Username is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.alternate_email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: emailController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Phone number is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
