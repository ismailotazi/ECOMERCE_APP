import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
import 'package:flutter/material.dart';

class UserOrdersPage extends StatelessWidget {
  final String userId;

  const UserOrdersPage({super.key, required this.userId});

  String formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    return "-";
  }

  Color statusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case "pending":
        return AppColors.warning;
      case "processing":
        return AppColors.info;
      case "shipped":
        return colorScheme.secondary;
      case "delivered":
      case "completed":
        return AppColors.success;
      case "cancelled":
      case "canceled":
        return AppColors.error;
      default:
        return colorScheme.outline;
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
      case "completed":
        return t.completed;
      case "cancelled":
      case "canceled":
        return t.cancelled;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(t.usersOrders),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            if (snapshot.hasError) {
              final t = AppLocalizations.of(context)!;
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  child: Text(
                    t.unableToLoadOrders,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isDesktop ? 88 : 80,
                        height: isDesktop ? 88 : 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: isDesktop ? 44 : 40,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 20 : 18),
                      Text(
                        t.noOrdersFound,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.userHasNoOrders,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final orders = [...snapshot.data!.docs];

            orders.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;

              final aDate = aData["createdAt"];
              final bDate = bData["createdAt"];

              if (aDate is Timestamp && bDate is Timestamp) {
                return bDate.compareTo(aDate);
              }

              return 0;
            });

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: isDesktop ? 24 : 20,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final data = order.data() as Map<String, dynamic>;

                    final orderNumber =
                        data["orderNumber"]?.toString() ?? order.id;

                    final status = data["status"]?.toString() ?? "Pending";

                    final total = data["totalPrice"];

                    final totalPrice = total is num
                        ? total.toDouble()
                        : double.tryParse(total?.toString() ?? "0") ?? 0;

                    final createdAt = data["createdAt"];

                    final products = data["products"];

                    int productCount = 0;

                    if (products is List) {
                      productCount = products.length;
                    }

                    final statusColorValue = statusColor(context, status);

                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 14),
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 20 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: isDesktop ? 52 : 48,
                                  height: isDesktop ? 52 : 48,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.orderNumber(orderNumber),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatDate(createdAt),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColorValue.withValues(
                                      alpha: .12,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    getLocalizedStatus(context, status),
                                    style: TextStyle(
                                      color: statusColorValue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Divider(color: colorScheme.outlineVariant),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  t.products,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Text(
                                  productCount.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  Icons.payments_outlined,
                                  size: 20,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  t.total,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Text(
                                  "\$${totalPrice.toStringAsFixed(2)}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailsPage(orderId: order.id),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined),
                                label: Text(t.viewDetails),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(color: colorScheme.primary),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
// import 'package:flutter/material.dart';

// class UserOrdersPage extends StatelessWidget {
//   final String userId;

//   const UserOrdersPage({super.key, required this.userId});

//   String formatDate(dynamic value) {
//     if (value is Timestamp) {
//       final date = value.toDate();

//       return "${date.day.toString().padLeft(2, '0')}/"
//           "${date.month.toString().padLeft(2, '0')}/"
//           "${date.year}";
//     }

//     return "-";
//   }

//   Color statusColor(BuildContext context, String status) {
//     final colorScheme = Theme.of(context).colorScheme;

//     switch (status.toLowerCase()) {
//       case "pending":
//         return AppColors.warning;
//       case "processing":
//         return AppColors.info;
//       case "shipped":
//         return colorScheme.secondary;
//       case "delivered":
//       case "completed":
//         return AppColors.success;
//       case "cancelled":
//       case "canceled":
//         return AppColors.error;
//       default:
//         return colorScheme.outline;
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
//       case "completed":
//         return t.completed;
//       case "cancelled":
//       case "canceled":
//         return t.cancelled;
//       default:
//         return status;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         leading: const CustomBackButton(),
//         title: Text(t.usersOrders),
//       ),

//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("orders")
//               .where("userId", isEqualTo: userId)
//               .snapshots(),

//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(color: colorScheme.primary),
//               );
//             }

//             if (snapshot.hasError) {
//               final t = AppLocalizations.of(context)!;
//               return Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(24),
//                   child: Text(
//                     t.unableToLoadOrders,
//                     style: theme.textTheme.bodyLarge,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               );
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: colorScheme.primaryContainer,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.shopping_bag_outlined,
//                           size: 40,
//                           color: colorScheme.onPrimaryContainer,
//                         ),
//                       ),

//                       const SizedBox(height: 18),

//                       Text(
//                         t.noOrdersFound,
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       Text(
//                         t.userHasNoOrders,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }

//             final orders = [...snapshot.data!.docs];

//             orders.sort((a, b) {
//               final aData = a.data() as Map<String, dynamic>;
//               final bData = b.data() as Map<String, dynamic>;

//               final aDate = aData["createdAt"];
//               final bDate = bData["createdAt"];

//               if (aDate is Timestamp && bDate is Timestamp) {
//                 return bDate.compareTo(aDate);
//               }

//               return 0;
//             });

//             return ListView.builder(
//               padding: const EdgeInsets.all(20),
//               itemCount: orders.length,
//               itemBuilder: (context, index) {
//                 final order = orders[index];
//                 final data = order.data() as Map<String, dynamic>;

//                 final orderNumber = data["orderNumber"]?.toString() ?? order.id;

//                 final status = data["status"]?.toString() ?? "Pending";

//                 final total = data["totalPrice"];

//                 final totalPrice = total is num
//                     ? total.toDouble()
//                     : double.tryParse(total?.toString() ?? "0") ?? 0;

//                 final createdAt = data["createdAt"];

//                 final products = data["products"];

//                 int productCount = 0;

//                 if (products is List) {
//                   productCount = products.length;
//                 }

//                 final statusColorValue = statusColor(context, status);

//                 return Card(
//                   elevation: 0,
//                   margin: const EdgeInsets.only(bottom: 14),
//                   color: colorScheme.surface,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide(color: colorScheme.outlineVariant),
//                   ),

//                   child: Padding(
//                     padding: const EdgeInsets.all(18),

//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,

//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 48,
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: colorScheme.primaryContainer,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Icon(
//                                 Icons.shopping_bag_outlined,
//                                 color: colorScheme.onPrimaryContainer,
//                               ),
//                             ),

//                             const SizedBox(width: 14),

//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     t.orderNumber(orderNumber),
//                                     style: theme.textTheme.titleMedium
//                                         ?.copyWith(fontWeight: FontWeight.bold),
//                                   ),

//                                   const SizedBox(height: 4),

//                                   Text(
//                                     formatDate(createdAt),
//                                     style: theme.textTheme.bodySmall?.copyWith(
//                                       color: colorScheme.onSurfaceVariant,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 7,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: statusColorValue.withValues(alpha: .12),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Text(
//                                 getLocalizedStatus(context, status),
//                                 style: TextStyle(
//                                   color: statusColorValue,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 18),

//                         Divider(color: colorScheme.outlineVariant),

//                         const SizedBox(height: 12),

//                         Row(
//                           children: [
//                             Icon(
//                               Icons.inventory_2_outlined,
//                               size: 20,
//                               color: colorScheme.onSurfaceVariant,
//                             ),

//                             const SizedBox(width: 10),

//                             Text(t.products, style: theme.textTheme.bodyMedium),

//                             const Spacer(),

//                             Text(
//                               productCount.toString(),
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 14),

//                         Row(
//                           children: [
//                             Icon(
//                               Icons.payments_outlined,
//                               size: 20,
//                               color: AppColors.success,
//                             ),

//                             const SizedBox(width: 10),

//                             Text(t.total, style: theme.textTheme.bodyMedium),

//                             const Spacer(),

//                             Text(
//                               "\$${totalPrice.toStringAsFixed(2)}",
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.success,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         SizedBox(
//                           width: double.infinity,
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       OrderDetailsPage(orderId: order.id),
//                                 ),
//                               );
//                             },

//                             icon: const Icon(Icons.visibility_outlined),

//                             label: Text(t.viewDetails),

//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: colorScheme.primary,
//                               side: BorderSide(color: colorScheme.primary),
//                               padding: const EdgeInsets.symmetric(vertical: 13),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
