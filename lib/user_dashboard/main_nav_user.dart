import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/login_page.dart';

import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_firestore.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/user_dashboard/user_notifications_page.dart';
import 'package:ecomerce_app/user_dashboard/cart_page.dart';
import 'package:ecomerce_app/user_dashboard/favorite_page.dart';
import 'package:ecomerce_app/user_dashboard/home_page.dart';
import 'package:ecomerce_app/user_dashboard/user_profil_page.dart';
import 'package:ecomerce_app/user_dashboard/user_settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavUser extends StatefulWidget {
  final String? storeId;

  const MainNavUser({super.key, this.storeId});

  @override
  State<MainNavUser> createState() => _MainNavUserState();
}

class _MainNavUserState extends State<MainNavUser> {
  int currentIndex = 0;
  DateTime? _lastBackPressTime;
  String? storeId;
  String? storeName;
  List<Widget> get pages => [
    HomePage(storeId: storeId),
    CartPage(showArrowBack: false, storeId: storeId),
    FavoritePage(showArrowBack: false, storeId: storeId),
    UserNotificationsPage(showArrowBack: false, storeId: storeId),
    UserProfilPage(showArrowBack: false, storeId: storeId),
  ];
  @override
  void initState() {
    super.initState();

    if (widget.storeId != null && widget.storeId!.isNotEmpty) {
      storeId = widget.storeId;
      _loadStoreName();
    } else {
      _loadStoreId();
    }
  }

  Future<void> _loadStoreName() async {
    if (storeId == null || storeId!.isEmpty) return;

    final storeDoc = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();

    if (!mounted) return;

    setState(() {
      storeName = storeDoc.data()?['name']?.toString();
    });
  }

  Future<void> _loadStoreId() async {
    debugPrint('⚠️ _loadStoreId() CALLED');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) return;

    final userData = userDoc.data();

    final userStoreId = userData?['storeId']?.toString();

    if (userStoreId == null || userStoreId.isEmpty) return;

    final storeDoc = await FirebaseFirestore.instance
        .collection('stores')
        .doc(userStoreId)
        .get();

    if (!mounted) return;

    final storeData = storeDoc.data();

    setState(() {
      storeId = userStoreId;
      storeName = storeData?['name']?.toString();
    });
  }

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
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: user == null || storeId == null || storeId!.isEmpty
          ? const Stream.empty()
          : CartFirestore.cartStream(storeId!),
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
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: user == null || storeId == null || storeId!.isEmpty
          ? const Stream.empty()
          : CartFirestore.cartStream(storeId!),
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
    return _buildFavoriteBadge(context, Icons.favorite_outline);
  }

  Widget _buildSelectedFavoriteIcon(BuildContext context) {
    return _buildFavoriteBadge(context, Icons.favorite);
  }

  Widget _buildFavoriteBadge(BuildContext context, IconData icon) {
    final user = FirebaseAuth.instance.currentUser;
    final currentStoreId = storeId?.trim();

    if (user == null || currentStoreId == null || currentStoreId.isEmpty) {
      return Icon(icon);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots(),
      builder: (context, favoriteSnapshot) {
        if (favoriteSnapshot.hasError) {
          return _buildBadgeIcon(context, icon: icon, count: 0);
        }

        final favoriteDocs = favoriteSnapshot.data?.docs ?? [];

        if (favoriteDocs.isEmpty) {
          return _buildBadgeIcon(context, icon: icon, count: 0);
        }

        return FutureBuilder<List<String>>(
          future: Future.wait(
            favoriteDocs.map((favoriteDoc) async {
              final productDoc = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(favoriteDoc.id)
                  .get();

              if (!productDoc.exists) return '';

              final productData = productDoc.data();

              if (productData?['storeId']?.toString() == currentStoreId) {
                return favoriteDoc.id;
              }

              return '';
            }),
          ),
          builder: (context, productSnapshot) {
            final count =
                productSnapshot.data
                    ?.where((productId) => productId.isNotEmpty)
                    .length ??
                0;

            return _buildBadgeIcon(context, icon: icon, count: count);
          },
        );
      },
    );
  }

  // ============================================================
  // NOTIFICATION BADGE
  // ============================================================

  Widget _buildNotificationIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || storeId == null || storeId!.isEmpty) {
      return const Icon(Icons.notifications_none_rounded);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('recipient', isEqualTo: 'user')
          .where('storeId', isEqualTo: storeId)
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

    if (user == null || storeId == null || storeId!.isEmpty) {
      return const Icon(Icons.notifications_rounded);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('recipient', isEqualTo: 'user')
          .where('storeId', isEqualTo: storeId)
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
    if (FirebaseAuth.instance.currentUser == null && index != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(storeId: storeId)),
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
                if (currentIndex != 0) _buildDesktopAppBar(context),

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
                      storeName ?? '',
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

                        icon: index == 1
                            ? _buildCartIcon(context)
                            : index == 2
                            ? _buildFavoriteIcon(context)
                            : index == 3
                            ? _buildNotificationIcon(context)
                            : Icon(destinations[index].icon),

                        selectedIcon: index == 1
                            ? _buildSelectedCartIcon(context)
                            : index == 2
                            ? _buildSelectedFavoriteIcon(context)
                            : index == 3
                            ? _buildSelectedNotificationIcon(context)
                            : Icon(destinations[index].selectedIcon),

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
    required Widget icon,
    required Widget selectedIcon,
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
              IconTheme(
                data: IconThemeData(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 23,
                ),
                child: selected ? selectedIcon : icon,
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
    final user = FirebaseAuth.instance.currentUser;
    final t = AppLocalizations.of(context)!;

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
            child: currentIndex == 0
                ? Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          storeName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    titles[currentIndex],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          // Profile: Notifications + Settings
          if (currentIndex == 4 && user != null) ...[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .where('recipient', isEqualTo: 'user')
                  .where('storeId', isEqualTo: storeId)
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.docs.length ?? 0;

                return IconButton(
                  tooltip: t.notifications,
                  onPressed: () => _changePage(3),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
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
            ),
            IconButton(
              tooltip: t.settings,
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserSettingsPage(storeId: storeId),
                  ),
                );
              },
            ),
          ],

          // Notifications: Mark all as read
          if (currentIndex == 3 && user != null)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: t.markAllAsRead,
              onPressed: () async {
                if (storeId == null || storeId!.isEmpty) return;

                try {
                  final snapshot = await FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userId', isEqualTo: user.uid)
                      .where('recipient', isEqualTo: 'user')
                      .where('storeId', isEqualTo: storeId)
                      .where('isRead', isEqualTo: false)
                      .get();

                  final batch = FirebaseFirestore.instance.batch();

                  for (final doc in snapshot.docs) {
                    batch.update(doc.reference, {'isRead': true});
                  }

                  if (snapshot.docs.isNotEmpty) {
                    await batch.commit();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.allNotificationsMarkedAsRead)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.somethingWentWrong)),
                    );
                  }
                }
              },
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
