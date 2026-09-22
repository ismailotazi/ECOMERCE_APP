import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditAdminProfile extends StatefulWidget {
  const EditAdminProfile({super.key});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  File? selectedImage;
  String? profileImageUrl;
  final ImagePicker picker = ImagePicker();
  String? completePhoneNumber;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  // pick image
  bool isPickingImage = false;
  String? savedPhone;

  Future<void> pickImage() async {
    if (isPickingImage) return;

    setState(() {
      isPickingImage = true;
    });

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isPickingImage = false;
        });
      }
    }
  }

  // save profile
  Future<void> saveProfile() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    completePhoneNumber ??= savedPhone;

    if (completePhoneNumber == null || completePhoneNumber!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.pleaseEnterPhoneNumber)));
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
        "phone": completePhoneNumber ?? "",
        "photoUrl": photoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
        "isProfileCompleted": true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            t.profileUpdatedSuccessfully,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            e.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
        ),
      );
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
    savedPhone = data["phone"]?.toString().trim();

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

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 28.0 : 16.0;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.editProfile),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                children: [
                  SizedBox(height: isDesktop ? 10 : 4),

                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: isDesktop ? 60 : 55,

                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,

                              backgroundImage: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : (profileImageUrl != null &&
                                        profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(profileImageUrl!)
                                  : null,

                              child:
                                  selectedImage == null &&
                                      (profileImageUrl == null ||
                                          profileImageUrl!.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: isDesktop ? 60 : 55,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: isPickingImage ? null : pickImage,
                                child: CircleAvatar(
                                  radius: isDesktop ? 19 : 18,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: isPickingImage
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          size: 18,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isDesktop ? 14 : 12),

                  Center(
                    child: Text(
                      t.changeProfilePhoto,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: isDesktop ? 32 : 30),

                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: Theme.of(context).brightness == Brightness.dark
                        ? 0
                        : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 26 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.personalInformation,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: isDesktop ? 22 : 20),

                          TextFormField(
                            controller: firstNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return t.firstNameRequired;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              context: context,
                              label: t.firstName,
                              icon: Icons.person_outline,
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: lastNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return t.lastNameIsRequired;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              context: context,
                              label: t.lastName,
                              icon: Icons.person_outline,
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            controller: usernameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return t.usernameIsRequired;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              context: context,
                              label: t.username,
                              icon: Icons.alternate_email,
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: emailController,
                            enabled: false,
                            decoration: inputDecoration(
                              context: context,
                              label: t.email,
                              icon: Icons.email_outlined,
                              suffixIcon: Icon(
                                Icons.lock_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          IntlPhoneField(
                            key: ValueKey(savedPhone),
                            initialValue: savedPhone,
                            keyboardType: TextInputType.phone,

                            decoration: inputDecoration(
                              context: context,
                              label: t.phoneNumber,
                              icon: Icons.phone,
                            ),

                            onChanged: (phone) {
                              completePhoneNumber = phone.completeNumber;
                            },
                          ),

                          SizedBox(height: isDesktop ? 28 : 25),

                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 58 : 55,
                            child: ElevatedButton.icon(
                              onPressed: saveProfile,

                              icon: Icon(
                                Icons.save,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),

                              label: Text(
                                t.saveChanges,
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,

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

                  SizedBox(height: isDesktop ? 20 : 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/theme/input_decoration.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// class EditAdminProfile extends StatefulWidget {
//   const EditAdminProfile({super.key});

//   @override
//   State<EditAdminProfile> createState() => _EditAdminProfileState();
// }

// class _EditAdminProfileState extends State<EditAdminProfile> {
//   File? selectedImage;
//   String? profileImageUrl;
//   final ImagePicker picker = ImagePicker();
//   String? completePhoneNumber;
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final usernameController = TextEditingController();
//   final emailController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   final user = FirebaseAuth.instance.currentUser;
//   bool isLoading = true;
//   // pick image
//   bool isPickingImage = false;
//   String? savedPhone;

//   Future<void> pickImage() async {
//     if (isPickingImage) return;

//     setState(() {
//       isPickingImage = true;
//     });

//     try {
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//       );

//       if (image == null) return;

//       if (!mounted) return;

//       setState(() {
//         selectedImage = File(image.path);
//       });
//     } catch (e) {
//       debugPrint(e.toString());
//     } finally {
//       if (mounted) {
//         setState(() {
//           isPickingImage = false;
//         });
//       }
//     }
//   }

//   // save profile
//   Future<void> saveProfile() async {
//     final t = AppLocalizations.of(context)!;
//     if (!_formKey.currentState!.validate()) return;

//     completePhoneNumber ??= savedPhone;

//     if (completePhoneNumber == null || completePhoneNumber!.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.pleaseEnterPhoneNumber)));
//       return;
//     }

//     if (user == null) return;

//     try {
//       String? photoUrl = profileImageUrl;

//       // Upload new image if user selected one
//       if (selectedImage != null) {
//         photoUrl = await uploadProfileImage();
//       }

//       await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
//         "firstName": firstNameController.text.trim(),
//         "lastName": lastNameController.text.trim(),
//         "username": usernameController.text.trim(),
//         "email": emailController.text.trim(),
//         "phone": completePhoneNumber ?? "",
//         "photoUrl": photoUrl,
//         "updatedAt": FieldValue.serverTimestamp(),
//         "isProfileCompleted": true,
//       }, SetOptions(merge: true));

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           content: Text(
//             t.profileUpdatedSuccessfully,
//             style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
//           ),
//         ),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Theme.of(context).colorScheme.error,
//           content: Text(
//             e.toString(),
//             style: TextStyle(color: Theme.of(context).colorScheme.onError),
//           ),
//         ),
//       );
//     }
//   }

//   // load profile
//   Future<void> loadUserData() async {
//     if (user == null) return;

//     final doc = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(user!.uid)
//         .get();

//     if (!doc.exists) {
//       setState(() => isLoading = false);
//       return;
//     }

//     final data = doc.data()!;
//     profileImageUrl = data["photoUrl"] ?? "";
//     firstNameController.text = data["firstName"] ?? "";
//     lastNameController.text = data["lastName"] ?? "";
//     usernameController.text = data["username"] ?? "";
//     emailController.text = data["email"] ?? "";
//     savedPhone = data["phone"]?.toString().trim();

//     setState(() {
//       isLoading = false;
//     });
//   }

//   //upload profile image
//   Future<String?> uploadProfileImage() async {
//     if (selectedImage == null || user == null) return null;

//     try {
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child("profile_images")
//           .child("${user!.uid}.jpg");

//       await ref.putFile(selectedImage!);

//       final downloadUrl = await ref.getDownloadURL();

//       return downloadUrl;
//     } catch (e) {
//       debugPrint(e.toString());
//       return null;
//     }
//   }

//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     usernameController.dispose();
//     emailController.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadUserData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     if (isLoading) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(
//             color: Theme.of(context).colorScheme.primary,
//           ),
//         ),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.editProfile),
//         leading: const CustomBackButton(),
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               const SizedBox(height: 10),

//               Center(
//                 child: Column(
//                   children: [
//                     Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 55,

//                           backgroundColor: Theme.of(
//                             context,
//                           ).colorScheme.surfaceContainerHighest,

//                           backgroundImage: selectedImage != null
//                               ? FileImage(selectedImage!)
//                               : (profileImageUrl != null &&
//                                     profileImageUrl!.isNotEmpty)
//                               ? NetworkImage(profileImageUrl!)
//                               : null,

//                           child:
//                               selectedImage == null &&
//                                   (profileImageUrl == null ||
//                                       profileImageUrl!.isEmpty)
//                               ? Icon(
//                                   Icons.person,
//                                   size: 55,
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onSurfaceVariant,
//                                 )
//                               : null,
//                         ),
//                         Positioned(
//                           right: 0,
//                           bottom: 0,
//                           child: GestureDetector(
//                             onTap: isPickingImage ? null : pickImage,
//                             child: CircleAvatar(
//                               radius: 18,
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.primary,
//                               child: isPickingImage
//                                   ? SizedBox(
//                                       width: 18,
//                                       height: 18,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.onPrimary,
//                                       ),
//                                     )
//                                   : Icon(
//                                       Icons.camera_alt,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimary,
//                                       size: 18,
//                                     ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 12),

//               Center(
//                 child: Text(
//                   t.changeProfilePhoto,
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),
//               Card(
//                 color: Theme.of(context).colorScheme.surface,
//                 elevation: Theme.of(context).brightness == Brightness.dark
//                     ? 0
//                     : 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         t.personalInformation,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       TextFormField(
//                         controller: firstNameController,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return t.firstNameRequired;
//                           }
//                           return null;
//                         },
//                         decoration: inputDecoration(
//                           context: context,
//                           label: t.firstName,
//                           icon: Icons.person_outline,
//                         ),
//                       ),

//                       const SizedBox(height: 15),

//                       TextFormField(
//                         controller: lastNameController,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return t.lastNameIsRequired;
//                           }
//                           return null;
//                         },
//                         decoration: inputDecoration(
//                           context: context,
//                           label: t.lastName,
//                           icon: Icons.person_outline,
//                         ),
//                       ),

//                       const SizedBox(height: 15),

//                       TextFormField(
//                         controller: usernameController,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return t.usernameIsRequired;
//                           }
//                           return null;
//                         },
//                         decoration: inputDecoration(
//                           context: context,
//                           label: t.username,
//                           icon: Icons.alternate_email,
//                         ),
//                       ),

//                       const SizedBox(height: 15),

//                       TextField(
//                         controller: emailController,
//                         enabled: false,
//                         decoration: inputDecoration(
//                           context: context,
//                           label: t.email,
//                           icon: Icons.email_outlined,
//                           suffixIcon: Icon(
//                             Icons.lock_outline,
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.onSurfaceVariant,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 15),

//                       IntlPhoneField(
//                         key: ValueKey(savedPhone),
//                         initialValue: savedPhone,
//                         keyboardType: TextInputType.phone,

//                         decoration: inputDecoration(
//                           context: context,
//                           label: t.phoneNumber,
//                           icon: Icons.phone,
//                         ),

//                         onChanged: (phone) {
//                           completePhoneNumber = phone.completeNumber;
//                         },
//                       ),

//                       const SizedBox(height: 25),

//                       SizedBox(
//                         width: double.infinity,
//                         height: 55,
//                         child: ElevatedButton.icon(
//                           onPressed: saveProfile,

//                           icon: Icon(
//                             Icons.save,
//                             color: Theme.of(context).colorScheme.onPrimary,
//                           ),

//                           label: Text(
//                             t.saveChanges,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).colorScheme.onPrimary,
//                             ),
//                           ),

//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(
//                               context,
//                             ).colorScheme.primary,
//                             foregroundColor: Theme.of(
//                               context,
//                             ).colorScheme.onPrimary,

//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
