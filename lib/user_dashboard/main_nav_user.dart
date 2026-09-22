import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_firestore.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/user_dashboard/User_notifications_page.dart';
import 'package:ecomerce_app/user_dashboard/cart_page.dart';
import 'package:ecomerce_app/user_dashboard/favorite_page.dart';
import 'package:ecomerce_app/user_dashboard/home_page.dart';
import 'package:ecomerce_app/user_dashboard/user_profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavUser extends StatefulWidget {
  const MainNavUser({super.key});

  @override
  State<MainNavUser> createState() => _MainNavUserState();
}

class _MainNavUserState extends State<MainNavUser> {
  int currentIndex = 0;
  DateTime? _lastBackPressTime;

  final List<Widget> pages = const [
    HomePage(),
    CartPage(showArrowBack: false),
    FavoritePage(showArrowBack: false),
    UserNotificationsPage(showArrowBack: false),
    UserProfilPage(showArrowBack: false),
  ];

  List<String> get titles {
    final t = AppLocalizations.of(context)!;

    return [t.home, t.cart, t.favorite, t.notifications, t.profile];
  }

  // ============================================================
  // BADGE
  // ============================================================

  Widget _buildBadgeIcon(
    BuildContext context, {
    required IconData icon,
    required int count,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),

        if (count > 0)
          Positioned(
            right: -9,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CART BADGE
  // ============================================================

  Widget _buildCartIcon(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: CartFirestore.cartStream(),
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          for (final item in snapshot.data!) {
            count += (item["quantity"] as num?)?.toInt() ?? 1;
          }
        }

        return _buildBadgeIcon(
          context,
          icon: Icons.shopping_cart_outlined,
          count: count,
        );
      },
    );
  }

  Widget _buildSelectedCartIcon(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: CartFirestore.cartStream(),
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          for (final item in snapshot.data!) {
            count += (item["quantity"] as num?)?.toInt() ?? 1;
          }
        }

        return _buildBadgeIcon(
          context,
          icon: Icons.shopping_cart,
          count: count,
        );
      },
    );
  }

  // ============================================================
  // FAVORITE BADGE
  // ============================================================

  Widget _buildFavoriteIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Icon(Icons.favorite_outline);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return _buildBadgeIcon(
          context,
          icon: Icons.favorite_outline,
          count: count,
        );
      },
    );
  }

  Widget _buildSelectedFavoriteIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Icon(Icons.favorite);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return _buildBadgeIcon(context, icon: Icons.favorite, count: count);
      },
    );
  }

  // ============================================================
  // NOTIFICATION BADGE
  // ============================================================

  Widget _buildNotificationIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Icon(Icons.notifications_none_rounded);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('recipient', isEqualTo: 'user')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return _buildBadgeIcon(
          context,
          icon: Icons.notifications_none_rounded,
          count: count,
        );
      },
    );
  }

  Widget _buildSelectedNotificationIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Icon(Icons.notifications_rounded);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('recipient', isEqualTo: 'user')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return _buildBadgeIcon(
          context,
          icon: Icons.notifications_rounded,
          count: count,
        );
      },
    );
  }

  // ============================================================
  // CHANGE PAGE
  // ============================================================

  void _changePage(int index) {
    final user = FirebaseAuth.instance.currentUser;

    // Guest cannot access notifications.
    if (index == 3 && user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

      return;
    }

    setState(() {
      currentIndex = index;
    });
  }
  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
            return _buildDesktopLayout(context, t);
          }

          return _buildMobileLayout(context, t);
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP / TABLET
  // ============================================================

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        children: [
          _buildSideNavigation(context, t),

          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(context),

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

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSideNavigation(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final destinations = [
      (icon: Icons.home_outlined, selectedIcon: Icons.home, label: t.home),
      (
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart,
        label: t.cart,
      ),
      (
        icon: Icons.favorite_outline,
        selectedIcon: Icons.favorite,
        label: t.favorite,
      ),
      (
        icon: Icons.notifications_none_rounded,
        selectedIcon: Icons.notifications_rounded,
        label: t.notifications,
      ),
      (
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
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

            // Logo / App title
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
                      Icons.shopping_bag_outlined,
                      color: colorScheme.primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Milo Mall',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  // ============================================================
  // DESKTOP APP BAR
  // ============================================================

  Widget _buildDesktopAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout(BuildContext context, AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: pages[currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: colorScheme.surface,

            // Selected icon = Purple
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              final selected = states.contains(WidgetState.selected);

              return IconThemeData(
                color: selected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              );
            }),

            // Selected label = Purple
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              final selected = states.contains(WidgetState.selected);

              return TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
              );
            }),

            // Purple selected indicator
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _changePage,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: t.home,
            ),
            NavigationDestination(
              icon: _buildCartIcon(context),
              selectedIcon: _buildSelectedCartIcon(context),
              label: t.cart,
            ),
            NavigationDestination(
              icon: _buildFavoriteIcon(context),
              selectedIcon: _buildSelectedFavoriteIcon(context),
              label: t.favorite,
            ),
            NavigationDestination(
              icon: _buildNotificationIcon(context),
              selectedIcon: _buildSelectedNotificationIcon(context),
              label: t.notifications,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: t.profile,
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/user_dashboard/cart_page.dart';
// import 'package:ecomerce_app/user_dashboard/favorite_page.dart';
// import 'package:ecomerce_app/user_dashboard/home_page.dart';
// import 'package:ecomerce_app/user_dashboard/user_profil_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class MainNavUser extends StatefulWidget {
//   const MainNavUser({super.key});

//   @override
//   State<MainNavUser> createState() => _MainNavUserState();
// }

// class _MainNavUserState extends State<MainNavUser> {
//   int currentIndex = 0;
//   DateTime? _lastBackPressTime;
//   final List<Widget> pages = const [
//     HomePage(),
//     CartPage(showArrowBack: false),
//     FavoritePage(showArrowBack: false),
//     UserProfilPage(showArrowBack: false),
//   ];

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
//         body: pages[currentIndex],

//         bottomNavigationBar: NavigationBar(
//           selectedIndex: currentIndex,
//           onDestinationSelected: (index) {
//             setState(() {
//               currentIndex = index;
//             });
//           },
//           destinations: [
//             NavigationDestination(
//               icon: Icon(Icons.home_outlined),
//               selectedIcon: Icon(Icons.home),
//               label: t.home,
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.shopping_cart_outlined),
//               selectedIcon: Icon(Icons.shopping_cart),
//               label: t.cart,
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.favorite_outline),
//               selectedIcon: Icon(Icons.favorite),
//               label: t.favorite,
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.person_outline),
//               selectedIcon: Icon(Icons.person),
//               label: t.profile,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
