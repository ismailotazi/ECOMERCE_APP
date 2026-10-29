import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';

class AddBankPage extends StatefulWidget {
  const AddBankPage({super.key, this.bankId, this.initialData});

  final String? bankId;
  final Map<String, dynamic>? initialData;

  bool get isEditing => bankId != null;

  @override
  State<AddBankPage> createState() => _AddBankPageState();
}

class _AddBankPageState extends State<AddBankPage> {
  final _formKey = GlobalKey<FormState>();

  final bankNameController = TextEditingController();
  final accountNameController = TextEditingController();
  final ibanController = TextEditingController();
  final ribController = TextEditingController();
  final swiftController = TextEditingController();

  bool isActive = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      final data = widget.initialData!;

      bankNameController.text = data["bankName"]?.toString() ?? "";

      accountNameController.text = data["accountName"]?.toString() ?? "";

      ibanController.text = data["iban"]?.toString() ?? "";

      ribController.text = data["rib"]?.toString() ?? "";

      swiftController.text = data["swift"]?.toString() ?? "";

      isActive = data["isActive"] == true;
    }
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountNameController.dispose();
    ibanController.dispose();
    ribController.dispose();
    swiftController.dispose();

    super.dispose();
  }

  Future<void> _saveBank() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      saving = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not authenticated");
      }

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found");
      }

      final userData = userDoc.data();

      if (userData == null) {
        throw Exception("User data not found");
      }

      final storeId = userData["storeId"]?.toString();

      if (storeId == null || storeId.isEmpty) {
        throw Exception("Store ID not found");
      }

      final bankData = {
        "bankName": bankNameController.text.trim(),
        "accountName": accountNameController.text.trim(),
        "iban": ibanController.text.replaceAll(' ', '').trim().toUpperCase(),
        "rib": ribController.text.replaceAll(' ', '').trim(),
        "swift": swiftController.text.trim().toUpperCase(),

        "isActive": isActive,
      };
      final banksRef = FirebaseFirestore.instance.collection("banks");

      if (widget.isEditing) {
        final bankDoc = await banksRef.doc(widget.bankId).get();

        if (!bankDoc.exists) {
          throw Exception("Bank account not found");
        }

        final bankDataFirestore = bankDoc.data();

        if (bankDataFirestore == null ||
            bankDataFirestore["storeId"]?.toString() != storeId) {
          throw Exception("Unauthorized bank account");
        }

        await banksRef.doc(widget.bankId).update(bankData);
      } else {
        await banksRef.add({
          ...bankData,
          "storeId": storeId,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? t.bankAccountUpdatedSuccessfully
                : t.bankAccountAddedSuccessfully,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? t.failedToUpdateBankAccount
                : t.failedToAddBankAccount,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;

    final isDesktop = screenWidth >= 1000;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;

    final horizontalPadding = isDesktop
        ? 32.0
        : isTablet
        ? 24.0
        : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? t.editBankAccount : t.addBankAccount),
        leading: const CustomBackButton(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isDesktop ? 32 : 20,
                  horizontalPadding,
                  40,
                ),
                children: [
                  // ============================================================
                  // HEADER
                  // ============================================================
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 24 : 20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isDesktop ? 58 : 52,
                          height: isDesktop ? 58 : 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            widget.isEditing
                                ? Icons.edit_rounded
                                : Icons.account_balance_rounded,
                            color: colorScheme.primary,
                            size: isDesktop ? 29 : 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEditing
                                    ? t.editBankInformation
                                    : t.bankInformation,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.isEditing
                                    ? t.updateBankAccountInfo
                                    : t.addBankAccountInfo,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isDesktop ? 28 : 22),

                  // ============================================================
                  // FORM
                  // ============================================================
                  if (isDesktop)
                    _buildDesktopForm(context: context, t: t)
                  else
                    _buildMobileForm(context: context, t: t),

                  const SizedBox(height: 24),

                  // ============================================================
                  // ACTIVE
                  // ============================================================
                  Card(
                    margin: EdgeInsets.zero,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 20 : 14,
                        vertical: 4,
                      ),
                      title: Text(
                        t.active,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(t.customersCanUseAccount),
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ============================================================
                  // SAVE BUTTON
                  // ============================================================
                  SizedBox(
                    width: double.infinity,
                    height: isDesktop ? 58 : 54,
                    child: ElevatedButton.icon(
                      onPressed: saving ? null : _saveBank,
                      icon: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              widget.isEditing
                                  ? Icons.save_rounded
                                  : Icons.add_rounded,
                            ),
                      label: Text(
                        saving
                            ? t.saving
                            : widget.isEditing
                            ? t.updateBankAccount
                            : t.saveBankAccount,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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

  // ===========================================================================
  // DESKTOP FORM
  // ===========================================================================

  Widget _buildDesktopForm({
    required BuildContext context,
    required AppLocalizations t,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: bankNameController,
                textCapitalization: TextCapitalization.words,
                decoration: inputDecoration(
                  context: context,
                  label: t.bankName,
                  icon: Icons.account_balance_rounded,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return t.bankNameRequired;
                  }

                  if (text.length < 2) {
                    return t.enterValidBankName;
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: accountNameController,
                textCapitalization: TextCapitalization.words,
                decoration: inputDecoration(
                  context: context,
                  label: t.accountName,
                  icon: Icons.person_rounded,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return t.accountNameRequired;
                  }

                  if (text.length < 2) {
                    return t.enterValidAccountName;
                  }

                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: ibanController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 28,
                decoration: inputDecoration(
                  context: context,
                  label: t.iban,
                  icon: Icons.credit_card_rounded,
                ),
                validator: (value) {
                  final iban =
                      value?.replaceAll(' ', '').trim().toUpperCase() ?? '';

                  if (iban.isEmpty) {
                    return t.ibanRequired;
                  }

                  if (!RegExp(r'^MA[0-9]{26}$').hasMatch(iban)) {
                    return t.enterValidIban;
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: ribController,
                maxLength: 24,
                decoration: inputDecoration(
                  context: context,
                  label: t.rib,
                  icon: Icons.numbers_rounded,
                ),
                validator: (value) {
                  final rib = value?.replaceAll(' ', '').trim() ?? '';

                  if (rib.isEmpty) {
                    return t.ribRequired;
                  }

                  if (!RegExp(r'^\d{24}$').hasMatch(rib)) {
                    return t.ribExactly24Digits;
                  }

                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: swiftController,
                textCapitalization: TextCapitalization.characters,
                decoration: inputDecoration(
                  context: context,
                  label: t.swiftBic,
                  icon: Icons.public_rounded,
                ),
                validator: (value) {
                  final swift = value?.trim().toUpperCase() ?? '';

                  if (swift.isEmpty) {
                    return null;
                  }

                  if (!RegExp(r'^[A-Z0-9]{8}([A-Z0-9]{3})?$').hasMatch(swift)) {
                    return t.enterValidSwiftBic;
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // MOBILE / TABLET FORM
  // ===========================================================================

  Widget _buildMobileForm({
    required BuildContext context,
    required AppLocalizations t,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: bankNameController,
          textCapitalization: TextCapitalization.words,
          decoration: inputDecoration(
            context: context,
            label: t.bankName,
            icon: Icons.account_balance_rounded,
          ),
          validator: (value) {
            final text = value?.trim() ?? '';

            if (text.isEmpty) {
              return t.bankNameRequired;
            }

            if (text.length < 2) {
              return t.enterValidBankName;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: accountNameController,
          textCapitalization: TextCapitalization.words,
          decoration: inputDecoration(
            context: context,
            label: t.accountName,
            icon: Icons.person_rounded,
          ),
          validator: (value) {
            final text = value?.trim() ?? '';

            if (text.isEmpty) {
              return t.accountNameRequired;
            }

            if (text.length < 2) {
              return t.enterValidAccountName;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: ibanController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 28,
          decoration: inputDecoration(
            context: context,
            label: t.iban,
            icon: Icons.credit_card_rounded,
          ),
          validator: (value) {
            final iban = value?.replaceAll(' ', '').trim().toUpperCase() ?? '';

            if (iban.isEmpty) {
              return t.ibanRequired;
            }

            if (!RegExp(r'^MA[0-9]{26}$').hasMatch(iban)) {
              return t.enterValidIban;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: ribController,
          maxLength: 24,
          decoration: inputDecoration(
            context: context,
            label: t.rib,
            icon: Icons.numbers_rounded,
          ),
          validator: (value) {
            final rib = value?.replaceAll(' ', '').trim() ?? '';

            if (rib.isEmpty) {
              return t.ribRequired;
            }

            if (!RegExp(r'^\d{24}$').hasMatch(rib)) {
              return t.ribExactly24Digits;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: swiftController,
          textCapitalization: TextCapitalization.characters,
          decoration: inputDecoration(
            context: context,
            label: t.swiftBic,
            icon: Icons.public_rounded,
          ),
          validator: (value) {
            final swift = value?.trim().toUpperCase() ?? '';

            if (swift.isEmpty) {
              return null;
            }

            if (!RegExp(r'^[A-Z0-9]{8}([A-Z0-9]{3})?$').hasMatch(swift)) {
              return t.enterValidSwiftBic;
            }

            return null;
          },
        ),
      ],
    );
  }
}
