import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserNotificationsPage extends StatelessWidget {
  final bool showArrowBack;
  const UserNotificationsPage({super.key, this.showArrowBack = true});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.notifications),
          leading: showArrowBack ? const CustomBackButton() : null,
          centerTitle: true,
        ),
        body: Center(child: Text(t.notifications)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(t.notifications),
        leading: showArrowBack ? const CustomBackButton() : null,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: t.markAllAsRead,
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection("notifications")
                  .where("userId", isEqualTo: user.uid)
                  .where("recipient", isEqualTo: "user")
                  .where("isRead", isEqualTo: false)
                  .get();

              final batch = FirebaseFirestore.instance.batch();

              for (final doc in snapshot.docs) {
                batch.update(doc.reference, {"isRead": true});
              }

              await batch.commit();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.allNotificationsMarkedAsRead)),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("notifications")
              .where("userId", isEqualTo: user.uid)
              .where("recipient", isEqualTo: "user")
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

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  t.noNotifications,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final notifications = snapshot.data!.docs;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final isDesktop = width >= 1100;
                final isTablet = width >= 700;

                final horizontalPadding = isDesktop
                    ? 32.0
                    : isTablet
                    ? 24.0
                    : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        24,
                      ),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final doc = notifications[index];

                        final data = doc.data() as Map<String, dynamic>;

                        final type = data["type"]?.toString() ?? "";

                        final rawTitle = data["title"]?.toString() ?? "";

                        final rawBody = data["body"]?.toString() ?? "";

                        final isRead = data["isRead"] == true;

                        String title = rawTitle;
                        String body = rawBody;

                        if (type == "order_placed") {
                          final orderNumber =
                              data["orderNumber"]?.toString() ?? "";

                          title = t.orderPlacedNotification;

                          body = t.orderPlacedNotificationBody(orderNumber);
                        }

                        if (type == "order_status") {
                          final orderNumber =
                              data["orderNumber"]?.toString() ?? "";

                          final status = data["status"]?.toString() ?? "";

                          final localizedStatus = getLocalizedStatus(
                            context,
                            status,
                          );

                          title = t.orderUpdatedNotification;

                          body = t.orderUpdatedNotificationBody(
                            orderNumber,
                            localizedStatus,
                          );
                        }

                        if (type == "product") {
                          final productName =
                              data["productName"]?.toString() ?? "";

                          title = t.newProductNotification;

                          body = t.newProductNotificationBody(productName);
                        }

                        if (type == "promotion") {
                          final productName =
                              data["productName"]?.toString() ?? "";

                          title = t.promotionNotification;

                          body = t.promotionNotificationBody(productName);
                        }

                        final Timestamp? timestamp =
                            data["createdAt"] is Timestamp
                            ? data["createdAt"] as Timestamp
                            : null;

                        final time = timestamp == null
                            ? ""
                            : "${timestamp.toDate().day}/"
                                  "${timestamp.toDate().month} "
                                  "${timestamp.toDate().hour}:"
                                  "${timestamp.toDate().minute.toString().padLeft(2, '0')}";

                        IconData icon = Icons.notifications_outlined;

                        Color iconColor = Theme.of(context).colorScheme.primary;

                        switch (type) {
                          case "order":
                          case "order_placed":
                          case "order_status":
                            icon = Icons.shopping_bag_outlined;
                            iconColor = Theme.of(context).colorScheme.primary;
                            break;

                          case "product":
                            icon = Icons.inventory_2_outlined;
                            iconColor = AppColors.success;
                            break;

                          case "promotion":
                            icon = Icons.local_offer_outlined;
                            iconColor = Theme.of(context).colorScheme.secondary;
                            break;

                          case "warning":
                            icon = Icons.warning_amber_outlined;
                            iconColor = Theme.of(context).colorScheme.error;
                            break;
                        }

                        return _buildNotificationCard(
                          context: context,
                          doc: doc,
                          data: data,
                          title: title,
                          body: body,
                          time: time,
                          icon: icon,
                          iconColor: iconColor,
                          isRead: isRead,
                          t: t,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        );
                      },
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

  Widget _buildNotificationCard({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
    required Map<String, dynamic> data,
    required String title,
    required String body,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isRead,
    required AppLocalizations t,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
          size: 26,
        ),
      ),
      onDismissed: (_) async {
        await doc.reference.delete();

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.notificationDeleted)));
        }
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          if (!isRead) {
            await doc.reference.update({"isRead": true});
          }

          final orderId = data["orderId"]?.toString() ?? "";

          final productId = data["productId"]?.toString() ?? "";

          if ((typeIsOrder(data["type"])) && orderId.isNotEmpty) {
            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(orderId: orderId),
              ),
            );

            return;
          }

          final type = data["type"]?.toString() ?? "";

          if ((type == "product" || type == "promotion") &&
              productId.isNotEmpty) {
            final productDoc = await FirebaseFirestore.instance
                .collection("products")
                .doc(productId)
                .get();

            if (!productDoc.exists) return;

            final productData = productDoc.data()!;

            productData["id"] = productDoc.id;

            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetails(data: productData)),
            );
          }
        },
        child: Card(
          color: isRead
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          margin: const EdgeInsets.only(bottom: 14),
          elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: !isRead
                ? BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.18),
                  )
                : BorderSide.none,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isDesktop
                  ? 18
                  : isTablet
                  ? 16
                  : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isDesktop
                      ? 52
                      : isTablet
                      ? 50
                      : 46,
                  height: isDesktop
                      ? 52
                      : isTablet
                      ? 50
                      : 46,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isDesktop ? 25 : 23,
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
                              title,
                              maxLines: isDesktop ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                  ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          if (time.isNotEmpty)
                            Text(
                              time,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        body,
                        maxLines: isDesktop ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool typeIsOrder(dynamic value) {
  final type = value?.toString() ?? "";

  return type == "order" || type == "order_placed" || type == "order_status";
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/user_dashboard/item_details.dart';
// import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class UserNotificationsPage extends StatelessWidget {
//   const UserNotificationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(t.notifications),
//           leading: const CustomBackButton(),
//           centerTitle: true,
//         ),
//         body: Center(child: Text(t.somethingWentWrong)),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.notifications),
//         leading: const CustomBackButton(),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             tooltip: t.markAllAsRead,
//             onPressed: () async {
//               final snapshot = await FirebaseFirestore.instance
//                   .collection("notifications")
//                   .where("userId", isEqualTo: user.uid)
//                   .where("recipient", isEqualTo: "user")
//                   .where("isRead", isEqualTo: false)
//                   .get();

//               final batch = FirebaseFirestore.instance.batch();

//               for (final doc in snapshot.docs) {
//                 batch.update(doc.reference, {"isRead": true});
//               }

//               await batch.commit();

//               if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(t.allNotificationsMarkedAsRead)),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("notifications")
//               .where("userId", isEqualTo: user.uid)
//               .where("recipient", isEqualTo: "user")
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

//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(
//                   snapshot.error.toString(),
//                   textAlign: TextAlign.center,
//                 ),
//               );
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   t.noNotifications,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final notifications = snapshot.data!.docs;

//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final doc = notifications[index];
//                 final data = doc.data() as Map<String, dynamic>;

//                 final type = data["type"]?.toString() ?? "";
//                 final rawTitle = data["title"]?.toString() ?? "";
//                 final rawBody = data["body"]?.toString() ?? "";
//                 final isRead = data["isRead"] == true;

//                 String title = rawTitle;
//                 String body = rawBody;

//                 if (type == "order_placed") {
//                   final orderNumber = data["orderNumber"]?.toString() ?? "";

//                   title = t.orderPlacedNotification;
//                   body = t.orderPlacedNotificationBody(orderNumber);
//                 }

//                 if (type == "order_status") {
//                   final orderNumber = data["orderNumber"]?.toString() ?? "";
//                   final status = data["status"]?.toString() ?? "";

//                   final localizedStatus = getLocalizedStatus(context, status);

//                   title = t.orderUpdatedNotification;
//                   body = t.orderUpdatedNotificationBody(
//                     orderNumber,
//                     localizedStatus,
//                   );
//                 }

//                 if (type == "product") {
//                   final productName = data["productName"]?.toString() ?? "";

//                   title = t.newProductNotification;
//                   body = t.newProductNotificationBody(productName);
//                 }
//                 if (type == "promotion") {
//                   final productName = data["productName"]?.toString() ?? "";

//                   title = t.promotionNotification;
//                   body = t.promotionNotificationBody(productName);
//                 }
//                 final Timestamp? timestamp = data["createdAt"] is Timestamp
//                     ? data["createdAt"] as Timestamp
//                     : null;

//                 final time = timestamp == null
//                     ? ""
//                     : "${timestamp.toDate().day}/"
//                           "${timestamp.toDate().month} "
//                           "${timestamp.toDate().hour}:"
//                           "${timestamp.toDate().minute.toString().padLeft(2, '0')}";

//                 IconData icon = Icons.notifications;
//                 Color iconColor = Colors.grey;

//                 switch (type) {
//                   case "order":
//                     icon = Icons.shopping_bag;
//                     iconColor = Colors.deepOrange;
//                     break;

//                   case "product":
//                     icon = Icons.inventory;
//                     iconColor = Colors.green;
//                     break;

//                   case "promotion":
//                     icon = Icons.local_offer;
//                     iconColor = Colors.orange;
//                     break;

//                   case "warning":
//                     icon = Icons.warning_amber;
//                     iconColor = Colors.red;
//                     break;
//                 }

//                 return Dismissible(
//                   key: Key(doc.id),
//                   direction: DismissDirection.endToStart,
//                   background: Container(
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.only(right: 20),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.error,
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     child: Icon(
//                       Icons.delete,
//                       color: Theme.of(context).colorScheme.onError,
//                     ),
//                   ),
//                   onDismissed: (_) async {
//                     await doc.reference.delete();

//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(t.notificationDeleted)),
//                       );
//                     }
//                   },
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(18),
//                     onTap: () async {
//                       if (!isRead) {
//                         await doc.reference.update({"isRead": true});
//                       }

//                       final orderId = data["orderId"]?.toString() ?? "";
//                       final productId = data["productId"]?.toString() ?? "";

//                       if ((type == "order" ||
//                               type == "order_placed" ||
//                               type == "order_status") &&
//                           orderId.isNotEmpty) {
//                         if (!context.mounted) return;

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => OrderDetailsPage(orderId: orderId),
//                           ),
//                         );

//                         return;
//                       }

//                       if ((type == "product" || type == "promotion") &&
//                           productId.isNotEmpty) {
//                         final productDoc = await FirebaseFirestore.instance
//                             .collection("products")
//                             .doc(productId)
//                             .get();

//                         if (!productDoc.exists) return;

//                         final productData = productDoc.data()!;
//                         productData["id"] = productDoc.id;

//                         if (!context.mounted) return;

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ItemDetails(data: productData),
//                           ),
//                         );
//                       }
//                     },
//                     child: Card(
//                       color: isRead
//                           ? Theme.of(context).colorScheme.surface
//                           : Theme.of(
//                               context,
//                             ).colorScheme.primary.withValues(alpha: 0.08),
//                       margin: const EdgeInsets.only(bottom: 14),
//                       elevation: Theme.of(context).brightness == Brightness.dark
//                           ? 0
//                           : 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           radius: 24,
//                           backgroundColor: iconColor.withValues(alpha: .12),
//                           child: Icon(icon, color: iconColor),
//                         ),
//                         title: Text(
//                           title,
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Padding(
//                           padding: const EdgeInsets.only(top: 5),
//                           child: Text(
//                             body,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ),
//                         trailing: Text(
//                           time,
//                           style: Theme.of(
//                             context,
//                           ).textTheme.bodyMedium?.copyWith(fontSize: 12),
//                         ),
//                       ),
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

// String getLocalizedStatus(BuildContext context, String status) {
//   final t = AppLocalizations.of(context)!;

//   switch (status.toLowerCase()) {
//     case "pending":
//       return t.pending;
//     case "processing":
//       return t.processing;
//     case "shipped":
//       return t.shipped;
//     case "delivered":
//       return t.delivered;
//     case "completed":
//       return t.completed;
//     case "cancelled":
//     case "canceled":
//       return t.cancelled;
//     default:
//       return status;
//   }
// }
