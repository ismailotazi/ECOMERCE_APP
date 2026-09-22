import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:image_picker/image_picker.dart';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  List<QueryDocumentSnapshot> banks = [];
  String? selectedBankId;
  bool loading = true;
  String? errorMessage;
  XFile? _paymentProof;
  bool _uploadingProof = false;
  Future<void> _pickPaymentProof() async {
    final t = AppLocalizations.of(context)!;
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _paymentProof = image;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.unableToSelectImage)));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBankData();
    });
  }

  Future<void> _loadBankData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("banks")
          .where("isActive", isEqualTo: true)
          .orderBy("createdAt", descending: true)
          .get();

      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      if (snapshot.docs.isEmpty) {
        setState(() {
          loading = false;
          errorMessage = t.noActiveBankAccountsAvailable;
        });
        return;
      }

      setState(() {
        banks = snapshot.docs;
        selectedBankId = snapshot.docs.first.id;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      setState(() {
        loading = false;
        errorMessage = t.unableToLoadPaymentInformation;
      });
    }
  }

  void _copy(BuildContext context, String value, String label) {
    final t = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: value));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label ${t.copied}"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBankTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),

        title: Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: title == "IBAN" || title == "RIB" ? .4 : 0,
            ),
          ),
        ),

        trailing: IconButton(
          tooltip: t.copy,
          icon: Icon(Icons.copy_rounded, color: colorScheme.primary),
          onPressed: () => _copy(context, value, title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.bankTransfer),
          leading: const CustomBackButton(),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.bankTransfer),
          leading: const CustomBackButton(),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 52,
                  color: colorScheme.error,
                ),

                const SizedBox(height: 16),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      loading = true;
                      errorMessage = null;
                    });

                    _loadBankData();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(t.tryAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Firestore data
    final bankDoc = banks.firstWhere((doc) => doc.id == selectedBankId);

    final bank = bankDoc.data() as Map<String, dynamic>;

    final bankName = bank["bankName"]?.toString() ?? "";
    final accountName = bank["accountName"]?.toString() ?? "";
    final iban = bank["iban"]?.toString() ?? "";
    final rib = bank["rib"]?.toString() ?? "";
    final isActive = bank["isActive"] == true;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.bankTransfer),
        leading: const CustomBackButton(),
        centerTitle: true,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: colorScheme.onPrimary,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    t.bankTransfer,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    t.transferYourOrderTotalToTheBankAccountBelow,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              t.selectBankAccount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: .6),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedBankId,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(18),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.primary,
                  ),
                  items: banks.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data["bankName"]?.toString() ?? t.bank;
                    final accountName = data["accountName"]?.toString() ?? "";

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_rounded,
                              color: colorScheme.primary,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  accountName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedBankId = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              t.bankAccountDetails,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _buildBankTile(
              context,
              title: t.bank,
              value: bankName,
              icon: Icons.account_balance_rounded,
            ),

            _buildBankTile(
              context,
              title: t.accountName,
              value: accountName,
              icon: Icons.person_rounded,
            ),

            _buildBankTile(
              context,
              title: "IBAN",
              value: iban,
              icon: Icons.credit_card_rounded,
            ),

            _buildBankTile(
              context,
              title: "RIB",
              value: rib,
              icon: Icons.numbers_rounded,
            ),
            Text(
              t.paymentProof,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: isActive ? _pickPaymentProof : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _paymentProof != null
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: _paymentProof != null ? 1.5 : 1,
                  ),
                ),
                child: _paymentProof == null
                    ? Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 38,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.uploadTransferScreenshot,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.tapToChooseAnImage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(_paymentProof!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.paymentProofSelected,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Important notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _paymentProof != null
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: _paymentProof != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      t.afterCompletingTheTransfer,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isActive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.bankTransferCurrentlyUnavailable,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isActive && _paymentProof != null && !_uploadingProof
                    ? () async {
                        setState(() {
                          _uploadingProof = true;
                        });

                        try {
                          final user = FirebaseAuth.instance.currentUser;

                          if (user == null) {
                            throw Exception(t.userNotLoggedIn);
                          }

                          final file = File(_paymentProof!.path);

                          final ref = FirebaseStorage.instance
                              .ref()
                              .child("payment_proofs")
                              .child(user.uid)
                              .child(
                                "${DateTime.now().millisecondsSinceEpoch}.jpg",
                              );

                          await ref.putFile(file);

                          final downloadUrl = await ref.getDownloadURL();

                          if (!context.mounted) return;

                          Navigator.pop(context, {
                            "confirmed": true,
                            "proofUrl": downloadUrl,
                            "bankId": selectedBankId,
                            "bankName": bank["bankName"]?.toString() ?? "",
                          });
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.uploadFailed)),
                          );

                          setState(() {
                            _uploadingProof = false;
                          });
                        }
                      }
                    : null,
                icon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  t.iHaveTransferred,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
