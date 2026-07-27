import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics"), centerTitle: true),

      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance.collection("orders").get(),
          FirebaseFirestore.instance.collection("users").get(),
          FirebaseFirestore.instance.collection("products").get(),
        ]),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data"));
          }

          final orders = snapshot.data![0] as QuerySnapshot;

          final users = snapshot.data![1] as QuerySnapshot;

          final products = snapshot.data![2] as QuerySnapshot;

          double revenue = 0;

          int pending = 0;
          int processing = 0;
          int delivered = 0;
          int cancelled = 0;

          for (final doc in orders.docs) {
            final data = doc.data() as Map<String, dynamic>;

            revenue += (data["totalPrice"] ?? 0).toDouble();

            switch (data["status"]) {
              case "pending":
                pending++;
                break;

              case "processing":
                processing++;
                break;

              case "delivered":
                delivered++;
                break;

              case "cancelled":
                cancelled++;
                break;
            }
          }

          final averageOrder = orders.docs.isEmpty
              ? 0
              : revenue / orders.docs.length;

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  _AnalyticsCard(
                    title: "Revenue",
                    value: "\$${revenue.toStringAsFixed(2)}",
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),

                  _AnalyticsCard(
                    title: "Orders",
                    value: "${orders.docs.length}",
                    icon: Icons.shopping_bag,
                    color: Colors.deepOrange,
                  ),

                  _AnalyticsCard(
                    title: "Users",
                    value: "${users.docs.length}",
                    icon: Icons.people,
                    color: Colors.blue,
                  ),

                  _AnalyticsCard(
                    title: "Products",
                    value: "${products.docs.length}",
                    icon: Icons.inventory,
                    color: Colors.purple,
                  ),

                  _AnalyticsCard(
                    title: "Average Order",
                    value: "\$${averageOrder.toStringAsFixed(2)}",
                    icon: Icons.analytics,
                    color: Colors.indigo,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Orders Status",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
                children: [
                  _AnalyticsCard(
                    title: "Pending",
                    value: "$pending",
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),

                  _AnalyticsCard(
                    title: "Processing",
                    value: "$processing",
                    icon: Icons.sync,
                    color: Colors.blue,
                  ),

                  _AnalyticsCard(
                    title: "Delivered",
                    value: "$delivered",
                    icon: Icons.local_shipping,
                    color: Colors.green,
                  ),

                  _AnalyticsCard(
                    title: "Cancelled",
                    value: "$cancelled",
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.insights,
                        color: Colors.deepOrange,
                        size: 55,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Business Overview",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Your store currently has ${users.docs.length} users, "
                        "${products.docs.length} products and "
                        "${orders.docs.length} orders generating "
                        "\$${revenue.toStringAsFixed(2)} in revenue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: color.withValues(alpha: .20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color, size: 22),
            ),

            const SizedBox(height: 12),

            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
