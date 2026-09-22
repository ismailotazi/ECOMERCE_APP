import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';

import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final orderRef = FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.orderDetails),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: orderRef.get(),
          builder: (context, orderSnapshot) {
            if (!orderSnapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            final orderData =
                orderSnapshot.data!.data() as Map<String, dynamic>;

            final total = orderData["totalPrice"] ?? 0;
            final status = orderData["status"] ?? "pending";

            final createdAt = orderData["createdAt"] != null
                ? (orderData["createdAt"] as Timestamp).toDate()
                : null;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final bool isDesktop = width >= 1100;
                final bool isTablet = width >= 700 && width < 1100;

                final double horizontalPadding = isDesktop
                    ? 32
                    : isTablet
                    ? 24
                    : 15;

                final double maxContentWidth = isDesktop
                    ? 1000
                    : isTablet
                    ? 850
                    : double.infinity;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.all(
                            isDesktop
                                ? 20
                                : isTablet
                                ? 18
                                : 15,
                          ),
                          elevation:
                              Theme.of(context).brightness == Brightness.dark
                              ? 0
                              : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              isDesktop
                                  ? 20
                                  : isTablet
                                  ? 18
                                  : 15,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t.orderId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      "#${1000 + orderSnapshot.data!.id.hashCode.abs() % 9000}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t.status,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(
                                          status,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            getStatusIcon(status),
                                            color: getStatusColor(status),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            getLocalizedStatus(t, status),
                                            style: TextStyle(
                                              color: getStatusColor(status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t.total,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      "\$$total",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                if (createdAt != null) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        t.date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              t.products,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: orderRef.collection("items").snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                );
                              }

                              final items = snapshot.data!.docs;

                              if (items.isEmpty) {
                                return Center(
                                  child: Text(
                                    t.noProducts,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      items[index].data()
                                          as Map<String, dynamic>;

                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                      vertical: 8,
                                    ),
                                    elevation:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? 0
                                        : 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: isDesktop
                                            ? 70
                                            : isTablet
                                            ? 65
                                            : 60,
                                        height: isDesktop
                                            ? 70
                                            : isTablet
                                            ? 65
                                            : 60,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Image.network(
                                          item["image"] ?? "",
                                          fit: BoxFit.contain,
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null) {
                                                  return child;
                                                }

                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                      ),
                                                );
                                              },
                                          errorBuilder: (_, _, _) {
                                            return Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                            );
                                          },
                                        ),
                                      ),
                                      title: Text(
                                        item["name"] ?? "",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      subtitle: Text(
                                        "${t.qty} : ${item["quantity"]}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      trailing: Text(
                                        "\$${item["price"]}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;

      case "processing":
        return Colors.blue;

      case "shipped":
        return Colors.purple;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

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

  String getLocalizedStatus(AppLocalizations t, String status) {
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
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';

// import 'package:flutter/material.dart';

// class OrderDetailsPage extends StatelessWidget {
//   final String orderId;

//   const OrderDetailsPage({super.key, required this.orderId});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;

//     final orderRef = FirebaseFirestore.instance
//         .collection("orders")
//         .doc(orderId);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.orderDetails),
//         leading: const CustomBackButton(),
//       ),
//       body: SafeArea(
//         child: FutureBuilder<DocumentSnapshot>(
//           future: orderRef.get(),
//           builder: (context, orderSnapshot) {
//             if (!orderSnapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             final orderData =
//                 orderSnapshot.data!.data() as Map<String, dynamic>;

//             final total = orderData["totalPrice"] ?? 0;
//             final status = orderData["status"] ?? "pending";

//             final createdAt = orderData["createdAt"] != null
//                 ? (orderData["createdAt"] as Timestamp).toDate()
//                 : null;

//             return Column(
//               children: [
//                 Card(
//                   margin: const EdgeInsets.all(15),
//                   elevation: Theme.of(context).brightness == Brightness.dark
//                       ? 0
//                       : 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(15),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               t.orderId,
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               "#${1000 + orderSnapshot.data!.id.hashCode.abs() % 9000}",
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               t.status,
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: getStatusColor(
//                                   status,
//                                 ).withValues(alpha: 0.15),
//                                 borderRadius: BorderRadius.circular(25),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     getStatusIcon(status),
//                                     color: getStatusColor(status),
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     getLocalizedStatus(t, status),
//                                     style: TextStyle(
//                                       color: getStatusColor(status),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               t.total,
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               "\$$total",
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(
//                                     color: AppColors.success,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                           ],
//                         ),
//                         if (createdAt != null) ...[
//                           const SizedBox(height: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 t.date,
//                                 style: Theme.of(context).textTheme.titleMedium
//                                     ?.copyWith(fontWeight: FontWeight.bold),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     "${createdAt.day}/${createdAt.month}/${createdAt.year}",
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium
//                                         ?.copyWith(fontWeight: FontWeight.w500),
//                                   ),
//                                   const SizedBox(height: 3),
//                                   Text(
//                                     "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
//                                     style: Theme.of(context).textTheme.bodySmall
//                                         ?.copyWith(
//                                           color: Theme.of(
//                                             context,
//                                           ).colorScheme.outline,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       t.products,
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: orderRef.collection("items").snapshots(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return Center(
//                           child: CircularProgressIndicator(
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         );
//                       }

//                       final items = snapshot.data!.docs;

//                       if (items.isEmpty) {
//                         return Center(
//                           child: Text(
//                             t.noProducts,
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         );
//                       }

//                       return ListView.builder(
//                         itemCount: items.length,
//                         itemBuilder: (context, index) {
//                           final item =
//                               items[index].data() as Map<String, dynamic>;

//                           return Card(
//                             margin: const EdgeInsets.symmetric(
//                               horizontal: 15,
//                               vertical: 8,
//                             ),
//                             elevation:
//                                 Theme.of(context).brightness == Brightness.dark
//                                 ? 0
//                                 : 3,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: ListTile(
//                               leading: Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.surfaceContainerHighest,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 padding: const EdgeInsets.all(8),
//                                 child: Image.network(
//                                   item["image"] ?? "",
//                                   fit: BoxFit.contain,
//                                   loadingBuilder: (context, child, progress) {
//                                     if (progress == null) return child;

//                                     return Center(
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.primary,
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (_, _, _) {
//                                     return Icon(
//                                       Icons.image_not_supported_outlined,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.outline,
//                                     );
//                                   },
//                                 ),
//                               ),
//                               title: Text(
//                                 item["name"] ?? "",
//                                 style: Theme.of(context).textTheme.titleMedium,
//                               ),

//                               subtitle: Text(
//                                 "${t.qty} : ${item["quantity"]}",
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                               trailing: Text(
//                                 "\$${item["price"]}",
//                                 style: Theme.of(context).textTheme.titleMedium
//                                     ?.copyWith(
//                                       color: AppColors.success,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

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

//   String getLocalizedStatus(AppLocalizations t, String status) {
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
// }
