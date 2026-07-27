import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    final orderRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("orders")
        .doc(orderId);

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: orderRef.get(),
        builder: (context, orderSnapshot) {
          if (!orderSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderData = orderSnapshot.data!.data() as Map<String, dynamic>;

          final total = orderData["totalPrice"] ?? 0;
          final status = orderData["status"] ?? "pending";

          final createdAt = orderData["createdAt"] != null
              ? (orderData["createdAt"] as Timestamp).toDate()
              : null;

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Order ID",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "#${1000 + orderSnapshot.data!.id.hashCode.abs() % 9000}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                  status.toUpperCase(),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("\$$total"),
                        ],
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Products",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: orderRef.collection("items").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = snapshot.data!.docs;

                    if (items.isEmpty) {
                      return const Center(child: Text("No products"));
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item =
                            items[index].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: Image.network(
                              item["image"] ?? "",
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image),
                            ),
                            title: Text(item["name"] ?? ""),
                            subtitle: Text("Qty : ${item["quantity"]}"),
                            trailing: Text(
                              "\$${item["price"]}",
                              style: const TextStyle(
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
          );
        },
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
