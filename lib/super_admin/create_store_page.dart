import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateStorePage extends StatefulWidget {
  const CreateStorePage({super.key});

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeIdController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  bool isActive = true;
  bool isLoading = false;
  bool isPickingImage = false;

  // ================= STORE LOGO =================

  XFile? selectedLogo;
  String? selectedLogoName;
  final List<String> categories = [
    'smartphones',
    'computers',
    'electronics',
    'perfumes',
    'accessories',
    'gold',
    'silver',
    'fashion',
    'beauty',
    'furniture',
    'sports',
    'gaming',
    'other',
  ];
  final Set<String> selectedCategories = {};
  String _categoryLabel(String category, AppLocalizations t) {
    switch (category) {
      case 'smartphones':
        return t.smartphones;
      case 'computers':
        return t.computers;
      case 'electronics':
        return t.electronics;
      case 'perfumes':
        return t.perfumes;
      case 'accessories':
        return t.accessories;
      case 'gold':
        return t.gold;

      case 'silver':
        return t.silver;

      case 'fashion':
        return t.fashion;
      case 'beauty':
        return t.beauty;
      case 'furniture':
        return t.furniture;
      case 'sports':
        return t.sports;
      case 'gaming':
        return t.gaming;
      case 'other':
        return t.other;
      default:
        return category;
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    storeIdController.dispose();
    whatsappController.dispose();
    super.dispose();
  }

  // ================= PICK LOGO =================

  Future<void> pickLogo() async {
    if (isLoading || isPickingImage) return;

    setState(() {
      isPickingImage = true;
    });

    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        selectedLogo = image;
        selectedLogoName = image.name;
      });
    } catch (e) {
      debugPrint('PICK STORE LOGO ERROR: $e');

      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.somethingWentWrong),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPickingImage = false;
        });
      }
    }
  }

  // ================= REMOVE LOGO =================

  void removeLogo() {
    if (isLoading) return;

    setState(() {
      selectedLogo = null;
      selectedLogoName = null;
    });
  }

  // ================= UPLOAD LOGO =================

  Future<String?> uploadStoreLogo(String storeId) async {
    if (selectedLogo == null) {
      return null;
    }

    final bytes = await selectedLogo!.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception('Store logo is empty.');
    }

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('stores')
        .child(storeId)
        .child('logo.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public,max-age=31536000',
    );

    await storageRef.putData(bytes, metadata);

    final downloadUrl = await storageRef.getDownloadURL();

    return downloadUrl;
  }

  // ================= CREATE STORE =================

  Future<void> createStore() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.selectStoreCategories),
        ),
      );
      return;
    }

    if (isLoading) {
      return;
    }

    final storeName = storeNameController.text.trim();
    final storeId = storeIdController.text.trim().toLowerCase();
    final whatsappNumber = whatsappController.text.trim().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    setState(() {
      isLoading = true;
    });

    try {
      final storeRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId);

      // ================= CHECK EXISTING STORE =================

      final existingStore = await storeRef.get();

      if (existingStore.exists) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(t.storeIdAlreadyExists),
          ),
        );

        return;
      }

      // ================= UPLOAD LOGO =================

      String? logoUrl;

      if (selectedLogo != null) {
        logoUrl = await uploadStoreLogo(storeId);
      }

      // ================= CREATE STORE =================

      await storeRef.set({
        'name': storeName,
        'logoUrl': logoUrl,
        'whatsappNumber': whatsappNumber,
        'isActive': isActive,
        'categories': selectedCategories.toList()..sort(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(t.storeCreatedSuccessfully),
        ),
      );

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      debugPrint('CREATE STORE ERROR: ${e.code}');
      debugPrint('CREATE STORE MESSAGE: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.somethingWentWrong),
        ),
      );
    } catch (e) {
      debugPrint('CREATE STORE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.somethingWentWrong),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= STORE LOGO WIDGET =================

  Widget _buildStoreLogo(BuildContext context, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;

    final double logoSize = isDesktop ? 140 : 120;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: selectedLogo != null
                    ? FutureBuilder<Uint8List>(
                        future: selectedLogo!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.primary,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }

                          return Icon(
                            Icons.storefront_rounded,
                            size: isDesktop ? 54 : 48,
                            color: colorScheme.primary,
                          );
                        },
                      )
                    : Icon(
                        Icons.storefront_rounded,
                        size: isDesktop ? 54 : 48,
                        color: colorScheme.primary,
                      ),
              ),
            ),

            Positioned(
              right: -2,
              bottom: -2,
              child: Material(
                color: colorScheme.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: isLoading || isPickingImage ? null : pickLogo,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: isPickingImage
                        ? Padding(
                            padding: const EdgeInsets.all(11),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            selectedLogo == null
                                ? Icons.camera_alt_rounded
                                : Icons.edit_rounded,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (selectedLogo != null) ...[
          const SizedBox(height: 14),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: colorScheme.primary,
              ),

              const SizedBox(width: 6),

              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    selectedLogoName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              IconButton(
                onPressed: isLoading ? null : removeLogo,
                tooltip: 'Remove',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ================= INPUT DECORATION =================

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.createStore,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: const CustomBackButton(),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isDesktop = width >= 1100;
            final bool isTablet = width >= 700 && width < 1100;

            final double horizontalPadding = isDesktop
                ? 40
                : isTablet
                ? 32
                : 20;

            final double verticalPadding = isDesktop
                ? 40
                : isTablet
                ? 32
                : 24;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    children: [
                      // =========================
                      // HEADER ICON
                      // =========================
                      Center(
                        child: Container(
                          width: isDesktop ? 72 : 64,
                          height: isDesktop ? 72 : 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            size: isDesktop ? 38 : 34,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        t.storeInformation,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        t.createNewStoreForPlatform,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // =========================
                      // STORE LOGO
                      // =========================
                      _buildStoreLogo(context, isDesktop),

                      const SizedBox(height: 32),

                      // =========================
                      // STORE NAME
                      // =========================
                      TextFormField(
                        controller: storeNameController,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          context: context,
                          label: t.storeName,
                          hint: t.exampleMiloMall,
                          icon: Icons.storefront_outlined,
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return t.pleaseEnterStoreName;
                          }

                          if (text.length < 2) {
                            return t.storeNameTooShort;
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // STORE ID
                      // =========================
                      TextFormField(
                        controller: storeIdController,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        decoration: _inputDecoration(
                          context: context,
                          label: t.storeId,
                          hint: t.exampleMiloMallId,
                          icon: Icons.fingerprint_rounded,
                        ),
                        validator: (value) {
                          final text = value?.trim().toLowerCase() ?? '';

                          if (text.isEmpty) {
                            return t.pleaseEnterStoreId;
                          }

                          if (text.length < 3) {
                            return t.storeIdTooShort;
                          }

                          if (!RegExp(r'^[a-z0-9_]+$').hasMatch(text)) {
                            return t.storeIdCharactersError;
                          }

                          return null;
                        },
                        onChanged: (value) {
                          final normalized = value.toLowerCase().replaceAll(
                            ' ',
                            '_',
                          );

                          if (normalized != value) {
                            storeIdController.value = storeIdController.value
                                .copyWith(
                                  text: normalized,
                                  selection: TextSelection.collapsed(
                                    offset: normalized.length,
                                  ),
                                );
                          }
                        },
                      ),

                      const SizedBox(height: 18),
                      TextFormField(
                        controller: whatsappController,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          context: context,
                          label: t.whatsappNumber,
                          hint: "212000000000",
                          icon: Icons.phone_rounded,
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return t.enterWhatsappNumber;
                          }

                          final cleanNumber = text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          );

                          if (cleanNumber.length < 10 ||
                              cleanNumber.length > 15) {
                            return t.invalidWhatsappNumber;
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // =========================
                      // STORE CATEGORIES
                      // =========================
                      Text(
                        t.storeCategories,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        t.selectStoreCategories,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        color: colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Column(
                            children: categories.map((category) {
                              return CheckboxListTile(
                                value: selectedCategories.contains(category),
                                onChanged: isLoading
                                    ? null
                                    : (selected) {
                                        setState(() {
                                          if (selected == true) {
                                            selectedCategories.add(category);
                                          } else {
                                            selectedCategories.remove(category);
                                          }
                                        });
                                      },
                                title: Text(_categoryLabel(category, t)),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // ACTIVE
                      // =========================
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        color: colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 20 : 16,
                            vertical: 4,
                          ),
                          value: isActive,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    isActive = value;
                                  });
                                },
                          title: Text(
                            t.storeActive,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            isActive
                                ? t.usersCanAccessStore
                                : t.usersCannotAccessStore,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // =========================
                      // CREATE BUTTON
                      // =========================
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : createStore,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  t.createStore,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
