import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/main_nav_admin.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/localization/language_provider.dart';
import 'package:ecomerce_app/theme/theme_provider.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'verify_email_page.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
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

        // User not logged in
        if (user == null) {
          return const LoginPage();
        }

        // Email not verified
        if (!user.emailVerified) {
          return const VerifyEmailPage();
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: getUserData(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData) {
              final t = AppLocalizations.of(context)!;

              return Scaffold(body: Center(child: Text(t.somethingWentWrong)));
            }

            final data = userSnapshot.data!;

            final role = data['role'] as String?;

            return _LoadUserSettings(
              theme: data['theme'] as String?,
              language: data['language'] as String?,
              role: role,
            );
          },
        );
      },
    );
  }
}

class _LoadUserSettings extends StatefulWidget {
  final String? theme;
  final String? language;
  final String? role;

  const _LoadUserSettings({
    required this.theme,
    required this.language,
    required this.role,
  });

  @override
  State<_LoadUserSettings> createState() => _LoadUserSettingsState();
}

class _LoadUserSettingsState extends State<_LoadUserSettings> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<ThemeProvider>().loadUserTheme(widget.theme);

      if (!mounted) return;

      await context.read<LanguageProvider>().loadUserLanguage(widget.language);

      if (!mounted) return;

      setState(() {
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.role == 'admin') {
      return const MainNavAdmin();
    }

    if (widget.role == 'user') {
      return const MainNavUser();
    }

    return const LoginPage();
  }
}
