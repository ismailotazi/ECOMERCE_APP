import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/account_service.dart';
import 'package:ecomerce_app/services/app_preferences.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:ecomerce_app/settings/change_password_page.dart';
import 'package:ecomerce_app/settings/language_page.dart';
import 'package:ecomerce_app/settings/theme_page.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/user_dashboard/user_edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  String currentLanguage = "";
  String currentTheme = "";

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

  Future openSupport() async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'ismailotazi1@gmail.com',
      query: 'subject=MILO Mall Support',
    );

    if (!await launchUrl(email)) {
      throw Exception('Could not open email app');
    }
  }

  Future openHelp() async {
    final Uri url = Uri.parse(
      'https://sites.google.com/view/milo-mallhelp/accueil',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open Help & Support");
    }
  }

  Future openTerms() async {
    final Uri url = Uri.parse(
      'https://sites.google.com/view/milo-mall/accueil',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open Terms of Service");
    }
  }

  Future openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://sites.google.com/view/milo-mallprivacypolicy/accueil',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open Privacy Policy");
    }
  }

  Widget settingsCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final isDesktop = width >= 1100;
            final isTablet = width >= 700;

            final horizontalPadding = isDesktop
                ? 32.0
                : isTablet
                ? 24.0
                : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isDesktop ? 28 : 20,
                    horizontalPadding,
                    30,
                  ),
                  children: [
                    Text(
                      t.accountSettings,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    settingsCard(
                      icon: Icons.edit_outlined,
                      title: t.editProfile,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserEditProfile(),
                          ),
                        );
                      },
                    ),

                    settingsCard(
                      icon: Icons.lock_outline_rounded,
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

                    // settingsCard(
                    //   icon: Icons.notifications_none_rounded,
                    //   title: t.notifications,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    //     );
                    //   },
                    // ),
                    settingsCard(
                      icon: Icons.language_rounded,
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

                    settingsCard(
                      icon: Icons.palette_outlined,
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

                    settingsCard(
                      icon: Icons.description_outlined,
                      title: t.termsOfService,
                      onTap: openTerms,
                    ),

                    settingsCard(
                      icon: Icons.privacy_tip_outlined,
                      title: t.privacyPolicy,
                      onTap: openPrivacyPolicy,
                    ),

                    settingsCard(
                      icon: Icons.help_outline_rounded,
                      title: t.helpAndSupport,
                      onTap: openHelp,
                    ),

                    settingsCard(
                      icon: Icons.support_agent_rounded,
                      title: t.contactSupport,
                      onTap: openSupport,
                    ),

                    settingsCard(
                      icon: Icons.delete_outline_rounded,
                      iconColor: theme.colorScheme.error,
                      title: t.deleteAccount,
                      onTap: () async {
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
                                    foregroundColor: theme.colorScheme.onError,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await AccountService.deleteUserAccount();

                                      await AppPreferences.clear();

                                      if (!context.mounted) {
                                        return;
                                      }

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                        (route) => false,
                                      );
                                    } catch (e) {
                                      if (!mounted) return;

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
                                  child: Text(t.delete),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    settingsCard(
                      icon: Icons.logout_rounded,
                      iconColor: theme.colorScheme.error,
                      title: t.logout,
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.logout_rounded,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      t.logout,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                t.logoutConfirmation,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                              actionsPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: Text(t.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: theme.colorScheme.onError,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(t.logout),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout != true) {
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.signOut();

                          // Clear local cart
                          await CartStorage.clearCart();

                          // Clear local favorites
                          await FavoriteStorage.clearFavorites();

                          // Clear app preferences
                          await AppPreferences.clear();

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: theme.colorScheme.surface,
                              content: Text(
                                t.loginFailed,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        }
                      },
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
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:ecomerce_app/auth/login_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';

// import 'package:ecomerce_app/services/app_preferences.dart';
// import 'package:ecomerce_app/settings/change_password_page.dart';
// import 'package:ecomerce_app/settings/language_page.dart';
// import 'package:ecomerce_app/settings/theme_page.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/theme/theme_provider.dart';
// import 'package:ecomerce_app/localization/language_provider.dart';

// import 'package:ecomerce_app/user_dashboard/user_edit_profile.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class UserSettingsPage extends StatefulWidget {
//   const UserSettingsPage({super.key});

//   @override
//   State<UserSettingsPage> createState() => _UserSettingsPageState();
// }

// class _UserSettingsPageState extends State<UserSettingsPage> {
//   String currentLanguage = "";
//   String currentTheme = "";

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

//   Future openSupport() async {
//     final Uri email = Uri(
//       scheme: 'mailto',
//       path: 'ismailotazi1@gmail.com',
//       query: 'subject=MILO Mall Support',
//     );

//     if (!await launchUrl(email)) {
//       throw Exception('Could not open email app');
//     }
//   }

//   Future openHelp() async {
//     final Uri url = Uri.parse(
//       'https://sites.google.com/view/milo-mallhelp/accueil',
//     );

//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       throw Exception("Could not open Help & Support");
//     }
//   }

//   Future openTerms() async {
//     final Uri url = Uri.parse(
//       'https://sites.google.com/view/milo-mall/accueil',
//     );

//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       throw Exception("Could not open Terms of Service");
//     }
//   }

//   Future openPrivacyPolicy() async {
//     final Uri url = Uri.parse(
//       'https://sites.google.com/view/milo-mallprivacypolicy/accueil',
//     );

//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       throw Exception("Could not open Privacy Policy");
//     }
//   }

//   Widget settingsCard({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     required VoidCallback onTap,
//     Color? iconColor,
//   }) {
//     final theme = Theme.of(context);

//     return Card(
//       elevation: 0,
//       color: theme.colorScheme.surfaceContainerHighest,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//         side: BorderSide(color: theme.colorScheme.outlineVariant),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
//         leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
//         title: Text(
//           title,
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         subtitle: subtitle != null
//             ? Text(
//                 subtitle,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.outline,
//                 ),
//               )
//             : null,
//         trailing: Icon(
//           Icons.arrow_forward_ios_rounded,
//           size: 16,
//           color: theme.colorScheme.outline,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.settings),
//         centerTitle: true,
//         leading: const CustomBackButton(),
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             Text(
//               t.accountSettings,
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 15),

//             settingsCard(
//               icon: Icons.edit_outlined,
//               title: t.editProfile,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const UserEditProfile()),
//                 );
//               },
//             ),

//             settingsCard(
//               icon: Icons.lock_outline_rounded,

//               title: t.changePassword,
//               subtitle: t.updateYourAccountPassword,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
//                 );
//               },
//             ),

//             // settingsCard(
//             //   icon: Icons.notifications_none_rounded,
//             //   title: t.notifications,
//             //   onTap: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(builder: (_) => const NotificationsPage()),
//             //     );
//             //   },
//             // ),
//             settingsCard(
//               icon: Icons.language_rounded,
//               title: t.language,
//               subtitle: currentLanguage,
//               onTap: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LanguagePage()),
//                 );

//                 if (!mounted) return;

//                 updateLanguageLabel();
//               },
//             ),

//             settingsCard(
//               icon: Icons.palette_outlined,
//               title: t.theme,
//               subtitle: currentTheme,
//               onTap: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ThemePage()),
//                 );

//                 if (!mounted) return;

//                 updateThemeLabel();
//               },
//             ),

//             settingsCard(
//               icon: Icons.description_outlined,
//               title: t.termsOfService,
//               onTap: openTerms,
//             ),

//             settingsCard(
//               icon: Icons.privacy_tip_outlined,
//               title: t.privacyPolicy,
//               onTap: openPrivacyPolicy,
//             ),

//             settingsCard(
//               icon: Icons.help_outline_rounded,
//               title: t.helpAndSupport,
//               onTap: openHelp,
//             ),

//             settingsCard(
//               icon: Icons.support_agent_rounded,
//               title: t.contactSupport,
//               onTap: openSupport,
//             ),

//             settingsCard(
//               icon: Icons.delete_outline_rounded,
//               iconColor: theme.colorScheme.error,
//               title: t.deleteAccount,
//               onTap: () async {
//                 showDialog(
//                   context: context,
//                   builder: (dialogContext) {
//                     return AlertDialog(
//                       backgroundColor: theme.colorScheme.surface,
//                       title: Text(
//                         t.deleteAccount,
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       content: Text(
//                         t.deleteAccountConfirmation,
//                         style: theme.textTheme.bodyMedium,
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(dialogContext);
//                           },
//                           child: Text(
//                             t.cancel,
//                             style: TextStyle(color: theme.colorScheme.outline),
//                           ),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: theme.colorScheme.error,
//                             foregroundColor: theme.colorScheme.onError,
//                           ),
//                           onPressed: () async {
//                             try {
//                               final user = FirebaseAuth.instance.currentUser;

//                               if (user == null) return;

//                               await FirebaseFirestore.instance
//                                   .collection("users")
//                                   .doc(user.uid)
//                                   .delete();

//                               await user.delete();

//                               await AppPreferences.clear();

//                               if (!context.mounted) return;

//                               Navigator.pushAndRemoveUntil(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => const LoginPage(),
//                                 ),
//                                 (route) => false,
//                               );
//                             } catch (e) {
//                               if (!mounted) return;

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   backgroundColor: theme.colorScheme.surface,
//                                   content: Text(
//                                     t.deleteFailed,
//                                     style: TextStyle(
//                                       color: theme.colorScheme.onSurface,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Text(t.delete),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),

//             settingsCard(
//               icon: Icons.logout_rounded,
//               iconColor: theme.colorScheme.error,
//               title: t.logout,
//               onTap: () async {
//                 final shouldLogout = await showDialog<bool>(
//                   context: context,
//                   builder: (dialogContext) {
//                     return AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                       title: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.errorContainer,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.logout_rounded,
//                               color: theme.colorScheme.error,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               t.logout,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       content: Text(
//                         t.logoutConfirmation,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: theme.colorScheme.onSurface.withValues(
//                             alpha: 0.75,
//                           ),
//                         ),
//                       ),
//                       actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                       actions: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pop(dialogContext, false);
//                           },
//                           child: Text(t.cancel),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(dialogContext, true);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: theme.colorScheme.error,
//                             foregroundColor: theme.colorScheme.onError,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           child: Text(t.logout),
//                         ),
//                       ],
//                     );
//                   },
//                 );

//                 if (shouldLogout != true) return;

//                 try {
//                   await FirebaseAuth.instance.signOut();

//                   await AppPreferences.clear();

//                   if (!context.mounted) return;

//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginPage()),
//                     (route) => false,
//                   );
//                 } catch (e) {
//                   if (!mounted) return;

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       backgroundColor: theme.colorScheme.surface,
//                       content: Text(
//                         t.loginFailed,
//                         style: TextStyle(color: theme.colorScheme.onSurface),
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
