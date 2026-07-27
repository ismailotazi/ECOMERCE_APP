import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserEditProfile extends StatefulWidget {
  const UserEditProfile({super.key});

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  File? selectedImage;
  String? profileImageUrl;
  final ImagePicker picker = ImagePicker();
  DateTime? selectedBirthDate;
  String? selectedGender;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final zipController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
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
        const SnackBar(content: Text("Please select a profile photo")),
      );
      return;
    }
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your gender")),
      );
      return;
    }

    if (selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth")),
      );
      return;
    }

    if (user == null) return;

    String? photoUrl;

    if (selectedImage != null) {
      photoUrl = await uploadProfileImage();
    }

    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "username": usernameController.text.trim(),
        "email": user!.email,
        "phone": phoneController.text.trim(),

        if (photoUrl != null) "photoUrl": photoUrl,

        "country": countryController.text.trim(),
        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
        "zipCode": zipController.text.trim(),

        "gender": selectedGender,
        "birthDate": Timestamp.fromDate(selectedBirthDate!),

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

    countryController.text = data["country"] ?? "";
    cityController.text = data["city"] ?? "";
    addressController.text = data["address"] ?? "";
    zipController.text = data["zipCode"] ?? "";

    selectedGender = data["gender"];

    if (data["birthDate"] != null) {
      selectedBirthDate = (data["birthDate"] as Timestamp).toDate();
    }

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
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();
    zipController.dispose();
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
                              backgroundColor: Theme.of(context).primaryColor,
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

                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(text: "Profile Photo "),
                          TextSpan(
                            text: "*",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                    if (selectedImage == null &&
                        (profileImageUrl == null || profileImageUrl!.isEmpty))
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "Profile photo is required",
                          style: TextStyle(color: Colors.red, fontSize: 12),
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
                                "Shipping Address",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              TextFormField(
                                controller: countryController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Country is required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Country",
                                  prefixIcon: const Icon(Icons.public),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              TextFormField(
                                controller: cityController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "City is required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "City",
                                  prefixIcon: const Icon(Icons.location_city),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: addressController,
                                maxLines: 2,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Address is required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Street Address",
                                  prefixIcon: const Icon(Icons.home_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              TextFormField(
                                controller: zipController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "ZIP Code is required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "ZIP Code",
                                  prefixIcon: const Icon(
                                    Icons.local_post_office_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Additional Information",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      DropdownButtonFormField<String>(
                                        initialValue: selectedGender,
                                        decoration: InputDecoration(
                                          labelText: "Gender",
                                          prefixIcon: const Icon(
                                            Icons.people_outline,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null) {
                                            return "Please select your gender";
                                          }
                                          return null;
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                            value: "Male",
                                            child: Text("Male"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Female",
                                            child: Text("Female"),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedGender = value;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: 15),

                                      InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime(2000),
                                            firstDate: DateTime(1950),
                                            lastDate: DateTime.now(),
                                          );

                                          if (date != null) {
                                            setState(() {
                                              selectedBirthDate = date;
                                            });
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: "Date of Birth",
                                            prefixIcon: const Icon(
                                              Icons.cake_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            selectedBirthDate == null
                                                ? "Select your birth date"
                                                : "${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 35),

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

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
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
