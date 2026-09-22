import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/add_bank_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:ecomerce_app/theme/custom_back_button.dart';

class AdminPaymentBanksPage extends StatelessWidget {
  const AdminPaymentBanksPage({super.key});

  Future<void> _toggleBank(
    BuildContext context,
    String bankId,
    bool isActive,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("banks").doc(bankId).update({
        "isActive": !isActive,
      });

      if (!context.mounted) return;
      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isActive ? t.bankAccountDisabled : t.bankAccountEnabled,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.unableToUpdateBankAccount),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteBank(
    BuildContext context,
    String bankId,
    String bankName,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.deleteBankAccount),
          content: Text(t.deleteBankConfirmation(bankName)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(t.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection("banks").doc(bankId).delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.bankAccountDeleted),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.unableToDeleteBankAccount),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    final horizontalPadding = isDesktop
        ? 32.0
        : isTablet
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.paymentBanks),
        leading: const CustomBackButton(),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("banks")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 40 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isDesktop ? 88 : 76,
                      height: isDesktop ? 88 : 76,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: isDesktop ? 44 : 38,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.unableToLoadPaymentBanks,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        // StreamBuilder will retry automatically.
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(t.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          final banks = snapshot.data?.docs ?? [];

          if (banks.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 40 : 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isDesktop ? 96 : 82,
                        height: isDesktop ? 96 : 82,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_outlined,
                          size: isDesktop ? 46 : 40,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.noBankAccountsYet,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.addBankAccountToEnableTransfers,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isDesktop ? 24 : 20,
                  horizontalPadding,
                  isDesktop ? 120 : 100,
                ),
                itemCount: banks.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: isDesktop ? 16 : 12),
                itemBuilder: (context, index) {
                  final doc = banks[index];

                  final bank = doc.data() as Map<String, dynamic>;

                  final bankName = bank["bankName"]?.toString().trim() ?? "";

                  final accountName =
                      bank["accountName"]?.toString().trim() ?? "";

                  final iban = bank["iban"]?.toString().trim() ?? "";

                  final rib = bank["rib"]?.toString().trim() ?? "";

                  final isActive = bank["isActive"] == true;

                  return Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 22 : 20),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: isDesktop ? 58 : 54,
                                height: isDesktop ? 58 : 54,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    isDesktop ? 17 : 16,
                                  ),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: colorScheme.primary,
                                  size: isDesktop ? 28 : 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bankName.isEmpty
                                          ? t.unnamedBank
                                          : bankName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      accountName.isEmpty
                                          ? t.accountNameNotProvided
                                          : accountName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                tooltip: t.bankOptions,
                                onSelected: (value) async {
                                  if (value == "edit") {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddBankPage(
                                          bankId: doc.id,
                                          initialData: bank,
                                        ),
                                      ),
                                    );

                                    if (!context.mounted) return;

                                    // StreamBuilder updates automatically.
                                    if (result == true) {
                                      // No manual refresh needed.
                                    }
                                  }

                                  if (value == "toggle") {
                                    if (!context.mounted) return;

                                    await _toggleBank(
                                      context,
                                      doc.id,
                                      isActive,
                                    );
                                  }

                                  if (value == "delete") {
                                    if (!context.mounted) return;

                                    await _deleteBank(
                                      context,
                                      doc.id,
                                      bankName,
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: "edit",
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_rounded),
                                        const SizedBox(width: 10),
                                        Text(t.edit),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "toggle",
                                    child: Row(
                                      children: [
                                        Icon(
                                          isActive
                                              ? Icons.toggle_off_rounded
                                              : Icons.toggle_on_rounded,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(isActive ? t.disable : t.enable),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: "delete",
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          t.delete,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Divider(height: 1, color: colorScheme.outlineVariant),

                          const SizedBox(height: 14),

                          if (iban.isNotEmpty)
                            _BankInfoRow(
                              icon: Icons.credit_card_rounded,
                              label: t.iban,
                              value: iban,
                            ),

                          if (rib.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _BankInfoRow(
                              icon: Icons.numbers_rounded,
                              label: t.rib,
                              value: rib,
                            ),
                          ],

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green
                                      : colorScheme.outline,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isActive ? t.active : t.inactive,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isActive
                                      ? Colors.green
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBankPage()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          t.addBankAccount,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BankInfoRow extends StatelessWidget {
  const _BankInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/add_bank_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';

// import 'package:ecomerce_app/theme/custom_back_button.dart';

// class AdminPaymentBanksPage extends StatelessWidget {
//   const AdminPaymentBanksPage({super.key});

//   Future<void> _toggleBank(
//     BuildContext context,
//     String bankId,
//     bool isActive,
//   ) async {
//     try {
//       await FirebaseFirestore.instance.collection("banks").doc(bankId).update({
//         "isActive": !isActive,
//       });

//       if (!context.mounted) return;
//       final t = AppLocalizations.of(context)!;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isActive ? t.bankAccountDisabled : t.bankAccountEnabled,
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!context.mounted) return;
//       final t = AppLocalizations.of(context)!;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.unableToUpdateBankAccount),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   Future<void> _deleteBank(
//     BuildContext context,
//     String bankId,
//     String bankName,
//   ) async {
//     final colorScheme = Theme.of(context).colorScheme;
//     final t = AppLocalizations.of(context)!;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(t.deleteBankAccount),
//           content: Text(t.deleteBankConfirmation(bankName)),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: Text(t.cancel),
//             ),
//             FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: colorScheme.error,
//                 foregroundColor: colorScheme.onError,
//               ),
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               child: Text(t.delete),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true) return;

//     try {
//       await FirebaseFirestore.instance.collection("banks").doc(bankId).delete();

//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.bankAccountDeleted),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(t.unableToDeleteBankAccount),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.paymentBanks),
//         leading: const CustomBackButton(),
//         centerTitle: true,
//       ),

//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection("banks")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),

//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(color: colorScheme.primary),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.error_outline_rounded,
//                       size: 52,
//                       color: colorScheme.error,
//                     ),

//                     const SizedBox(height: 14),

//                     Text(
//                       t.unableToLoadPaymentBanks,
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     FilledButton.icon(
//                       onPressed: () {
//                         // StreamBuilder will retry automatically.
//                       },
//                       icon: const Icon(Icons.refresh_rounded),
//                       label: Text(t.tryAgain),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final banks = snapshot.data?.docs ?? [];

//           if (banks.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(30),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 82,
//                       height: 82,
//                       decoration: BoxDecoration(
//                         color: colorScheme.primaryContainer,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.account_balance_outlined,
//                         size: 40,
//                         color: colorScheme.primary,
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     Text(
//                       t.noBankAccountsYet,
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Text(
//                       t.addBankAccountToEnableTransfers,
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           return ListView.separated(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//             itemCount: banks.length,
//             separatorBuilder: (_, _) => const SizedBox(height: 12),

//             itemBuilder: (context, index) {
//               final doc = banks[index];

//               final bank = doc.data() as Map<String, dynamic>;

//               final bankName = bank["bankName"]?.toString().trim() ?? "";

//               final accountName = bank["accountName"]?.toString().trim() ?? "";

//               final iban = bank["iban"]?.toString().trim() ?? "";

//               final rib = bank["rib"]?.toString().trim() ?? "";

//               final isActive = bank["isActive"] == true;

//               return Card(
//                 elevation: 0,
//                 clipBehavior: Clip.antiAlias,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   side: BorderSide(color: colorScheme.outlineVariant),
//                 ),

//                 child: Padding(
//                   padding: const EdgeInsets.all(16),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,

//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,

//                         children: [
//                           Container(
//                             width: 54,
//                             height: 54,
//                             decoration: BoxDecoration(
//                               color: colorScheme.primaryContainer,
//                               borderRadius: BorderRadius.circular(16),
//                             ),

//                             child: Icon(
//                               Icons.account_balance_rounded,
//                               color: colorScheme.primary,
//                               size: 26,
//                             ),
//                           ),

//                           const SizedBox(width: 14),

//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,

//                               children: [
//                                 Text(
//                                   bankName.isEmpty ? t.unnamedBank : bankName,

//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,

//                                   style: theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),

//                                 const SizedBox(height: 4),

//                                 Text(
//                                   accountName.isEmpty
//                                       ? t.accountNameNotProvided
//                                       : accountName,

//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,

//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color: colorScheme.onSurfaceVariant,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           PopupMenuButton<String>(
//                             tooltip: t.bankOptions,

//                             onSelected: (value) async {
//                               if (value == "edit") {
//                                 final result = await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => AddBankPage(
//                                       bankId: doc.id,
//                                       initialData: bank,
//                                     ),
//                                   ),
//                                 );

//                                 if (!context.mounted) return;

//                                 // StreamBuilder updates automatically.
//                                 if (result == true) {
//                                   // No manual refresh needed.
//                                 }
//                               }

//                               if (value == "toggle") {
//                                 if (!context.mounted) return;

//                                 await _toggleBank(context, doc.id, isActive);
//                               }

//                               if (value == "delete") {
//                                 if (!context.mounted) return;

//                                 await _deleteBank(context, doc.id, bankName);
//                               }
//                             },

//                             itemBuilder: (context) => [
//                               PopupMenuItem(
//                                 value: "edit",
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.edit_rounded),
//                                     SizedBox(width: 10),
//                                     Text(t.edit),
//                                   ],
//                                 ),
//                               ),

//                               PopupMenuItem(
//                                 value: "toggle",
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       isActive
//                                           ? Icons.toggle_off_rounded
//                                           : Icons.toggle_on_rounded,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(isActive ? t.disable : t.enable),
//                                   ],
//                                 ),
//                               ),

//                               const PopupMenuDivider(),

//                               PopupMenuItem(
//                                 value: "delete",
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.delete_outline_rounded,
//                                       color: colorScheme.error,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       t.delete,
//                                       style: TextStyle(
//                                         color: colorScheme.error,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       Divider(height: 1, color: colorScheme.outlineVariant),

//                       const SizedBox(height: 14),

//                       if (iban.isNotEmpty)
//                         _BankInfoRow(
//                           icon: Icons.credit_card_rounded,
//                           label: t.iban,
//                           value: iban,
//                         ),

//                       if (rib.isNotEmpty) ...[
//                         const SizedBox(height: 10),

//                         _BankInfoRow(
//                           icon: Icons.numbers_rounded,
//                           label: t.rib,
//                           value: rib,
//                         ),
//                       ],

//                       const SizedBox(height: 14),

//                       Row(
//                         children: [
//                           Container(
//                             width: 9,
//                             height: 9,
//                             decoration: BoxDecoration(
//                               color: isActive
//                                   ? Colors.green
//                                   : colorScheme.outline,
//                               shape: BoxShape.circle,
//                             ),
//                           ),

//                           const SizedBox(width: 7),

//                           Text(
//                             isActive ? t.active : t.inactive,

//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: isActive
//                                   ? Colors.green
//                                   : colorScheme.onSurfaceVariant,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),

//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddBankPage()),
//           );
//         },

//         icon: const Icon(Icons.add_rounded),

//         label: Text(
//           t.addBankAccount,
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }
// }

// class _BankInfoRow extends StatelessWidget {
//   const _BankInfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   final IconData icon;
//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 19, color: colorScheme.primary),

//         const SizedBox(width: 10),

//         Text(
//           "$label: ",
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: colorScheme.onSurfaceVariant,
//             fontWeight: FontWeight.w600,
//           ),
//         ),

//         Expanded(
//           child: Text(
//             value,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: theme.textTheme.bodySmall?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
