import 'dart:async';

import 'package:ecomerce_app/auth/store_selection_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/super_admin/subscriptions_page.dart';
import 'package:ecomerce_app/super_admin/super_admin_admins_page.dart';
import 'package:ecomerce_app/super_admin/super_admin_home_page.dart';
import 'package:ecomerce_app/super_admin/super_admin_settings_page.dart';
import 'package:ecomerce_app/super_admin/super_admin_stores_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavSuperAdmin extends StatefulWidget {
  const MainNavSuperAdmin({super.key});

  @override
  State<MainNavSuperAdmin> createState() => _MainNavSuperAdminState();
}

class _MainNavSuperAdminState extends State<MainNavSuperAdmin> {
  int _currentIndex = 0;
  DateTime? _lastBackPressTime;
  StreamSubscription<User?>? _authSubscription;

  late final List<Widget> _pages = [
    const SuperAdminHomePage(),
    const SuperAdminStoresPage(),
    SubscriptionsPage(showArrowBack: false),
    const SuperAdminAdminsPage(),
    const SuperAdminSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // User signed out
    if (currentUser == null) {
      return const StoreSelectionPage();
    }

    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = width >= 1100;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: t.platform,
      ),
      NavigationDestination(
        icon: const Icon(Icons.storefront_outlined),
        selectedIcon: const Icon(Icons.storefront_rounded),
        label: t.stores,
      ),
      NavigationDestination(
        icon: Icon(Icons.workspace_premium_outlined),
        selectedIcon: Icon(Icons.workspace_premium_rounded),
        label: t.subscriptions,
      ),

      NavigationDestination(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        selectedIcon: const Icon(Icons.admin_panel_settings_rounded),
        label: t.admins,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: t.settings,
      ),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();

        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.tapAgainToExit),
              duration: const Duration(seconds: 2),
            ),
          );

          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Row(
          children: [
            if (isDesktop)
              _buildDesktopNavigation(context, destinations, colorScheme),

            Expanded(
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),
          ],
        ),
        bottomNavigationBar: isDesktop
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onItemTapped,
                height: 72,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                  states,
                ) {
                  final selected = states.contains(WidgetState.selected);

                  return TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  );
                }),
                destinations: destinations,
              ),
      ),
    );
  }

  Widget _buildDesktopNavigation(
    BuildContext context,
    List<NavigationDestination> destinations,
    ColorScheme colorScheme,
  ) {
    final t = AppLocalizations.of(context)!;

    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onItemTapped,
      extended: MediaQuery.sizeOf(context).width >= 1250,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
      selectedIconTheme: IconThemeData(color: colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      leading: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 24),
        child: _buildLogo(context, t),
      ),
      destinations: destinations
          .map(
            (destination) => NavigationRailDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: Text(destination.label),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLogo(BuildContext context, AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: t.superAdmin,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.admin_panel_settings_rounded,
          color: colorScheme.onPrimary,
          size: 26,
        ),
      ),
    );
  }
}
