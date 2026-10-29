import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_notifications_page.dart';
import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/edit_admin_profile.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileAdminPage extends StatelessWidget {
  const ProfileAdminPage({super.key});

  String getLocalizedRole(BuildContext context, String role) {
    final t = AppLocalizations.of(context)!;

    switch (role.toLowerCase()) {
      case "admin":
        return t.admin;
      case "user":
        return t.user;
      default:
        return role;
    }
  }

  Future<List<dynamic>> _loadProfileData(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final userData = userDoc.data();

    if (userData == null) {
      throw Exception("User data not found");
    }

    final storeIdValue = userData["storeId"]?.toString();

    if (storeIdValue == null || storeIdValue.isEmpty) {
      throw Exception("Store ID not found");
    }

    final String storeId = storeIdValue;

    final results = await Future.wait([
      FirebaseFirestore.instance
          .collection("orders")
          .where("storeId", isEqualTo: storeId)
          .get(),

      FirebaseFirestore.instance
          .collection("users")
          .where("storeId", isEqualTo: storeId)
          .get(),

      FirebaseFirestore.instance.collection("stores").doc(storeId).get(),
    ]);

    return [userDoc, results[0], results[1], results[2]];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return FutureBuilder<List<dynamic>>(
      future: _loadProfileData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                t.somethingWentWrong,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        final userDoc =
            snapshot.data![0] as DocumentSnapshot<Map<String, dynamic>>;
        final orders = snapshot.data![1] as QuerySnapshot<Map<String, dynamic>>;
        final allUsers =
            snapshot.data![2] as QuerySnapshot<Map<String, dynamic>>;
        final storeDoc =
            snapshot.data![3] as DocumentSnapshot<Map<String, dynamic>>;

        final storeData = storeDoc.data() ?? {};

        final logoUrl = storeData['logoUrl']?.toString().trim() ?? '';
        final data = userDoc.data() ?? {};

        final storeId = data["storeId"]?.toString() ?? "";

        final usersCount = allUsers.docs.where((doc) {
          final userData = doc.data();

          if (userData["role"] != "user" || userData["emailVerified"] != true) {
            return false;
          }

          if (userData["storeId"]?.toString() == storeId) {
            return true;
          }

          final stores = userData["stores"];

          if (stores is Map<String, dynamic>) {
            final membership = stores[storeId];

            if (membership is Map<String, dynamic>) {
              return membership["role"] == "user" &&
                  membership["isActive"] == true;
            }
          }

          return false;
        }).length;

        final email = data["email"]?.toString().trim() ?? "";
        final phone = data["phone"]?.toString().trim() ?? "";
        final firstName = data["firstName"] ?? "";
        final lastName = data["lastName"] ?? "";
        final role = data["role"] ?? "Administrator";

        double revenue = 0;

        for (final doc in orders.docs) {
          final order = doc.data();

          if (order["status"] == "delivered") {
            final totalPrice = order["totalPrice"];

            if (totalPrice is num) {
              revenue += totalPrice.toDouble();
            } else if (totalPrice is String) {
              revenue += double.tryParse(totalPrice) ?? 0;
            }
          }
        }

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 20,
                vertical: 20,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 28 : 22),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.22),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.75),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    backgroundImage: logoUrl.isNotEmpty
                                        ? NetworkImage(logoUrl)
                                        : null,
                                    onBackgroundImageError: logoUrl.isNotEmpty
                                        ? (exception, stackTrace) {
                                            debugPrint(
                                              'ADMIN STORE LOGO ERROR: $exception',
                                            );
                                          }
                                        : null,
                                    child: logoUrl.isEmpty
                                        ? Icon(
                                            Icons.storefront_rounded,
                                            size: 38,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          )
                                        : null,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Name
                              if ("$firstName $lastName".trim().isNotEmpty)
                                Text(
                                  "$firstName $lastName".trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),

                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),

                              // Role
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      getLocalizedRole(context, role),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Stats
                              Row(
                                children: [
                                  Expanded(
                                    child: _HeaderStatCard(
                                      icon: Icons.attach_money_rounded,
                                      title: t.revenue,
                                      value:
                                          "${revenue.toStringAsFixed(0)} ${t.currencySymbol}",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _HeaderStatCard(
                                      icon: Icons.shopping_bag_outlined,
                                      title: t.orders,
                                      value: "${orders.docs.length}",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _HeaderStatCard(
                                      icon: Icons.people_outline_rounded,
                                      title: t.users,
                                      value: "$usersCount",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        Text(
                          t.account,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 15),

                        Card(
                          elevation:
                              Theme.of(context).brightness == Brightness.dark
                              ? 0
                              : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  t.editProfile,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditAdminProfile(),
                                    ),
                                  );
                                },
                              ),

                              Divider(
                                height: 1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),

                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  child: Icon(
                                    Icons.notifications,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                title: Text(
                                  t.notifications,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminNotificationsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          t.storeManagement,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 15),

                        Card(
                          elevation:
                              Theme.of(context).brightness == Brightness.dark
                              ? 0
                              : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.inventory,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  t.products,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductPage(),
                                    ),
                                  );
                                },
                              ),

                              Divider(
                                height: 1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),

                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  child: Icon(
                                    Icons.shopping_bag,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                title: Text(
                                  t.orders,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminOrdersPage(),
                                    ),
                                  );
                                },
                              ),

                              Divider(
                                height: 1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),

                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.tertiaryContainer,
                                  child: Icon(
                                    Icons.people,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                                ),
                                title: Text(
                                  t.users,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UsersPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () async {
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
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.errorContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.logout_rounded,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.75),
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
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onError,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
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

                              if (context.mounted) {
                                if (storeId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(t.somethingWentWrong),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(storeId: storeId),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                            label: Text(
                              t.logout,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onError,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderStatCard extends StatelessWidget {
  const _HeaderStatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colorScheme.onPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.onPrimary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
