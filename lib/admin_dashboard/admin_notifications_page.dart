import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';
import 'package:ecomerce_app/admin_dashboard/user_details_page.dart';
import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection("notifications")
                  .where("isRead", isEqualTo: false)
                  .get();

              final batch = FirebaseFirestore.instance.batch();

              for (final doc in snapshot.docs) {
                batch.update(doc.reference, {"isRead": true});
              }

              await batch.commit();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All notifications marked as read"),
                  ),
                );
              }
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("notifications")
                .where("isRead", isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final unread = snapshot.data?.docs.length ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications),

                    if (unread > 0)
                      Positioned(
                        right: 0,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unread.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              final type = data["type"] ?? "";
              final title = data["title"] ?? "";
              final body = data["body"] ?? "";
              final orderId = data["orderId"];
              final userId = data["userId"];
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

              final Timestamp? ts = data["createdAt"];

              final time = ts == null
                  ? ""
                  : "${ts.toDate().day}/${ts.toDate().month} ${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}";

              return Dismissible(
                key: Key(snapshot.data!.docs[index].id),
                direction: DismissDirection.endToStart,

                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                onDismissed: (_) async {
                  await snapshot.data!.docs[index].reference.delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notification deleted")),
                  );
                },

                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    if (!isRead) {
                      await snapshot.data!.docs[index].reference.update({
                        "isRead": true,
                      });
                    }

                    if (!context.mounted) return;

                    if (type == "order") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminOrderDetailsPage(orderId: orderId),
                        ),
                      );
                    } else if (type == "user") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailsPage(userId: userId),
                        ),
                      );
                    }
                  },
                  child: _notificationCard(
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
          );
        },
      ),
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return Card(
      color: isRead ? Colors.white : Colors.orange.withValues(alpha: 0.08),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: iconColor.withValues(alpha: .12),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
