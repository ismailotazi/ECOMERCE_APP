import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/settings/language_page.dart';
import 'package:ecomerce_app/settings/theme_page.dart';
import 'package:ecomerce_app/super_admin/Backup_database_page.dart';

import 'package:ecomerce_app/super_admin/edit_super_admin_profile_page.dart';
import 'package:ecomerce_app/super_admin/platform_overview_page.dart';
import 'package:ecomerce_app/super_admin/subscription_payments_page.dart';
import 'package:ecomerce_app/super_admin/subscriptions_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';

import 'package:ecomerce_app/super_admin/create_admin_page.dart';
import 'package:ecomerce_app/super_admin/create_store_page.dart';
import 'package:ecomerce_app/super_admin/super_admin_admins_page.dart';
import 'package:ecomerce_app/super_admin/super_admin_stores_page.dart';
import 'package:flutter/material.dart';

class SuperAdminSettingsPage extends StatefulWidget {
  const SuperAdminSettingsPage({super.key});

  @override
  State<SuperAdminSettingsPage> createState() => _SuperAdminSettingsPageState();
}

class _SuperAdminSettingsPageState extends State<SuperAdminSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isSigningOut = false;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!mounted) return;

      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('SUPER ADMIN SETTINGS ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendPasswordReset() async {
    final t = AppLocalizations.of(context)!;
    final user = _auth.currentUser;

    if (user == null || user.email == null || user.email!.isEmpty) {
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(t.passwordResetEmailSent),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('PASSWORD RESET ERROR: ${e.code} - ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.somethingWentWrong),
        ),
      );
    } catch (e) {
      debugPrint('PASSWORD RESET ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.somethingWentWrong),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    if (isSigningOut) return;

    setState(() {
      isSigningOut = true;
    });

    try {
      await _auth.signOut();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSigningOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.somethingWentWrong),
        ),
      );
    }
  }

  Future<void> _showSignOutDialog() async {
    final t = AppLocalizations.of(context)!;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Text(t.signOut),
          content: Text(t.signOutConfirmation),
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
              child: Text(t.signOut),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true && mounted) {
      await _signOut();
    }
  }

  Future<void> _openPage(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (result == true && mounted) {
      await _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final user = _auth.currentUser;

    final firstName = userData?['firstName']?.toString().trim() ?? '';

    final lastName = userData?['lastName']?.toString().trim() ?? '';

    final fullName = '$firstName $lastName'.trim();

    final displayName = fullName.isNotEmpty
        ? fullName
        : userData?['name']?.toString().trim().isNotEmpty == true
        ? userData!['name'].toString().trim()
        : t.superAdmin;

    final email = user?.email ?? userData?['email']?.toString() ?? '';

    final photoUrl = userData?['photoUrl']?.toString().trim() ?? '';

    final emailVerified =
        user?.emailVerified == true || userData?['emailVerified'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final isDesktop = width >= 1100;
                  final isTablet = width >= 700 && width < 1100;

                  final horizontalPadding = isDesktop
                      ? 40.0
                      : isTablet
                      ? 28.0
                      : 20.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isDesktop ? 32 : 24,
                          horizontalPadding,
                          32,
                        ),
                        children: [
                          // =================================================
                          // ACCOUNT
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.account,
                            icon: Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 12),

                          _buildAccountCard(
                            context,
                            displayName: displayName,
                            email: email,
                            photoUrl: photoUrl,
                            emailVerified: emailVerified,
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // SECURITY
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.security,
                            icon: Icons.security_outlined,
                          ),

                          const SizedBox(height: 12),

                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.lock_reset_rounded,
                                title: t.changePassword,
                                subtitle: t.passwordResetDescription,
                                onTap: _sendPasswordReset,
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // APPEARANCE
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.appearance,
                            icon: Icons.palette_outlined,
                          ),

                          const SizedBox(height: 12),

                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.language_rounded,
                                title: t.language,
                                subtitle: t.chooseYourPreferredLanguage,
                                onTap: () {
                                  _openPage(const LanguagePage());
                                },
                              ),
                              const Divider(height: 1),
                              _buildSettingsTile(
                                context,
                                icon: Icons.dark_mode_outlined,
                                title: t.theme,
                                subtitle: t.chooseYourPreferredTheme,
                                onTap: () {
                                  _openPage(const ThemePage());
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // STORE MANAGEMENT
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.storeManagement,
                            icon: Icons.storefront_outlined,
                          ),

                          const SizedBox(height: 12),

                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.storefront_outlined,
                                title: t.manageStores,
                                subtitle: t.manageAllStoresAndAdmins,
                                onTap: () {
                                  _openPage(const SuperAdminStoresPage());
                                },
                              ),
                              const Divider(height: 1),
                              _buildSettingsTile(
                                context,
                                icon: Icons.add_business_outlined,
                                title: t.createStore,
                                subtitle: t.createNewStoreForPlatform,
                                onTap: () {
                                  _openPage(const CreateStorePage());
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // ADMIN MANAGEMENT
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.adminManagement,
                            icon: Icons.admin_panel_settings_outlined,
                          ),

                          const SizedBox(height: 12),

                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.admin_panel_settings_outlined,
                                title: t.manageAdmins,
                                subtitle: t.createAdminsAndAssignStores,
                                onTap: () {
                                  _openPage(const SuperAdminAdminsPage());
                                },
                              ),
                              const Divider(height: 1),
                              _buildSettingsTile(
                                context,
                                icon: Icons.person_add_alt_1_rounded,
                                title: t.createAdmin,
                                subtitle: t.createAdminAssignStore,
                                onTap: () {
                                  _openPage(const CreateAdminPage());
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // SUBSCRIPTION PAYMENTS
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.subscriptionPayments,
                            icon: Icons.receipt_long_rounded,
                          ),

                          const SizedBox(height: 12),
                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.analytics_outlined,
                                title: t.subscriptions,
                                subtitle: t.manageAllSubscriptions,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SubscriptionsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.fact_check_outlined,
                                title: t.reviewSubscriptionPayments,
                                subtitle: t.reviewSubscriptionPaymentsSubtitle,
                                onTap: () {
                                  _openPage(const SubscriptionPaymentsPage());
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // =================================================
                          // PLATFORM
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.platform,
                            icon: Icons.dashboard_outlined,
                          ),
                          const SizedBox(height: 12),

                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.analytics_outlined,
                                title: t.platformOverview,
                                subtitle: t.manageAllStoresAndAdmins,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PlatformOverviewPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.backup_rounded,
                                title: t.backupDatabase,
                                subtitle: t.createBackup,
                                onTap: () {
                                  _openPage(const BackupDatabasePage());
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // ABOUT
                          // =================================================
                          _buildSectionTitle(
                            context,
                            title: t.about,
                            icon: Icons.info_outline_rounded,
                          ),

                          const SizedBox(height: 12),

                          _buildSettingsCard(
                            context,
                            children: [
                              _buildSettingsTile(
                                context,
                                icon: Icons.shopping_bag_outlined,
                                title: t.aboutMiloMall,
                                subtitle: t.saasMarketplacePlatform,
                                onTap: () {
                                  _showAboutDialog();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // SIGN OUT
                          // =================================================
                          SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: isSigningOut
                                  ? null
                                  : _showSignOutDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                side: BorderSide(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              icon: isSigningOut
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.error,
                                      ),
                                    )
                                  : const Icon(Icons.logout_rounded),
                              label: Text(
                                t.signOut,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 21, color: colorScheme.primary),
        const SizedBox(width: 9),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    BuildContext context, {
    required String displayName,
    required String email,
    required String photoUrl,
    required bool emailVerified,
  }) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openPage(const EditSuperAdminProfilePage());
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'images/official.jpg',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 64,
                      height: 64,
                      color: colorScheme.primaryContainer,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 34,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: emailVerified
                            ? colorScheme.primary.withValues(alpha: 0.12)
                            : colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        emailVerified ? t.emailVerified : t.emailNotVerified,
                        style: TextStyle(
                          color: emailVerified
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(elevation: 0, child: Column(children: children));
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: colorScheme.onPrimaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 17,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Future<void> _showAboutDialog() async {
    final t = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.aboutMiloMall),
          content: Text(t.saasMarketplacePlatform),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(t.close),
            ),
          ],
        );
      },
    );
  }
}
