import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("orders")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders yet"));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];

            final data = order.data() as Map<String, dynamic>;

            final total = data["totalPrice"] ?? 0;

            final status = data["status"] ?? "pending";

            DateTime? date;

            if (data["createdAt"] != null) {
              date = (data["createdAt"] as Timestamp).toDate();
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getStatusColor(status),
                  child: const Icon(Icons.shopping_bag, color: Colors.white),
                ),
                title: Text("Order #${order.id.substring(0, 6)}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status : $status"),
                    Text(
                      date == null
                          ? ""
                          : "${date.day}/${date.month}/${date.year}",
                    ),
                  ],
                ),
                trailing: Text(
                  "\$$total",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
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
    );
  }
}
