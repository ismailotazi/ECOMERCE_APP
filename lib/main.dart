import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/auth_check.dart';
import 'package:ecomerce_app/auth/store_selection_page.dart';
import 'package:ecomerce_app/auth/verify_email_page.dart';
import 'package:ecomerce_app/firebase_options.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/services/app_preferences.dart';
import 'package:ecomerce_app/super_admin/main_nav_super_admin.dart';
import 'package:ecomerce_app/theme/app_theme.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppPreferences.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Milo Mall',

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,

      locale: languageProvider.locale,

      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (languageProvider.locale != null) {
          return languageProvider.locale;
        }
        if (deviceLocale == null) {
          return const Locale('en');
        }

        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode) {
            return locale;
          }
        }

        return const Locale('en');
      },

      home: const AuthStartupPage(),
    );
  }
}

class AuthFlowState {
  static bool isLoginInProgress = false;
}

class AuthStartupPage extends StatelessWidget {
  const AuthStartupPage({super.key});
  Future<Map<String, dynamic>?> _getCurrentUserData(
    BuildContext context,
    User user,
  ) async {
    final themeProvider = context.read<ThemeProvider>();
    final languageProvider = context.read<LanguageProvider>();

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final doc = await docRef.get();

      if (!doc.exists) return null;

      final data = doc.data();

      if (user.emailVerified && data?['emailVerified'] != true) {
        await docRef.set({'emailVerified': true}, SetOptions(merge: true));

        data?['emailVerified'] = true;
      }

      await themeProvider.loadUserTheme(data?['theme'] as String?);

      await languageProvider.loadUserLanguage(data?['language'] as String?);

      return data;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;
        if (AuthFlowState.isLoginInProgress) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ================= GUEST / NOT LOGGED IN =================

        if (user == null) {
          final savedStoreId = AppPreferences.getSelectedStoreId();

          if (savedStoreId != null && savedStoreId.isNotEmpty) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(savedStoreId)
                  .get(),
              builder: (context, storeSnapshot) {
                if (storeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (storeSnapshot.hasError ||
                    !storeSnapshot.hasData ||
                    !storeSnapshot.data!.exists ||
                    storeSnapshot.data!.data()?['isActive'] != true) {
                  return const StoreSelectionPage();
                }

                return MainNavUser(storeId: savedStoreId);
              },
            );
          }

          return const StoreSelectionPage();
        }

        // ================= EMAIL NOT VERIFIED =================

        if (!user.emailVerified) {
          return const VerifyEmailPage(storeId: null);
        }
        // ================= LOAD USER DATA =================

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getCurrentUserData(context, user),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnapshot.data;

            if (userData == null) {
              return const StoreSelectionPage();
            }

            final role = userData['role']?.toString();

            final savedStoreId = AppPreferences.getSelectedStoreId();
            final defaultStoreId = userData['storeId']?.toString();

            final stores = Map<String, dynamic>.from(userData['stores'] ?? {});

            final String? storeId;

            if (role == 'admin') {
              // Admin kaybqa ghir f store dyalo
              storeId = defaultStoreId;
            } else if (role == 'user') {
              // User khaso ykoun 3ando membership active
              final savedStoreIsActive =
                  savedStoreId != null &&
                  savedStoreId.isNotEmpty &&
                  stores[savedStoreId] is Map &&
                  (stores[savedStoreId] as Map)['isActive'] == true;

              final defaultStoreIsActive =
                  defaultStoreId != null &&
                  defaultStoreId.isNotEmpty &&
                  stores[defaultStoreId] is Map &&
                  (stores[defaultStoreId] as Map)['isActive'] == true;

              storeId = savedStoreIsActive
                  ? savedStoreId
                  : defaultStoreIsActive
                  ? defaultStoreId
                  : null;
            } else {
              storeId = null;
            }

            // ================= INACTIVE ADMIN =================

            if (role == 'admin' && userData['isActive'] != true) {
              FirebaseAuth.instance.signOut();

              return const StoreSelectionPage();
            }
            // ================= SUPER ADMIN =================

            if (role == 'superAdmin') {
              return const MainNavSuperAdmin();
            }

            // ================= NORMAL USER / ADMIN =================

            if (storeId == null || storeId.isEmpty || storeId == 'null') {
              return const StoreSelectionPage();
            }

            debugPrint('🚀 FINAL STARTUP STORE ID: $storeId');
            debugPrint(
              '🚀 SAVED STORE ID: ${AppPreferences.getSelectedStoreId()}',
            );

            return AuthCheck(storeId: storeId);
          },
        );
      },
    );
  }
}
