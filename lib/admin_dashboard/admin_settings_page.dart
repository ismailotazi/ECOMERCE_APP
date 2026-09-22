import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/admin_payment_banks_page.dart';
import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';
import 'package:ecomerce_app/admin_dashboard/backup_database_page.dart';
import 'package:ecomerce_app/admin_dashboard/edit_admin_profile.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/services/account_service.dart';
import 'package:ecomerce_app/services/app_preferences.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:ecomerce_app/settings/change_password_page.dart';
import 'package:ecomerce_app/settings/language_page.dart';
import 'package:ecomerce_app/settings/theme_page.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  String currentLanguage = "";
  String currentTheme = "";

  // void exportOrders(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         "Export Orders coming soon",
  //         style: Theme.of(context).snackBarTheme.contentTextStyle,
  //       ),
  //     ),
  //   );
  // }

  // deletion account
  Future<void> deleteAccount(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.deleteAccount),
          content: Text(t.permanentlyDeleteAccountConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      // Delete Firestore document
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .delete();

      // Delete Authentication account
      await user.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.accountDeletedSuccessfully)));

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == "requires-recent-login") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.forSecurityReasonsSignInAgain)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? t.failedToDeleteAccount)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
      }
    }
  }

  void updateLanguageLabel() {
    final provider = context.read<LanguageProvider>();
    final t = AppLocalizations.of(context)!;

    setState(() {
      if (provider.isEnglish) {
        currentLanguage = "🇺🇸 ${t.english}";
      } else if (provider.isFrench) {
        currentLanguage = "🇫🇷 ${t.french}";
      } else if (provider.isArabic) {
        currentLanguage = "🇲🇦 ${t.arabic}";
      } else {
        currentLanguage = "📱 ${t.system}";
      }
    });
  }

  void updateThemeLabel() {
    final provider = context.read<ThemeProvider>();
    final t = AppLocalizations.of(context)!;

    setState(() {
      if (provider.isLight) {
        currentTheme = "☀️ ${t.light}";
      } else if (provider.isDark) {
        currentTheme = "🌙 ${t.dark}";
      } else {
        currentTheme = "📱 ${t.system}";
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      updateLanguageLabel();
      updateThemeLabel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 28.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  t.unableToLoadProfile,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final firstName = data["firstName"] ?? "";
            final lastName = data["lastName"] ?? "";
            final photoUrl = data["photoUrl"] ?? "";
            final email = FirebaseAuth.instance.currentUser?.email ?? "";

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 24 : 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: isDesktop ? 34 : 31,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl.isEmpty
                                  ? Icon(
                                      Icons.admin_panel_settings_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: isDesktop ? 35 : 32,
                                    )
                                  : null,
                            ),
                          ),

                          SizedBox(width: isDesktop ? 18 : 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$firstName $lastName",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDesktop ? 18 : null,
                                      ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  email,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isDesktop ? 32 : 28),

                    Text(
                      t.account,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      title: t.editProfile,
                      subtitle: t.updateYourAdministratorProfile,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditAdminProfile(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      title: t.changePassword,
                      subtitle: t.updateYourAccountPassword,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: isDesktop ? 32 : 30),

                    Text(
                      t.application,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SettingsTile(
                      icon: Icons.language_rounded,
                      color: Theme.of(context).colorScheme.tertiary,
                      title: t.language,
                      subtitle: currentLanguage,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguagePage(),
                          ),
                        );

                        if (!mounted) return;

                        updateLanguageLabel();
                      },
                    ),

                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      title: t.theme,
                      subtitle: currentTheme,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ThemePage()),
                        );

                        if (!mounted) return;

                        updateThemeLabel();
                      },
                    ),

                    const SizedBox(height: 12),

                    // _SettingsTile(
                    //   icon: Icons.notifications_active_outlined,
                    //   color: Theme.of(context).colorScheme.error,
                    //   title: t.notifications,
                    //   subtitle: t.manageNotificationSettings,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const NotificationSettingsPage(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    // const SizedBox(height: 30),
                    Text(
                      t.administration,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SettingsTile(
                      icon: Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      title: t.analytics,
                      subtitle: t.viewStoreAnalytics,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.inventory_2_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                      title: t.manageProducts,
                      subtitle: t.addEditOrDeleteProducts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.shopping_bag_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      title: t.manageOrders,
                      subtitle: t.trackAndUpdateOrders,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminOrdersPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.people_alt_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      title: t.manageUsers,
                      subtitle: t.viewRegisteredCustomers,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UsersPage()),
                        );
                      },
                    ),

                    // const SizedBox(height: 12),

                    // _SettingsTile(
                    //   icon: Icons.download_rounded,
                    //   color: Theme.of(context).colorScheme.primary,
                    //   title: t.exportOrders,
                    //   subtitle: t.exportAllOrders,
                    //   onTap: () {
                    //     exportOrders(context);
                    //   },
                    // ),
                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.backup_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                      title: t.backupDatabase,
                      subtitle: t.createBackup,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BackupDatabasePage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _SettingsTile(
                      icon: Icons.account_balance_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                      title: t.paymentBanks,
                      subtitle: t.manageBankTransferAccounts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPaymentBanksPage(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: isDesktop ? 32 : 30),

                    Text(
                      t.about,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.outline,
                      title: t.appVersion,
                      subtitle: t.version101,
                      onTap: () {},
                    ),

                    SizedBox(height: isDesktop ? 32 : 30),

                    SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 58 : 56,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          final theme = Theme.of(context);

                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                backgroundColor: theme.colorScheme.surface,
                                title: Text(
                                  t.deleteAccount,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  t.deleteAccountConfirmation,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    child: Text(
                                      t.cancel,
                                      style: TextStyle(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor:
                                          theme.colorScheme.onError,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await AccountService.deleteAdminAccount();

                                        await AppPreferences.clear();

                                        if (!context.mounted) return;

                                        Navigator.pop(dialogContext);

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginPage(),
                                          ),
                                          (route) => false,
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;

                                        Navigator.pop(dialogContext);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                theme.colorScheme.surface,
                                            content: Text(
                                              t.deleteFailed,
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(t.deleteAccount),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_forever_rounded),
                        label: Text(
                          t.deleteAccount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 58 : 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              final t = AppLocalizations.of(dialogContext)!;
                              final colorScheme = Theme.of(
                                dialogContext,
                              ).colorScheme;

                              return AlertDialog(
                                title: Text(t.logout),
                                content: Text(t.logoutConfirmation),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: Text(t.cancel),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                      foregroundColor: colorScheme.onError,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: Text(t.logout),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldLogout != true) return;

                          await FirebaseAuth.instance.signOut();

                          await CartStorage.clearCart();
                          await FavoriteStorage.clearFavorites();

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(
                          t.logout,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isDesktop ? 28 : 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isDesktop ? 56 : 52,
                height: isDesktop ? 56 : 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),

              SizedBox(width: isDesktop ? 18 : 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_payment_banks_page.dart';
// import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';
// import 'package:ecomerce_app/admin_dashboard/backup_database_page.dart';
// import 'package:ecomerce_app/admin_dashboard/edit_admin_profile.dart';
// import 'package:ecomerce_app/admin_dashboard/product_page.dart';
// import 'package:ecomerce_app/admin_dashboard/users_page.dart';
// import 'package:ecomerce_app/auth/login_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/localization/language_provider.dart';
// import 'package:ecomerce_app/settings/change_password_page.dart';
// import 'package:ecomerce_app/settings/language_page.dart';
// import 'package:ecomerce_app/settings/theme_page.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/theme/theme_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AdminSettingsPage extends StatefulWidget {
//   const AdminSettingsPage({super.key});

//   @override
//   State<AdminSettingsPage> createState() => _AdminSettingsPageState();
// }

// class _AdminSettingsPageState extends State<AdminSettingsPage> {
//   String currentLanguage = "";
//   String currentTheme = "";
//   // void exportOrders(BuildContext context) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Text(
//   //         "Export Orders coming soon",
//   //         style: Theme.of(context).snackBarTheme.contentTextStyle,
//   //       ),
//   //     ),
//   //   );
//   // }

//   // deletion account
//   Future<void> deleteAccount(BuildContext context) async {
//     final t = AppLocalizations.of(context)!;
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) return;

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(t.deleteAccount),
//           content: Text(t.permanentlyDeleteAccountConfirmation),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text(t.cancel),
//             ),
//             FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.error,
//               ),
//               onPressed: () => Navigator.pop(context, true),
//               child: Text(t.delete),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm != true) return;

//     try {
//       // Delete Firestore document
//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .delete();

//       // Delete Authentication account
//       await user.delete();

//       if (context.mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(t.accountDeletedSuccessfully)));

//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (_) => const LoginPage()),
//           (route) => false,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       if (context.mounted) {
//         if (e.code == "requires-recent-login") {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(t.forSecurityReasonsSignInAgain)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(e.message ?? t.failedToDeleteAccount)),
//           );
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
//       }
//     }
//   }

//   void updateLanguageLabel() {
//     final provider = context.read<LanguageProvider>();
//     final t = AppLocalizations.of(context)!;

//     setState(() {
//       if (provider.isEnglish) {
//         currentLanguage = "🇺🇸 ${t.english}";
//       } else if (provider.isFrench) {
//         currentLanguage = "🇫🇷 ${t.french}";
//       } else if (provider.isArabic) {
//         currentLanguage = "🇲🇦 ${t.arabic}";
//       } else {
//         currentLanguage = "📱 ${t.system}";
//       }
//     });
//   }

//   void updateThemeLabel() {
//     final provider = context.read<ThemeProvider>();
//     final t = AppLocalizations.of(context)!;

//     setState(() {
//       if (provider.isLight) {
//         currentTheme = "☀️ ${t.light}";
//       } else if (provider.isDark) {
//         currentTheme = "🌙 ${t.dark}";
//       } else {
//         currentTheme = "📱 ${t.system}";
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       updateLanguageLabel();
//       updateThemeLabel();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.settings),
//         leading: const CustomBackButton(),
//       ),

//       body: SafeArea(
//         child: FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance
//               .collection("users")
//               .doc(FirebaseAuth.instance.currentUser!.uid)
//               .get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return Center(
//                 child: Text(
//                   t.unableToLoadProfile,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final data = snapshot.data!.data() as Map<String, dynamic>;

//             final firstName = data["firstName"] ?? "";
//             final lastName = data["lastName"] ?? "";
//             final photoUrl = data["photoUrl"] ?? "";
//             final email = FirebaseAuth.instance.currentUser?.email ?? "";

//             return ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: .05),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),

//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.primary.withValues(alpha: 0.15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.primary.withValues(alpha: 0.12),
//                               blurRadius: 12,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: CircleAvatar(
//                           radius: 31,
//                           backgroundColor: Theme.of(
//                             context,
//                           ).colorScheme.surfaceContainerHighest,
//                           backgroundImage: photoUrl.isNotEmpty
//                               ? NetworkImage(photoUrl)
//                               : null,
//                           child: photoUrl.isEmpty
//                               ? Icon(
//                                   Icons.admin_panel_settings_rounded,
//                                   color: Theme.of(context).colorScheme.primary,
//                                   size: 32,
//                                 )
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(width: 16),

//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "$firstName $lastName",
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),

//                             const SizedBox(height: 4),

//                             Text(
//                               email,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 28),

//                 Text(
//                   t.account,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 14),
//                 _SettingsTile(
//                   icon: Icons.person_outline_rounded,
//                   color: Theme.of(context).colorScheme.primary,
//                   title: t.editProfile,
//                   subtitle: t.updateYourAdministratorProfile,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const EditAdminProfile(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.lock_outline_rounded,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.changePassword,
//                   subtitle: t.updateYourAccountPassword,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ChangePasswordPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 30),

//                 Text(
//                   t.application,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 14),

//                 _SettingsTile(
//                   icon: Icons.language_rounded,
//                   color: Theme.of(context).colorScheme.tertiary,
//                   title: t.language,
//                   subtitle: currentLanguage,
//                   onTap: () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const LanguagePage()),
//                     );

//                     if (!mounted) return;

//                     updateLanguageLabel();
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.dark_mode_rounded,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.theme,
//                   subtitle: currentTheme,
//                   onTap: () async {
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ThemePage()),
//                     );

//                     if (!mounted) return;

//                     updateThemeLabel();
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 // _SettingsTile(
//                 //   icon: Icons.notifications_active_outlined,
//                 //   color: Theme.of(context).colorScheme.error,
//                 //   title: t.notifications,
//                 //   subtitle: t.manageNotificationSettings,
//                 //   onTap: () {
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => const NotificationSettingsPage(),
//                 //       ),
//                 //     );
//                 //   },
//                 // ),
//                 // const SizedBox(height: 30),
//                 Text(
//                   t.administration,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 14),
//                 _SettingsTile(
//                   icon: Icons.analytics_outlined,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.analytics,
//                   subtitle: t.viewStoreAnalytics,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const AnalyticsPage()),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.inventory_2_outlined,
//                   color: Theme.of(context).colorScheme.tertiary,
//                   title: t.manageProducts,
//                   subtitle: t.addEditOrDeleteProducts,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ProductPage()),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.shopping_bag_outlined,
//                   color: Theme.of(context).colorScheme.primary,
//                   title: t.manageOrders,
//                   subtitle: t.trackAndUpdateOrders,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const AdminOrdersPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.people_alt_outlined,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.manageUsers,
//                   subtitle: t.viewRegisteredCustomers,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const UsersPage()),
//                     );
//                   },
//                 ),

//                 // const SizedBox(height: 12),

//                 // _SettingsTile(
//                 //   icon: Icons.download_rounded,
//                 //   color: Theme.of(context).colorScheme.primary,
//                 //   title: t.exportOrders,
//                 //   subtitle: t.exportAllOrders,
//                 //   onTap: () {
//                 //     exportOrders(context);
//                 //   },
//                 // ),
//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.backup_outlined,
//                   color: Theme.of(context).colorScheme.tertiary,
//                   title: t.backupDatabase,
//                   subtitle: t.createBackup,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const BackupDatabasePage(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 _SettingsTile(
//                   icon: Icons.account_balance_outlined,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.paymentBanks,
//                   subtitle: t.manageBankTransferAccounts,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const AdminPaymentBanksPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 30),

//                 Text(
//                   t.about,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 14),

//                 _SettingsTile(
//                   icon: Icons.info_outline_rounded,
//                   color: Theme.of(context).colorScheme.outline,
//                   title: t.appVersion,
//                   subtitle: t.version101,
//                   onTap: () {},
//                 ),

//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: OutlinedButton.icon(
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Theme.of(context).colorScheme.error,
//                       side: BorderSide(
//                         color: Theme.of(context).colorScheme.error,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                     onPressed: () {
//                       // Delete Account
//                     },
//                     icon: const Icon(Icons.delete_forever_rounded),
//                     label: Text(
//                       t.deleteAccount,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).colorScheme.error,
//                       foregroundColor: Theme.of(context).colorScheme.onError,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                     onPressed: () async {
//                       final shouldLogout = await showDialog<bool>(
//                         context: context,
//                         builder: (dialogContext) {
//                           final t = AppLocalizations.of(dialogContext)!;
//                           final colorScheme = Theme.of(
//                             dialogContext,
//                           ).colorScheme;

//                           return AlertDialog(
//                             title: Text(t.logout),
//                             content: Text(t.logoutConfirmation),
//                             actions: [
//                               TextButton(
//                                 onPressed: () =>
//                                     Navigator.pop(dialogContext, false),
//                                 child: Text(t.cancel),
//                               ),
//                               FilledButton(
//                                 style: FilledButton.styleFrom(
//                                   backgroundColor: colorScheme.error,
//                                   foregroundColor: colorScheme.onError,
//                                 ),
//                                 onPressed: () =>
//                                     Navigator.pop(dialogContext, true),
//                                 child: Text(t.logout),
//                               ),
//                             ],
//                           );
//                         },
//                       );

//                       if (shouldLogout != true) return;

//                       await FirebaseAuth.instance.signOut();

//                       if (context.mounted) {
//                         Navigator.pop(context);
//                       }
//                     },
//                     icon: const Icon(Icons.logout_rounded),
//                     label: Text(
//                       t.logout,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _SettingsTile extends StatelessWidget {
//   const _SettingsTile({
//     required this.icon,
//     required this.color,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   final IconData icon;
//   final Color color;
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Theme.of(context).colorScheme.surface,
//       borderRadius: BorderRadius.circular(20),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: .04),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha: .12),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Icon(icon, color: color),
//               ),

//               const SizedBox(width: 16),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ),

//               Icon(
//                 Icons.chevron_right_rounded,
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
