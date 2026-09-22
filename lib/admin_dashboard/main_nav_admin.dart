import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_drawer.dart';
import 'package:ecomerce_app/admin_dashboard/admin_notifications_page.dart';
import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';
import 'package:ecomerce_app/admin_dashboard/dashboard_page.dart';
import 'package:ecomerce_app/admin_dashboard/profile_admin_page.dart';
import 'package:ecomerce_app/admin_dashboard/add_product.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavAdmin extends StatefulWidget {
  const MainNavAdmin({super.key});

  @override
  State<MainNavAdmin> createState() => _MainNavAdminState();
}

class _MainNavAdminState extends State<MainNavAdmin> {
  int currentIndex = 0;
  DateTime? _lastBackPressTime;

  final List<Widget> pages = const [
    DashboardPage(),
    AddProductPage(),
    AnalyticsPage(showAppBar: false),
    ProfileAdminPage(),
  ];

  List<String> get titles {
    final t = AppLocalizations.of(context)!;

    return [t.home, t.addProduct, t.analytics, t.profile];
  }

  void _changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminNotificationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return _buildDesktopLayout(context, t, theme, colorScheme);
          }

          return _buildMobileLayout(context, t, theme, colorScheme);
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP / TABLET
  // ============================================================

  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations t,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        children: [
          _buildSideNavigation(context, t, colorScheme),

          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(context, theme, colorScheme),

                Expanded(
                  child: IndexedStack(index: currentIndex, children: pages),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    final destinations = [
      (
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        label: t.home,
      ),
      (
        icon: Icons.add_box_outlined,
        selectedIcon: Icons.add_box,
        label: t.addProduct,
      ),
      (
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics_outlined,
        label: t.analytics,
      ),
      (
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
        label: t.profile,
      ),
    ];

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo / Admin title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.admin,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (int index = 0; index < destinations.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildSideNavItem(
                        context,
                        icon: destinations[index].icon,
                        selectedIcon: destinations[index].selectedIcon,
                        label: destinations[index].label,
                        selected: currentIndex == index,
                        onTap: () => _changePage(index),
                      ),
                    ),
                ],
              ),
            ),

            // Drawer settings / other admin items
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildDrawerButton(context, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 23,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, ColorScheme colorScheme) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (context) {
              return SafeArea(
                child: SizedBox(height: 500, child: const AdminDrawer()),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  t.settings,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titles[currentIndex],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          _buildNotificationButton(context, colorScheme),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations t,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(titles[currentIndex], style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,

        automaticallyImplyLeading: true,

        actions: [_buildNotificationButton(context, colorScheme)],
      ),

      drawer: const AdminDrawer(),

      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        onDestinationSelected: _changePage,

        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: t.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_box_outlined),
            selectedIcon: const Icon(Icons.add_box),
            label: t.addProduct,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics_outlined),
            label: t.analytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: const Icon(Icons.admin_panel_settings),
            label: t.profile,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Widget _buildNotificationButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("recipient", isEqualTo: "admin")
          .where("isRead", isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unread = snapshot.data?.docs.length ?? 0;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: _openNotifications,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 25),

              if (unread > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_drawer.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_notifications_page.dart';
// import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';

// import 'package:ecomerce_app/admin_dashboard/dashboard_page.dart';
// import 'package:ecomerce_app/admin_dashboard/profile_admin_page.dart';

// import 'package:ecomerce_app/admin_dashboard/add_product.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class MainNavAdmin extends StatefulWidget {
//   const MainNavAdmin({super.key});

//   @override
//   State<MainNavAdmin> createState() => _MainNavAdminState();
// }

// class _MainNavAdminState extends State<MainNavAdmin> {
//   int currentIndex = 0;
//   DateTime? _lastBackPressTime;
//   bool get showDrawer => currentIndex == 0;
//   final List<Widget> pages = const [
//     DashboardPage(),

//     AddProductPage(),
//     AnalyticsPage(showAppBar: false),
//     ProfileAdminPage(),
//   ];

//   List<String> get titles {
//     final t = AppLocalizations.of(context)!;

//     return [t.home, t.addProduct, t.analytics, t.profile];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;

//         final now = DateTime.now();

//         if (_lastBackPressTime == null ||
//             now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
//           _lastBackPressTime = now;

//           ScaffoldMessenger.of(context).hideCurrentSnackBar();

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(t.tapAgainToExit),
//               duration: const Duration(seconds: 2),
//             ),
//           );

//           return;
//         }

//         SystemNavigator.pop();
//       },
//       child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         appBar: AppBar(
//           title: Text(
//             titles[currentIndex],
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           centerTitle: true,
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           foregroundColor: Theme.of(context).colorScheme.onSurface,
//           elevation: 0,
//           scrolledUnderElevation: 0,

//           automaticallyImplyLeading: showDrawer,

//           actions: showDrawer
//               ? [
//                   StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection("notifications")
//                         .where("recipient", isEqualTo: "admin")
//                         .where("isRead", isEqualTo: false)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       final unread = snapshot.data?.docs.length ?? 0;

//                       return IconButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => AdminNotificationsPage(),
//                             ),
//                           );
//                         },
//                         icon: Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             const Icon(Icons.notifications_outlined),

//                             if (unread > 0)
//                               Positioned(
//                                 right: -6,
//                                 top: -6,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(3),
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).colorScheme.error,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   constraints: const BoxConstraints(
//                                     minWidth: 18,
//                                     minHeight: 18,
//                                   ),
//                                   child: Text(
//                                     unread.toString(),
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onError,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ]
//               : [],
//         ),
//         drawer: showDrawer ? const AdminDrawer() : null,
//         body: IndexedStack(index: currentIndex, children: pages),

//         bottomNavigationBar: NavigationBar(
//           backgroundColor: Theme.of(context).colorScheme.surface,

//           selectedIndex: currentIndex,
//           labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//           onDestinationSelected: (index) {
//             setState(() {
//               currentIndex = index;
//             });
//           },
//           destinations: [
//             NavigationDestination(
//               icon: Icon(Icons.inventory_2_outlined),
//               selectedIcon: Icon(Icons.inventory_2),
//               label: t.home,
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.add_box_outlined),
//               selectedIcon: Icon(Icons.add_box),
//               label: t.addProduct,
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.analytics_outlined),

//               selectedIcon: Icon(Icons.analytics_outlined),
//               label: t.analytics,
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.admin_panel_settings_outlined),
//               selectedIcon: Icon(Icons.admin_panel_settings),
//               label: t.profile,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
