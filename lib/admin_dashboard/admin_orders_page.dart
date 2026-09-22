import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 600 && screenWidth < 1100;

    final horizontalPadding = isDesktop
        ? 32.0
        : isTablet
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(t.orders),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t.noOrders,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }

            final orders = snapshot.data!.docs;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    100,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    final data = order.data() as Map<String, dynamic>;

                    final status = data["status"] ?? t.pending;
                    final total = data["totalPrice"] ?? 0;
                    final items = data["itemsCount"] ?? 0;
                    final number =
                        data["orderNumber"] ?? order.id.substring(0, 6);
                    final userName = data["userName"] ?? t.unknownUser;
                    final email = data["email"] ?? "";

                    DateTime? createdAt;

                    if (data["createdAt"] != null) {
                      createdAt = (data["createdAt"] as Timestamp).toDate();
                    }

                    final statusColor = orderStatusColor(context, status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminOrderDetailsPage(orderId: order.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(
                            isDesktop
                                ? 20
                                : isTablet
                                ? 18
                                : 16,
                          ),
                          child: isDesktop
                              ? _buildDesktopOrder(
                                  context: context,
                                  number: number,
                                  userName: userName,
                                  email: email,
                                  status: status,
                                  statusColor: statusColor,
                                  items: items,
                                  total: total,
                                  createdAt: createdAt,
                                  t: t,
                                )
                              : _buildMobileOrder(
                                  context: context,
                                  number: number,
                                  userName: userName,
                                  email: email,
                                  status: status,
                                  statusColor: statusColor,
                                  items: items,
                                  total: total,
                                  createdAt: createdAt,
                                  t: t,
                                  isTablet: isTablet,
                                ),
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

  Widget _buildDesktopOrder({
    required BuildContext context,
    required dynamic number,
    required dynamic userName,
    required dynamic email,
    required String status,
    required Color statusColor,
    required dynamic items,
    required dynamic total,
    required DateTime? createdAt,
    required AppLocalizations t,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.shopping_bag_rounded, color: statusColor, size: 28),
        ),

        const SizedBox(width: 18),

        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                userName.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (email.toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  email.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedOrderStatus(context, status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "$items ${items == 1 ? t.product : t.products}",
                style: theme.textTheme.bodyMedium,
              ),

              if (createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                  "${createdAt.hour.toString().padLeft(2, '0')}:"
                  "${createdAt.minute.toString().padLeft(2, '0')}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 20),

        Text(
          "\$$total",
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(width: 12),

        Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
      ],
    );
  }

  Widget _buildMobileOrder({
    required BuildContext context,
    required dynamic number,
    required dynamic userName,
    required dynamic email,
    required String status,
    required Color statusColor,
    required dynamic items,
    required dynamic total,
    required DateTime? createdAt,
    required AppLocalizations t,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isTablet ? 56 : 52,
          height: isTablet ? 56 : 52,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            color: statusColor,
            size: isTablet ? 27 : 25,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      number.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "\$$total",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                userName.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (email.toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  email.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 9),

              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    localizedOrderStatus(context, status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "$items ${items == 1 ? t.product : t.products}",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              if (createdAt != null) ...[
                const SizedBox(height: 5),
                Text(
                  "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                  "${createdAt.hour.toString().padLeft(2, '0')}:"
                  "${createdAt.minute.toString().padLeft(2, '0')}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 6),

        Padding(
          padding: const EdgeInsets.only(top: 17),
          child: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ],
    );
  }

  String localizedOrderStatus(BuildContext context, String status) {
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
        return status.toUpperCase();
    }
  }

  Color orderStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return AppColors.warning;

      case "processing":
        return AppColors.info;

      case "shipped":
        return AppColors.primary;

      case "delivered":
        return AppColors.success;

      case "cancelled":
        return AppColors.error;

      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class AdminOrdersPage extends StatelessWidget {
//   const AdminOrdersPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         leading: const CustomBackButton(),
//         title: Text(t.orders),
//       ),
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("orders")
//               .orderBy("createdAt", descending: true)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   t.noOrders,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final orders = snapshot.data!.docs;

//             return ListView.builder(
//               itemCount: orders.length,
//               itemBuilder: (context, index) {
//                 final order = orders[index];

//                 final data = order.data() as Map<String, dynamic>;

//                 final status = data["status"] ?? t.pending;
//                 final total = data["totalPrice"] ?? 0;
//                 final items = data["itemsCount"] ?? 0;
//                 final number = data["orderNumber"] ?? order.id.substring(0, 6);
//                 final userName = data["userName"] ?? t.unknownUser;
//                 final email = data["email"] ?? "";
//                 DateTime? createdAt;

//                 if (data["createdAt"] != null) {
//                   createdAt = (data["createdAt"] as Timestamp).toDate();
//                 }

//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: orderStatusColor(context, status),
//                       child: const Icon(
//                         Icons.shopping_bag,
//                         color: AppColors.white,
//                       ),
//                     ),

//                     title: Text(number),

//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           userName,
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),

//                         Text(
//                           email,
//                           style: Theme.of(context).textTheme.bodySmall
//                               ?.copyWith(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSurfaceVariant,
//                                 fontSize: 12,
//                               ),
//                         ),

//                         const SizedBox(height: 6),

//                         Text(
//                           localizedOrderStatus(context, status),
//                           style: TextStyle(
//                             color: orderStatusColor(context, status),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         Text("$items ${items == 1 ? t.product : t.products}"),

//                         if (createdAt != null)
//                           Text(
//                             "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
//                             "${createdAt.hour.toString().padLeft(2, '0')}:"
//                             "${createdAt.minute.toString().padLeft(2, '0')}",
//                             style: TextStyle(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                       ],
//                     ),

//                     trailing: Text(
//                       "\$$total",
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: AppColors.success,
//                       ),
//                     ),

//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               AdminOrderDetailsPage(orderId: order.id),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   String localizedOrderStatus(BuildContext context, String status) {
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
//         return status.toUpperCase();
//     }
//   }

//   Color orderStatusColor(BuildContext context, String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//         return AppColors.warning;

//       case "processing":
//         return AppColors.info;

//       case "shipped":
//         return AppColors.primary;

//       case "delivered":
//         return AppColors.success;

//       case "cancelled":
//         return AppColors.error;

//       default:
//         return Theme.of(context).colorScheme.onSurfaceVariant;
//     }
//   }
// }
