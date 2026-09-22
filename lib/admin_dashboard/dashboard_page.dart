import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';

import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Color getStatusColor(String status) {
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
        return Theme.of(_dummyContext).colorScheme.onSurfaceVariant;
    }
  }

  // Used only to keep the method structure.
  // Real default status color is handled below.
  static BuildContext get _dummyContext => throw UnimplementedError();

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Icons.hourglass_top;
      case "processing":
        return Icons.sync;
      case "shipped":
        return Icons.local_shipping;
      case "delivered":
        return Icons.check_circle;
      case "cancelled":
        return Icons.cancel;
      default:
        return Icons.help_outline;
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
                              child: const RevenueDashboardCard(),
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

                                final orderNumber = data["orderNumber"] ?? "";
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
                                          builder: (_) => AdminOrderDetailsPage(
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
                                            backgroundColor: Theme.of(context)
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
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "\$$total",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.success,
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
                                                      Icon(
                                                        getStatusIcon(status),
                                                        color: statusColorValue,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          getLocalizedStatus(
                                                            context,
                                                            status,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
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
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String collection;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          if (collection == "users") {
            count = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return data["role"] == "user" && data["emailVerified"] == true;
            }).length;
          } else {
            count = snapshot.data!.docs.length;
          }
        }

        return Card(
          elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
      },
    );
  }
}

class RevenueDashboardCard extends StatelessWidget {
  const RevenueDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
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
                  "\$${revenue.toStringAsFixed(0)}",
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';

// import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
// import 'package:ecomerce_app/admin_dashboard/product_page.dart';
// import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
// import 'package:ecomerce_app/admin_dashboard/users_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//         return Colors.orange;
//       case "processing":
//         return Colors.blue;
//       case "shipped":
//         return Colors.purple;
//       case "delivered":
//         return Colors.green;
//       case "cancelled":
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//         return Icons.hourglass_top;
//       case "processing":
//         return Icons.sync;
//       case "shipped":
//         return Icons.local_shipping;
//       case "delivered":
//         return Icons.check_circle;
//       case "cancelled":
//         return Icons.cancel;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   String getLocalizedStatus(BuildContext context, String status) {
//     final t = AppLocalizations.of(context)!;

//     switch (status.toLowerCase()) {
//       case "pending":
//         return t.pending;
//       case "processing":
//         return t.processing;
//       case "shipped":
//         return t.shipped;
//       case "delivered":
//         return t.delivered;
//       case "cancelled":
//         return t.cancelled;
//       default:
//         return status;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             Text(
//               t.welcomeBack,
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),

//             const SizedBox(height: 6),

//             Text(
//               t.dashboardSubtitle,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),

//             const SizedBox(height: 20),

//             GridView.count(
//               crossAxisCount: 2,
//               crossAxisSpacing: 15,
//               mainAxisSpacing: 15,
//               childAspectRatio: 0.8,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const RevenuePage()),
//                     );
//                   },
//                   child: const RevenueDashboardCard(),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const AdminOrdersPage(),
//                       ),
//                     );
//                   },
//                   child: DashboardCard(
//                     title: t.orders,
//                     icon: Icons.shopping_bag,
//                     color: AppColors.warning,
//                     collection: "orders",
//                   ),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const UsersPage()),
//                     );
//                   },
//                   child: DashboardCard(
//                     title: t.users,
//                     icon: Icons.people,
//                     color: AppColors.info,
//                     collection: "users",
//                   ),
//                 ),

//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ProductPage()),
//                     );
//                   },
//                   child: DashboardCard(
//                     title: t.products,
//                     icon: Icons.inventory_2,
//                     color: AppColors.secondary,
//                     collection: "products",
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             Text(t.recentOrders, style: Theme.of(context).textTheme.titleLarge),

//             const SizedBox(height: 15),

//             StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection("orders")
//                   .orderBy("createdAt", descending: true)
//                   .limit(5)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   );
//                 }

//                 final orders = snapshot.data!.docs;

//                 if (orders.isEmpty) {
//                   return Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Center(
//                         child: Text(
//                           t.noRecentOrders,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     final data = orders[index].data() as Map<String, dynamic>;

//                     final orderNumber = data["orderNumber"] ?? "";
//                     final userName = data["userName"] ?? "";
//                     final total = data["totalPrice"] ?? 0;
//                     final status = data["status"] ?? "";

//                     return Card(
//                       elevation: Theme.of(context).brightness == Brightness.dark
//                           ? 0
//                           : 2,
//                       margin: const EdgeInsets.only(bottom: 10),
//                       child: ListTile(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => AdminOrderDetailsPage(
//                                 orderId: orders[index].id,
//                               ),
//                             ),
//                           );
//                         },
//                         leading: CircleAvatar(
//                           backgroundColor: Theme.of(
//                             context,
//                           ).colorScheme.surfaceContainerHighest,
//                           child: Icon(
//                             Icons.shopping_bag,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                         title: Text(
//                           orderNumber,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         subtitle: Text(
//                           userName,
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                         trailing: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "\$$total",
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(
//                                     color: AppColors.success,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(top: 2),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: getStatusColor(
//                                   status,
//                                 ).withValues(alpha: 0.15),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     getStatusIcon(status),
//                                     color: getStatusColor(status),
//                                     size: 14,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     getLocalizedStatus(context, status),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .labelSmall
//                                         ?.copyWith(
//                                           color: getStatusColor(status),
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DashboardCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final String collection;

//   const DashboardCard({
//     super.key,
//     required this.title,
//     required this.icon,
//     required this.color,
//     required this.collection,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection(collection).snapshots(),
//       builder: (context, snapshot) {
//         int count = 0;

//         if (snapshot.hasData) {
//           if (collection == "users") {
//             count = snapshot.data!.docs.where((doc) {
//               final data = doc.data() as Map<String, dynamic>;

//               return data["role"] == "user";
//             }).length;
//           } else {
//             count = snapshot.data!.docs.length;
//           }
//         }

//         return Card(
//           elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(18),

//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: color.withValues(alpha: .15),
//                   child: Icon(icon, color: color, size: 30),
//                 ),

//                 const SizedBox(height: 12),

//                 Text(title, style: Theme.of(context).textTheme.titleMedium),

//                 const SizedBox(height: 8),

//                 Text(
//                   "$count",
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: color,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class RevenueDashboardCard extends StatelessWidget {
//   const RevenueDashboardCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection("orders")
//           .where("status", isEqualTo: "delivered")
//           .snapshots(),
//       builder: (context, snapshot) {
//         double revenue = 0;

//         if (snapshot.hasData) {
//           for (final doc in snapshot.data!.docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             revenue += (data["totalPrice"] as num?)?.toDouble() ?? 0;
//           }
//         }

//         return Card(
//           elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: AppColors.success.withValues(alpha: .15),
//                   child: const Icon(
//                     Icons.attach_money,
//                     color: AppColors.success,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(t.revenue, style: Theme.of(context).textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 Text(
//                   "\$${revenue.toStringAsFixed(0)}",
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: AppColors.success,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
