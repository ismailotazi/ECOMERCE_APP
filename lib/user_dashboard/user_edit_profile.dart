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

class UserEditProfile extends StatefulWidget {
  const UserEditProfile({super.key});

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  // Profile Image

  File? selectedImage;
  String? profileImageUrl;
  String? savedPhone;
  final ImagePicker picker = ImagePicker();
  bool isPickingImage = false;

  // User Information

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  // final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final zipController = TextEditingController();

  // Personal Information

  DateTime? selectedBirthDate;
  String? selectedGender;

  // Firebase / Form

  final user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;

  String? completePhoneNumber;

  // pick image
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
        "phone": completePhoneNumber ?? "",

        "photoUrl": photoUrl ?? profileImageUrl ?? "",
        "country": countryController.text.trim(),

        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
        "zipCode": zipController.text.trim(),

        "gender": selectedGender,
        "birthDate": selectedBirthDate != null
            ? Timestamp.fromDate(selectedBirthDate!)
            : null,

        "updatedAt": FieldValue.serverTimestamp(),
        "isProfileCompleted": true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.profileUpdatedSuccessfully)));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
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
    countryController.text = data["country"]?.toString() ?? "";
    cityController.text = data["city"]?.toString() ?? "";

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
      return null;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    // phoneController.dispose();
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
    final t = AppLocalizations.of(context)!;

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
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isDesktop = width >= 1100;
            final bool isTablet = width >= 700 && width < 1100;

            final double horizontalPadding = isDesktop
                ? 32
                : isTablet
                ? 24
                : 20;

            final double maxContentWidth = isDesktop
                ? 950
                : isTablet
                ? 850
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    children: [
                      const SizedBox(height: 10),

                      // PROFILE IMAGE
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
                                      ? Icon(
                                          Icons.person,
                                          size: 55,
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
                                      radius: 18,
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

                            const SizedBox(height: 10),

                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(text: t.profilePhoto),
                                  TextSpan(
                                    text: "(${t.optional})",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // PERSONAL INFORMATION
                      Card(
                        elevation: 0,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 24 : 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.personalInformation,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 20),

                              TextFormField(
                                controller: firstNameController,
                                validator: (value) {
                                  final name = value?.trim() ?? '';

                                  if (name.isEmpty) {
                                    return t.firstNameIsRequired;
                                  }

                                  if (name.length < 2) {
                                    return t.firstNameMinLength;
                                  }

                                  if (name.length > 30) {
                                    return t.firstNameMaxLength;
                                  }

                                  if (!RegExp(
                                    r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' -]+$",
                                  ).hasMatch(name)) {
                                    return t.validFirstName;
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
                                  final name = value?.trim() ?? '';

                                  if (name.isEmpty) {
                                    return t.lastNameIsRequired;
                                  }

                                  if (name.length < 2) {
                                    return t.lastNameMinLength;
                                  }

                                  if (name.length > 30) {
                                    return t.lastNameMaxLength;
                                  }

                                  if (!RegExp(
                                    r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' -]+$",
                                  ).hasMatch(name)) {
                                    return t.validLastName;
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
                                    ).colorScheme.outline,
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

                              const SizedBox(height: 25),

                              // SHIPPING ADDRESS
                              Card(
                                elevation: 0,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isDesktop ? 20 : 18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.shippingAddress,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: countryController,
                                        validator: (value) {
                                          final country = value?.trim() ?? '';

                                          if (country.isEmpty) {
                                            return t.countryIsRequired;
                                          }

                                          if (country.length < 2) {
                                            return t.countryNameTooShort;
                                          }

                                          if (country.length > 60) {
                                            return t.countryNameTooLong;
                                          }

                                          if (!RegExp(
                                            r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                                          ).hasMatch(country)) {
                                            return t.validCountryName;
                                          }

                                          return null;
                                        },
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.countryRequired,
                                          icon: Icons.location_city,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: cityController,
                                        validator: (value) {
                                          final city = value?.trim() ?? '';

                                          if (city.isEmpty) {
                                            return t.cityIsRequired;
                                          }

                                          if (city.length < 2) {
                                            return t.cityNameTooShort;
                                          }

                                          if (city.length > 60) {
                                            return t.cityNameTooLong;
                                          }

                                          if (!RegExp(
                                            r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
                                          ).hasMatch(city)) {
                                            return t.validCityName;
                                          }

                                          return null;
                                        },
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.cityRequired,
                                          icon: Icons.location_city,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: addressController,
                                        maxLines: 2,
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.streetAddressOptional,
                                          icon: Icons.home_outlined,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      TextFormField(
                                        controller: zipController,
                                        keyboardType: TextInputType.number,
                                        decoration: inputDecoration(
                                          context: context,
                                          label: t.zipCodeOptional,
                                          icon:
                                              Icons.local_post_office_outlined,
                                        ),
                                      ),

                                      const SizedBox(height: 25),

                                      // ADDITIONAL INFORMATION
                                      Card(
                                        elevation: 2,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            isDesktop ? 20 : 18,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.additionalInformation,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),

                                              const SizedBox(height: 20),

                                              DropdownButtonFormField<String>(
                                                initialValue: selectedGender,
                                                dropdownColor: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                decoration: inputDecoration(
                                                  context: context,
                                                  label: t.genderOptional,
                                                  icon: Icons.people_outline,
                                                ),
                                                items: [
                                                  DropdownMenuItem(
                                                    value: "Male",
                                                    child: Text(t.male),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: "Female",
                                                    child: Text(t.female),
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
                                                    builder: (context, child) {
                                                      return Theme(
                                                        data: Theme.of(context).copyWith(
                                                          colorScheme: Theme.of(context).colorScheme.copyWith(
                                                            primary:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                            onPrimary:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onPrimary,
                                                            surface:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .surface,
                                                            onSurface:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                        ),
                                                        child: child!,
                                                      );
                                                    },
                                                  );

                                                  if (date != null) {
                                                    setState(() {
                                                      selectedBirthDate = date;
                                                    });
                                                  }
                                                },
                                                child: InputDecorator(
                                                  decoration: inputDecoration(
                                                    context: context,
                                                    label:
                                                        t.dateOfBirthOptional,
                                                    icon: Icons.cake_outlined,
                                                  ),
                                                  child: Text(
                                                    selectedBirthDate == null
                                                        ? t.selectYourBirthDate
                                                        : "${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}",
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                    ),
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
                                          icon: Icon(
                                            Icons.save,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                          label: Text(
                                            t.saveChanges,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
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
                                              borderRadius:
                                                  BorderRadius.circular(14),
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
          },
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

// class UserEditProfile extends StatefulWidget {
//   const UserEditProfile({super.key});

//   @override
//   State<UserEditProfile> createState() => _UserEditProfileState();
// }

// class _UserEditProfileState extends State<UserEditProfile> {
//   // Profile Image

//   File? selectedImage;
//   String? profileImageUrl;
//   String? savedPhone;
//   final ImagePicker picker = ImagePicker();
//   bool isPickingImage = false;

//   // User Information

//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final usernameController = TextEditingController();
//   final emailController = TextEditingController();
//   // final phoneController = TextEditingController();
//   final countryController = TextEditingController();
//   final cityController = TextEditingController();
//   final addressController = TextEditingController();
//   final zipController = TextEditingController();

//   // Personal Information

//   DateTime? selectedBirthDate;
//   String? selectedGender;

//   // Firebase / Form

//   final user = FirebaseAuth.instance.currentUser;

//   final _formKey = GlobalKey<FormState>();

//   bool isLoading = true;

//   String? completePhoneNumber;
//   // pick image
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

//     String? photoUrl;

//     if (selectedImage != null) {
//       photoUrl = await uploadProfileImage();
//     }

//     try {
//       await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
//         "firstName": firstNameController.text.trim(),
//         "lastName": lastNameController.text.trim(),
//         "username": usernameController.text.trim(),
//         "email": user!.email,
//         "phone": completePhoneNumber ?? "",

//         "photoUrl": photoUrl ?? profileImageUrl ?? "",
//         "country": countryController.text.trim(),

//         "city": cityController.text.trim(),
//         "address": addressController.text.trim(),
//         "zipCode": zipController.text.trim(),

//         "gender": selectedGender,
//         "birthDate": selectedBirthDate != null
//             ? Timestamp.fromDate(selectedBirthDate!)
//             : null,

//         "updatedAt": FieldValue.serverTimestamp(),
//         "isProfileCompleted": true,
//       }, SetOptions(merge: true));

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.profileUpdatedSuccessfully)));

//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
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
//     countryController.text = data["country"]?.toString() ?? "";
//     cityController.text = data["city"]?.toString() ?? "";

//     addressController.text = data["address"] ?? "";
//     zipController.text = data["zipCode"] ?? "";

//     selectedGender = data["gender"];

//     if (data["birthDate"] != null) {
//       selectedBirthDate = (data["birthDate"] as Timestamp).toDate();
//     }

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
//       return null;
//     }
//   }

//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     usernameController.dispose();
//     emailController.dispose();
//     // phoneController.dispose();
//     countryController.dispose();
//     cityController.dispose();
//     addressController.dispose();
//     zipController.dispose();
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
//         centerTitle: true,
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
//                           backgroundImage: selectedImage != null
//                               ? FileImage(selectedImage!)
//                               : (profileImageUrl != null &&
//                                             profileImageUrl!.isNotEmpty
//                                         ? NetworkImage(profileImageUrl!)
//                                         : null)
//                                     as ImageProvider?,
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

//                     const SizedBox(height: 10),

//                     RichText(
//                       text: TextSpan(
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Theme.of(context).colorScheme.onSurface,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         children: [
//                           TextSpan(text: t.profilePhoto),
//                           TextSpan(
//                             text: "(${t.optional})",
//                             style: TextStyle(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onSurfaceVariant,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 30),
//               Card(
//                 elevation: 0,
//                 color: Theme.of(context).colorScheme.surfaceContainerHighest,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   side: BorderSide(
//                     color: Theme.of(context).colorScheme.outlineVariant,
//                     width: 1,
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         t.personalInformation,
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),

//                       const SizedBox(height: 20),

//                       TextFormField(
//                         controller: firstNameController,
//                         validator: (value) {
//                           final name = value?.trim() ?? '';

//                           if (name.isEmpty) {
//                             return t.firstNameIsRequired;
//                           }

//                           if (name.length < 2) {
//                             return t.firstNameMinLength;
//                           }

//                           if (name.length > 30) {
//                             return t.firstNameMaxLength;
//                           }

//                           if (!RegExp(
//                             r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' -]+$",
//                           ).hasMatch(name)) {
//                             return t.validFirstName;
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
//                           final name = value?.trim() ?? '';
//                           if (name.isEmpty) {
//                             return t.lastNameIsRequired;
//                           }

//                           if (name.length < 2) {
//                             return t.lastNameMinLength;
//                           }

//                           if (name.length > 30) {
//                             return t.lastNameMaxLength;
//                           }

//                           if (!RegExp(
//                             r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF' -]+$",
//                           ).hasMatch(name)) {
//                             return t.validLastName;
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
//                             color: Theme.of(context).colorScheme.outline,
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

//                       Card(
//                         elevation: 0,
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.surfaceContainerHighest,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                           side: BorderSide(
//                             color: Theme.of(context).colorScheme.outlineVariant,
//                             width: 1,
//                           ),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(18),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 t.shippingAddress,
//                                 style: Theme.of(context).textTheme.titleMedium
//                                     ?.copyWith(fontWeight: FontWeight.bold),
//                               ),

//                               const SizedBox(height: 15),

//                               TextFormField(
//                                 controller: countryController,
//                                 validator: (value) {
//                                   final country = value?.trim() ?? '';

//                                   if (country.isEmpty) {
//                                     return t.countryIsRequired;
//                                   }

//                                   if (country.length < 2) {
//                                     return t.countryNameTooShort;
//                                   }

//                                   if (country.length > 60) {
//                                     return t.countryNameTooLong;
//                                   }

//                                   if (!RegExp(
//                                     r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
//                                   ).hasMatch(country)) {
//                                     return t.validCountryName;
//                                   }
//                                   return null;
//                                 },
//                                 decoration: inputDecoration(
//                                   context: context,
//                                   label: t.countryRequired,
//                                   icon: Icons.location_city,
//                                 ),
//                               ),
//                               const SizedBox(height: 15),

//                               TextFormField(
//                                 controller: cityController,
//                                 validator: (value) {
//                                   final city = value?.trim() ?? '';

//                                   if (city.isEmpty) {
//                                     return t.cityIsRequired;
//                                   }

//                                   if (city.length < 2) {
//                                     return t.cityNameTooShort;
//                                   }

//                                   if (city.length > 60) {
//                                     return t.cityNameTooLong;
//                                   }

//                                   if (!RegExp(
//                                     r"^[a-zA-ZÀ-ÿ\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\s'-]+$",
//                                   ).hasMatch(city)) {
//                                     return t.validCityName;
//                                   }
//                                   return null;
//                                 },
//                                 decoration: inputDecoration(
//                                   context: context,
//                                   label: t.cityRequired,
//                                   icon: Icons.location_city,
//                                 ),
//                               ),
//                               const SizedBox(height: 15),

//                               TextFormField(
//                                 controller: addressController,
//                                 maxLines: 2,

//                                 decoration: inputDecoration(
//                                   context: context,
//                                   label: t.streetAddressOptional,
//                                   icon: Icons.home_outlined,
//                                 ),
//                               ),

//                               const SizedBox(height: 15),

//                               TextFormField(
//                                 controller: zipController,
//                                 keyboardType: TextInputType.number,

//                                 decoration: inputDecoration(
//                                   context: context,
//                                   label: t.zipCodeOptional,
//                                   icon: Icons.local_post_office_outlined,
//                                 ),
//                               ),
//                               const SizedBox(height: 25),

//                               Card(
//                                 elevation: 2,
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.surfaceContainer,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(18),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(18),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         t.additionalInformation,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleMedium
//                                             ?.copyWith(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                       ),

//                                       const SizedBox(height: 20),

//                                       DropdownButtonFormField<String>(
//                                         initialValue: selectedGender,

//                                         dropdownColor: Theme.of(
//                                           context,
//                                         ).colorScheme.surface,

//                                         decoration: inputDecoration(
//                                           context: context,
//                                           label: t.genderOptional,
//                                           icon: Icons.people_outline,
//                                         ),

//                                         items: [
//                                           DropdownMenuItem(
//                                             value: "Male",
//                                             child: Text(t.male),
//                                           ),
//                                           DropdownMenuItem(
//                                             value: "Female",
//                                             child: Text(t.female),
//                                           ),
//                                         ],
//                                         onChanged: (value) {
//                                           setState(() {
//                                             selectedGender = value;
//                                           });
//                                         },
//                                       ),
//                                       const SizedBox(height: 15),

//                                       InkWell(
//                                         onTap: () async {
//                                           final date = await showDatePicker(
//                                             context: context,
//                                             initialDate: DateTime(2000),
//                                             firstDate: DateTime(1950),
//                                             lastDate: DateTime.now(),

//                                             builder: (context, child) {
//                                               return Theme(
//                                                 data: Theme.of(context).copyWith(
//                                                   colorScheme: Theme.of(context)
//                                                       .colorScheme
//                                                       .copyWith(
//                                                         primary: Theme.of(
//                                                           context,
//                                                         ).colorScheme.primary,
//                                                         onPrimary: Theme.of(
//                                                           context,
//                                                         ).colorScheme.onPrimary,
//                                                         surface: Theme.of(
//                                                           context,
//                                                         ).colorScheme.surface,
//                                                         onSurface: Theme.of(
//                                                           context,
//                                                         ).colorScheme.onSurface,
//                                                       ),
//                                                 ),
//                                                 child: child!,
//                                               );
//                                             },
//                                           );

//                                           if (date != null) {
//                                             setState(() {
//                                               selectedBirthDate = date;
//                                             });
//                                           }
//                                         },
//                                         child: InputDecorator(
//                                           decoration: inputDecoration(
//                                             context: context,
//                                             label: t.dateOfBirthOptional,
//                                             icon: Icons.cake_outlined,
//                                           ),

//                                           child: Text(
//                                             selectedBirthDate == null
//                                                 ? t.selectYourBirthDate
//                                                 : "${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}",
//                                             style: TextStyle(
//                                               color: Theme.of(
//                                                 context,
//                                               ).colorScheme.onSurface,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 35),

//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 55,
//                                 child: ElevatedButton.icon(
//                                   onPressed: saveProfile,
//                                   icon: Icon(
//                                     Icons.save,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                   ),
//                                   label: Text(
//                                     t.saveChanges,
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Theme.of(
//                                       context,
//                                     ).colorScheme.primary,
//                                     foregroundColor: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(14),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               const SizedBox(height: 40),
//                             ],
//                           ),
//                         ),
//                       ),
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
