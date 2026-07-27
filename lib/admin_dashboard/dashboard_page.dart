import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Welcome back",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Here's what's happening today",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RevenuePage()),
                  );
                },
                child: const DashboardCard(
                  title: "Revenue",
                  icon: Icons.attach_money,
                  color: Colors.green,
                  collection: "orders",
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
                  );
                },
                child: const DashboardCard(
                  title: "Orders",
                  icon: Icons.shopping_bag,
                  color: Colors.orange,
                  collection: "orders",
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsersPage()),
                  );
                },
                child: const DashboardCard(
                  title: "Users",
                  icon: Icons.people,
                  color: Colors.blue,
                  collection: "users",
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductPage()),
                  );
                },
                child: const DashboardCard(
                  title: "Products",
                  icon: Icons.inventory_2,
                  color: Colors.purple,
                  collection: "products",
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Recent Orders",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data!.docs;

              if (orders.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No recent orders")),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final data = orders[index].data() as Map<String, dynamic>;

                  final orderNumber = data["orderNumber"] ?? "";
                  final userName = data["userName"] ?? "";
                  final total = data["totalPrice"] ?? 0;
                  final status = data["status"] ?? "";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.shopping_bag),
                      ),
                      title: Text(orderNumber),
                      subtitle: Text(userName),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "\$$total",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
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
                                  color: getStatusColor(status),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
          const SizedBox(height: 20),
        ],
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
        final count = snapshot.data?.docs.length ?? 0;

        return Card(
          elevation: 4,
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
                  backgroundColor: color.withValues(alpha: .15),
                  child: Icon(icon, color: color, size: 30),
                ),

                const SizedBox(height: 12),

                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  "$count",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
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
