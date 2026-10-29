import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';

import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';

import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  FaIconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return FontAwesomeIcons.hourglassHalf;

      case "processing":
        return FontAwesomeIcons.gear;

      case "shipped":
        return FontAwesomeIcons.truck;

      case "delivered":
        return FontAwesomeIcons.circleCheck;

      case "cancelled":
        return FontAwesomeIcons.circleXmark;

      default:
        return FontAwesomeIcons.circleQuestion;
    }
  }

  String getLocalizedStatus(BuildContext context, String status) {
    final t = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case "pending":
        return t.pending;
      case "processing":
        return t.processing;
      case "shipped":
        return t.shipped;
      case "delivered":
        return t.delivered;
      case "cancelled":
        return t.cancelled;
      default:
        return status;
    }
  }

  Color statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return AppColors.warning;
      case "processing":
        return AppColors.info;
      case "shipped":
        return AppColors.secondary;
      case "delivered":
        return AppColors.success;
      case "cancelled":
        return AppColors.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Scaffold(body: Center(child: Text(t.somethingWentWrong)));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final String? storeId = userData?["storeId"]?.toString();
        if (storeId == null || storeId.isEmpty) {
          return Scaffold(body: Center(child: Text(t.somethingWentWrong)));
        }

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 16,
                    vertical: 20,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 1400 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.welcomeBack,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              t.dashboardSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // DASHBOARD CARDS
                            // ==================================================
                            GridView.count(
                              crossAxisCount: isDesktop ? 4 : 2,
                              crossAxisSpacing: isDesktop ? 20 : 15,
                              mainAxisSpacing: isDesktop ? 20 : 15,
                              childAspectRatio: isDesktop ? 1.5 : 0.8,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RevenuePage(),
                                      ),
                                    );
                                  },
                                  child: RevenueDashboardCard(storeId: storeId),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AdminOrdersPage(),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    title: t.orders,
                                    icon: Icons.shopping_bag,
                                    color: AppColors.warning,
                                    collection: "orders",
                                    storeId: storeId,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const UsersPage(),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    title: t.users,
                                    icon: Icons.people,
                                    color: AppColors.info,
                                    collection: "users",
                                    storeId: storeId,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProductPage(),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    title: t.products,
                                    icon: Icons.inventory_2,
                                    color: AppColors.secondary,
                                    collection: "products",
                                    storeId: storeId,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            Text(
                              t.recentOrders,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 15),

                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("orders")
                                  .where("storeId", isEqualTo: storeId)
                                  .orderBy("createdAt", descending: true)
                                  .limit(5)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }

                                final orders = snapshot.data!.docs;

                                if (orders.isEmpty) {
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Center(
                                        child: Text(
                                          t.noRecentOrders,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final data =
                                        orders[index].data()
                                            as Map<String, dynamic>;

                                    final orderNumber =
                                        data["orderNumber"] ?? "";
                                    final userName = data["userName"] ?? "";
                                    final total = data["totalPrice"] ?? 0;
                                    final status = data["status"] ?? "";

                                    final statusColorValue = statusColor(
                                      context,
                                      status,
                                    );

                                    return Card(
                                      elevation:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0
                                          : 2,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AdminOrderDetailsPage(
                                                    orderId: orders[index].id,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.shopping_bag,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                              ),

                                              const SizedBox(width: 14),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      orderNumber.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      userName.toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Theme.of(context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              Flexible(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "$total ${t.currencySymbol}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color: AppColors
                                                                .success,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),

                                                    const SizedBox(height: 5),

                                                    Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                            maxWidth: 180,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 9,
                                                            vertical: 5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: statusColorValue
                                                            .withValues(
                                                              alpha: 0.15,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          FaIcon(
                                                            getStatusIcon(
                                                              status,
                                                            ),
                                                            color:
                                                                statusColorValue,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              getLocalizedStatus(
                                                                context,
                                                                status,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .labelSmall
                                                                  ?.copyWith(
                                                                    color:
                                                                        statusColorValue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
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
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String collection;
  final String storeId;
  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.collection,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    if (collection == "users") {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "user")
            .where("emailVerified", isEqualTo: true)
            .where("storeId", isEqualTo: storeId)
            .snapshots(),
        builder: (context, legacySnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("role", isEqualTo: "user")
                .where("emailVerified", isEqualTo: true)
                .where("stores.$storeId.isActive", isEqualTo: true)
                .snapshots(),
            builder: (context, multiStoreSnapshot) {
              int count = 0;

              if (legacySnapshot.hasData && multiStoreSnapshot.hasData) {
                final users = <String, QueryDocumentSnapshot>{};

                for (final doc in legacySnapshot.data!.docs) {
                  users[doc.id] = doc;
                }

                for (final doc in multiStoreSnapshot.data!.docs) {
                  users[doc.id] = doc;
                }

                count = users.length;
              }

              if (legacySnapshot.hasError || multiStoreSnapshot.hasError) {
                return const Card(
                  child: Center(child: Icon(Icons.error_outline)),
                );
              }

              return _buildDashboardCard(context, count);
            },
          );
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where("storeId", isEqualTo: storeId)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        if (snapshot.hasError) {
          return const Card(child: Center(child: Icon(Icons.error_outline)));
        }

        return _buildDashboardCard(context, count);
      },
    );
  }

  Widget _buildDashboardCard(BuildContext context, int count) {
    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueDashboardCard extends StatelessWidget {
  final String storeId;

  const RevenueDashboardCard({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .where("storeId", isEqualTo: storeId)
          .where("status", isEqualTo: "delivered")
          .snapshots(),
      builder: (context, snapshot) {
        double revenue = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            revenue += (data["totalPrice"] as num?)?.toDouble() ?? 0;
          }
        }

        return Card(
          elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.success.withValues(alpha: .15),
                  child: const Icon(
                    Icons.attach_money,
                    color: AppColors.success,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 12),

                Flexible(
                  child: Text(
                    t.revenue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${revenue.toStringAsFixed(0)} ${t.currencySymbol}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
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
