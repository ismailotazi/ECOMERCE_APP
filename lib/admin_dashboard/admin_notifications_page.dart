import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  String getLocalizedNotificationTitle(
    BuildContext context,
    String type,
    String title,
  ) {
    final t = AppLocalizations.of(context)!;

    switch (type) {
      case "order":
        return t.newOrder;
      case "user":
        return t.newUser;
      case "product":
        return t.newProduct;
      case "warning":
        return t.warning;
      default:
        return title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notifications),
        leading: const CustomBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: t.markAllAsRead,
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection("notifications")
                  .where("recipient", isEqualTo: "admin")
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
              .where("recipient", isEqualTo: "admin")
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
                child: Text(
                  t.noNotifications,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 16,
                    vertical: 16,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    final type = data["type"] ?? "";
                    final originalTitle = data["title"] ?? "";

                    final title = getLocalizedNotificationTitle(
                      context,
                      type,
                      originalTitle,
                    );

                    String body = data["body"]?.toString() ?? "";

                    if (type == "order") {
                      final userName = data["userName"]?.toString() ?? "";
                      final orderNumber = data["orderNumber"]?.toString() ?? "";

                      body = t.newOrderNotificationBody(userName, orderNumber);
                    }

                    final orderId = data["orderId"]?.toString() ?? "";

                    final isRead = data["isRead"] ?? false;

                    IconData icon = Icons.notifications;
                    Color color = Colors.grey;

                    switch (type) {
                      case "order":
                        icon = Icons.shopping_bag;
                        color = Colors.deepOrange;
                        break;

                      case "user":
                        icon = Icons.person_add;
                        color = Colors.blue;
                        break;

                      case "product":
                        icon = Icons.inventory;
                        color = Colors.green;
                        break;

                      case "warning":
                        icon = Icons.warning_amber;
                        color = Colors.red;
                        break;
                    }

                    final createdAt = data["createdAt"];

                    final time = createdAt is Timestamp
                        ? "${createdAt.toDate().day}/${createdAt.toDate().month} "
                              "${createdAt.toDate().hour}:"
                              "${createdAt.toDate().minute.toString().padLeft(2, '0')}"
                        : "";

                    return Dismissible(
                      key: Key(snapshot.data!.docs[index].id),
                      direction: DismissDirection.endToStart,

                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),

                      onDismissed: (_) async {
                        await snapshot.data!.docs[index].reference.delete();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.notificationDeleted)),
                          );
                        }
                      },

                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final doc = snapshot.data!.docs[index];

                          debugPrint("BEFORE: ${doc.id}");

                          await doc.reference.update({"isRead": true});

                          debugPrint("AFTER UPDATE: ${doc.id}");

                          final check = await doc.reference.get();

                          debugPrint("EXISTS AFTER UPDATE: ${check.exists}");
                          debugPrint("DATA AFTER UPDATE: ${check.data()}");

                          if (!context.mounted) return;

                          if (type == "order") {
                            if (orderId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t.somethingWentWrong)),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AdminOrderDetailsPage(orderId: orderId),
                              ),
                            );
                          }
                        },
                        child: _notificationCard(
                          context,
                          icon: icon,
                          iconColor: color,
                          title: title,
                          subtitle: body,
                          time: time,
                          isRead: isRead,
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

  Widget _notificationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return Card(
      color: isRead
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: iconColor.withValues(alpha: .12),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class AdminNotificationsPage extends StatelessWidget {
//   const AdminNotificationsPage({super.key});
//   String getLocalizedNotificationTitle(
//     BuildContext context,
//     String type,
//     String title,
//   ) {
//     final t = AppLocalizations.of(context)!;

//     switch (type) {
//       case "order":
//         return t.newOrder;
//       case "user":
//         return t.newUser;
//       case "product":
//         return t.newProduct;
//       case "warning":
//         return t.warning;
//       default:
//         return title;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.notifications),
//         leading: const CustomBackButton(),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.done_all),
//             tooltip: t.markAllAsRead,
//             onPressed: () async {
//               final snapshot = await FirebaseFirestore.instance
//                   .collection("notifications")
//                   .where("recipient", isEqualTo: "admin")
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
//               .where("recipient", isEqualTo: "admin")
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
//                   t.noNotifications,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: snapshot.data!.docs.length,
//               itemBuilder: (context, index) {
//                 final data =
//                     snapshot.data!.docs[index].data() as Map<String, dynamic>;

//                 final type = data["type"] ?? "";
//                 final originalTitle = data["title"] ?? "";
//                 final title = getLocalizedNotificationTitle(
//                   context,
//                   type,
//                   originalTitle,
//                 );
//                 String body = data["body"]?.toString() ?? "";

//                 if (type == "order") {
//                   final userName = data["userName"]?.toString() ?? "";
//                   final orderNumber = data["orderNumber"]?.toString() ?? "";

//                   body = t.newOrderNotificationBody(userName, orderNumber);
//                 }
//                 final orderId = data["orderId"]?.toString() ?? "";

//                 final isRead = data["isRead"] ?? false;

//                 IconData icon = Icons.notifications;
//                 Color color = Colors.grey;

//                 switch (type) {
//                   case "order":
//                     icon = Icons.shopping_bag;
//                     color = Colors.deepOrange;
//                     break;

//                   case "user":
//                     icon = Icons.person_add;
//                     color = Colors.blue;
//                     break;

//                   case "product":
//                     icon = Icons.inventory;
//                     color = Colors.green;
//                     break;

//                   case "warning":
//                     icon = Icons.warning_amber;
//                     color = Colors.red;
//                     break;
//                 }

//                 final createdAt = data["createdAt"];

//                 final time = createdAt is Timestamp
//                     ? "${createdAt.toDate().day}/${createdAt.toDate().month} "
//                           "${createdAt.toDate().hour}:"
//                           "${createdAt.toDate().minute.toString().padLeft(2, '0')}"
//                     : "";
//                 return Dismissible(
//                   key: Key(snapshot.data!.docs[index].id),
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
//                     await snapshot.data!.docs[index].reference.delete();

//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(t.notificationDeleted)),
//                       );
//                     }
//                   },

//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(18),
//                     onTap: () async {
//                       final doc = snapshot.data!.docs[index];

//                       debugPrint("BEFORE: ${doc.id}");

//                       await doc.reference.update({"isRead": true});

//                       debugPrint("AFTER UPDATE: ${doc.id}");

//                       final check = await doc.reference.get();

//                       debugPrint("EXISTS AFTER UPDATE: ${check.exists}");
//                       debugPrint("DATA AFTER UPDATE: ${check.data()}");

//                       if (!context.mounted) return;

//                       if (type == "order") {
//                         if (orderId.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text(t.somethingWentWrong)),
//                           );
//                           return;
//                         }

//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 AdminOrderDetailsPage(orderId: orderId),
//                           ),
//                         );
//                       }
//                     },
//                     child: _notificationCard(
//                       context,
//                       icon: icon,
//                       iconColor: color,
//                       title: title,
//                       subtitle: body,
//                       time: time,
//                       isRead: isRead,
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

//   Widget _notificationCard(
//     BuildContext context, {
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required String time,
//     required bool isRead,
//   }) {
//     return Card(
//       color: isRead
//           ? Theme.of(context).colorScheme.surface
//           : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
//       margin: const EdgeInsets.only(bottom: 14),
//       elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 24,
//           backgroundColor: iconColor.withValues(alpha: .12),
//           child: Icon(icon, color: iconColor),
//         ),
//         title: Text(
//           title,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 5),
//           child: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
//         ),
//         trailing: Text(
//           time,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
//         ),
//       ),
//     );
//   }
// }
