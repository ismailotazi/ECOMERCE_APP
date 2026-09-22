import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> initialData;

  const EditUserPage({
    super.key,
    required this.userId,
    required this.initialData,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;
  late final TextEditingController phoneController;
  late final TextEditingController countryController;
  late final TextEditingController cityController;
  late final TextEditingController addressController;
  late final TextEditingController zipCodeController;

  String? selectedGender;
  DateTime? selectedBirthDate;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(
      text: widget.initialData["firstName"]?.toString() ?? "",
    );

    lastNameController = TextEditingController(
      text: widget.initialData["lastName"]?.toString() ?? "",
    );

    usernameController = TextEditingController(
      text: widget.initialData["username"]?.toString() ?? "",
    );

    phoneController = TextEditingController(
      text: widget.initialData["phone"]?.toString() ?? "",
    );

    countryController = TextEditingController(
      text: widget.initialData["country"]?.toString() ?? "",
    );

    cityController = TextEditingController(
      text: widget.initialData["city"]?.toString() ?? "",
    );

    addressController = TextEditingController(
      text: widget.initialData["address"]?.toString() ?? "",
    );

    zipCodeController = TextEditingController(
      text: widget.initialData["zipCode"]?.toString() ?? "",
    );

    selectedGender = widget.initialData["gender"]?.toString();

    final birthDate = widget.initialData["birthDate"];

    if (birthDate is Timestamp) {
      selectedBirthDate = birthDate.toDate();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();
    zipCodeController.dispose();

    super.dispose();
  }

  InputDecoration inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  Future<void> selectBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        selectedBirthDate = picked;
      });
    }
  }

  String formatBirthDate() {
    final t = AppLocalizations.of(context)!;
    if (selectedBirthDate == null) {
      return t.selectDateOfBirth;
    }

    final date = selectedBirthDate!;

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Future<void> saveUser() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final Map<String, dynamic> updates = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "username": usernameController.text.trim(),
        "phone": phoneController.text.trim(),
        "country": countryController.text.trim(),
        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
        "zipCode": zipCodeController.text.trim(),
      };

      if (selectedGender != null && selectedGender!.trim().isNotEmpty) {
        updates["gender"] = selectedGender;
      }

      if (selectedBirthDate != null) {
        updates["birthDate"] = Timestamp.fromDate(selectedBirthDate!);
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update(updates);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.userUpdatedSuccessfully)));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    } finally {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(t.editUser),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 20,
                  vertical: isDesktop ? 28 : 20,
                ),
                children: [
                  Text(
                    t.personalInformation,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: isDesktop ? 20 : 16),

                  TextFormField(
                    controller: firstNameController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      context,
                      label: t.firstName,
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.firstNameIsRequired;
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: lastNameController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      context,
                      label: t.lastName,
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.lastNameIsRequired;
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      context,
                      label: t.username,
                      icon: Icons.alternate_email_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      context,
                      label: t.phone,
                      icon: Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: selectedGender,
                    decoration: inputDecoration(
                      context,
                      label: t.gender,
                      icon: Icons.people_outline_rounded,
                    ),
                    items: [
                      DropdownMenuItem(value: "Male", child: Text(t.male)),
                      DropdownMenuItem(value: "Female", child: Text(t.female)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: selectBirthDate,
                    child: InputDecorator(
                      decoration: inputDecoration(
                        context,
                        label: t.dateOfBirth,
                        icon: Icons.cake_outlined,
                      ),
                      child: Text(
                        formatBirthDate(),
                        style: selectedBirthDate == null
                            ? theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )
                            : theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),

                  SizedBox(height: isDesktop ? 36 : 30),

                  Text(
                    t.shippingAddress,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: isDesktop ? 20 : 16),

                  TextFormField(
                    controller: countryController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      context,
                      label: t.country,
                      icon: Icons.public_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: cityController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecoration(
                      context,
                      label: t.city,
                      icon: Icons.location_city_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: addressController,
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
                    decoration: inputDecoration(
                      context,
                      label: t.streetAddress,
                      icon: Icons.home_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: zipCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: inputDecoration(
                      context,
                      label: t.zipCode,
                      icon: Icons.markunread_mailbox_outlined,
                    ),
                  ),

                  SizedBox(height: isDesktop ? 36 : 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : saveUser,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(isSaving ? t.saving : t.saveChanges),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class EditUserPage extends StatefulWidget {
//   final String userId;
//   final Map<String, dynamic> initialData;

//   const EditUserPage({
//     super.key,
//     required this.userId,
//     required this.initialData,
//   });

//   @override
//   State<EditUserPage> createState() => _EditUserPageState();
// }

// class _EditUserPageState extends State<EditUserPage> {
//   final _formKey = GlobalKey<FormState>();

//   late final TextEditingController firstNameController;
//   late final TextEditingController lastNameController;
//   late final TextEditingController usernameController;
//   late final TextEditingController phoneController;
//   late final TextEditingController countryController;
//   late final TextEditingController cityController;
//   late final TextEditingController addressController;
//   late final TextEditingController zipCodeController;

//   String? selectedGender;
//   DateTime? selectedBirthDate;

//   bool isSaving = false;

//   @override
//   void initState() {
//     super.initState();

//     firstNameController = TextEditingController(
//       text: widget.initialData["firstName"]?.toString() ?? "",
//     );

//     lastNameController = TextEditingController(
//       text: widget.initialData["lastName"]?.toString() ?? "",
//     );

//     usernameController = TextEditingController(
//       text: widget.initialData["username"]?.toString() ?? "",
//     );

//     phoneController = TextEditingController(
//       text: widget.initialData["phone"]?.toString() ?? "",
//     );

//     countryController = TextEditingController(
//       text: widget.initialData["country"]?.toString() ?? "",
//     );

//     cityController = TextEditingController(
//       text: widget.initialData["city"]?.toString() ?? "",
//     );

//     addressController = TextEditingController(
//       text: widget.initialData["address"]?.toString() ?? "",
//     );

//     zipCodeController = TextEditingController(
//       text: widget.initialData["zipCode"]?.toString() ?? "",
//     );

//     selectedGender = widget.initialData["gender"]?.toString();

//     final birthDate = widget.initialData["birthDate"];

//     if (birthDate is Timestamp) {
//       selectedBirthDate = birthDate.toDate();
//     }
//   }

//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     usernameController.dispose();
//     phoneController.dispose();
//     countryController.dispose();
//     cityController.dispose();
//     addressController.dispose();
//     zipCodeController.dispose();

//     super.dispose();
//   }

//   InputDecoration inputDecoration(
//     BuildContext context, {
//     required String label,
//     required IconData icon,
//   }) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon),
//       filled: true,
//       fillColor: colorScheme.surfaceContainerHighest,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide(color: colorScheme.outlineVariant),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
//       ),
//     );
//   }

//   Future<void> selectBirthDate() async {
//     final now = DateTime.now();

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedBirthDate ?? DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: now,
//     );

//     if (!mounted) return;

//     if (picked != null) {
//       setState(() {
//         selectedBirthDate = picked;
//       });
//     }
//   }

//   String formatBirthDate() {
//     final t = AppLocalizations.of(context)!;
//     if (selectedBirthDate == null) {
//       return t.selectDateOfBirth;
//     }

//     final date = selectedBirthDate!;

//     return "${date.day.toString().padLeft(2, '0')}/"
//         "${date.month.toString().padLeft(2, '0')}/"
//         "${date.year}";
//   }

//   Future<void> saveUser() async {
//     final t = AppLocalizations.of(context)!;
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       isSaving = true;
//     });

//     try {
//       final Map<String, dynamic> updates = {
//         "firstName": firstNameController.text.trim(),
//         "lastName": lastNameController.text.trim(),
//         "username": usernameController.text.trim(),
//         "phone": phoneController.text.trim(),
//         "country": countryController.text.trim(),
//         "city": cityController.text.trim(),
//         "address": addressController.text.trim(),
//         "zipCode": zipCodeController.text.trim(),
//       };

//       if (selectedGender != null && selectedGender!.trim().isNotEmpty) {
//         updates["gender"] = selectedGender;
//       }

//       if (selectedBirthDate != null) {
//         updates["birthDate"] = Timestamp.fromDate(selectedBirthDate!);
//       }

//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(widget.userId)
//           .update(updates);

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.userUpdatedSuccessfully)));

//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
//     } finally {
//       if (!mounted) return;

//       setState(() {
//         isSaving = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         leading: const CustomBackButton(),
//         title: Text(t.editUser),
//       ),

//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               Text(
//                 t.personalInformation,
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               TextFormField(
//                 controller: firstNameController,
//                 textInputAction: TextInputAction.next,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.firstName,
//                   icon: Icons.person_outline_rounded,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return t.firstNameIsRequired;
//                   }

//                   return null;
//                 },
//               ),

//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: lastNameController,
//                 textInputAction: TextInputAction.next,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.lastName,
//                   icon: Icons.person_outline_rounded,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return t.lastNameIsRequired;
//                   }

//                   return null;
//                 },
//               ),

//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: usernameController,
//                 textInputAction: TextInputAction.next,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.username,
//                   icon: Icons.alternate_email_rounded,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: phoneController,
//                 keyboardType: TextInputType.phone,
//                 textInputAction: TextInputAction.next,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.phone,
//                   icon: Icons.phone_outlined,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               DropdownButtonFormField<String>(
//                 initialValue: selectedGender,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.gender,
//                   icon: Icons.people_outline_rounded,
//                 ),
//                 items: [
//                   DropdownMenuItem(value: "Male", child: Text(t.male)),
//                   DropdownMenuItem(value: "Female", child: Text(t.female)),
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     selectedGender = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 14),

//               InkWell(
//                 borderRadius: BorderRadius.circular(16),
//                 onTap: selectBirthDate,
//                 child: InputDecorator(
//                   decoration: inputDecoration(
//                     context,
//                     label: t.dateOfBirth,
//                     icon: Icons.cake_outlined,
//                   ),
//                   child: Text(
//                     formatBirthDate(),
//                     style: selectedBirthDate == null
//                         ? theme.textTheme.bodyLarge?.copyWith(
//                             color: colorScheme.onSurfaceVariant,
//                           )
//                         : theme.textTheme.bodyLarge,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               Text(
//                 t.shippingAddress,
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               TextFormField(
//                 controller: countryController,
//                 textInputAction: TextInputAction.next,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.country,
//                   icon: Icons.public_rounded,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: cityController,
//                 textInputAction: TextInputAction.next,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.city,
//                   icon: Icons.location_city_rounded,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: addressController,
//                 textInputAction: TextInputAction.next,
//                 maxLines: 2,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.streetAddress,
//                   icon: Icons.home_outlined,
//                 ),
//               ),

//               const SizedBox(height: 14),

//               TextFormField(
//                 controller: zipCodeController,
//                 keyboardType: TextInputType.number,
//                 textInputAction: TextInputAction.done,
//                 decoration: inputDecoration(
//                   context,
//                   label: t.zipCode,
//                   icon: Icons.markunread_mailbox_outlined,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton.icon(
//                   onPressed: isSaving ? null : saveUser,
//                   icon: isSaving
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(Icons.save_outlined),
//                   label: Text(isSaving ? t.saving : t.saveChanges),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: colorScheme.onPrimary,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
