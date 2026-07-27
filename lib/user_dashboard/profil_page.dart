import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/user_dashboard/Payment_methods_page.dart';
import 'package:ecomerce_app/user_dashboard/notifications_page.dart';

import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
import 'package:ecomerce_app/user_dashboard/user_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserEditProfile()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---------------- User Info ----------------
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          data["photoUrl"] != null &&
                              data["photoUrl"].toString().isNotEmpty
                          ? NetworkImage(data["photoUrl"])
                          : const AssetImage("images/user.png")
                                as ImageProvider,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${data["firstName"]} ${data["lastName"]}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${data["city"]}, ${data["country"]}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      data["email"] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          // ---------------- Order History ----------------
          const Text(
            "Order History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("orders")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No orders yet")),
                );
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  final data = order.data() as Map<String, dynamic>;

                  final status = data["status"] ?? "pending";

                  final total = data["totalPrice"] ?? 0;
                  final itemsCount = (data["itemsCount"] ?? 0) as int;
                  DateTime? createdAt;

                  if (data["createdAt"] != null) {
                    createdAt = (data["createdAt"] as Timestamp).toDate();
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: getStatusColor(status),
                        child: Icon(getStatusIcon(status), color: Colors.white),
                      ),
                      title: Text(data["orderNumber"] ?? "Order"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(
                                status,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  getStatusIcon(status),
                                  size: 16,
                                  color: getStatusColor(status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          if (createdAt != null)
                            Text(
                              "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                              "${createdAt.hour.toString().padLeft(2, '0')}:"
                              "${createdAt.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 4),

                          Text(
                            "$itemsCount ${itemsCount == 1 ? 'Product' : 'Products'}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        "\$$total",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsPage(orderId: order.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 30),
          const Divider(),

          // ---------------- Account Settings ----------------
          const Text(
            "Account Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserEditProfile()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Payment Methods"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PaymentMethodsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                // Firebase logout
                await FirebaseAuth.instance.signOut();

                // clear local storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (Route<dynamic> route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
              }
            },
          ),
        ],
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
}
