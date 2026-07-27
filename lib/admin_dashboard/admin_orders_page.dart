import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_order_details.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          "Orders",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Orders"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              final data = order.data() as Map<String, dynamic>;

              final status = data["status"] ?? "pending";
              final total = data["totalPrice"] ?? 0;
              final items = data["itemsCount"] ?? 0;
              final number = data["orderNumber"] ?? order.id.substring(0, 6);
              final userName = data["userName"] ?? "Unknown User";
              final email = data["email"] ?? "";
              DateTime? createdAt;

              if (data["createdAt"] != null) {
                createdAt = (data["createdAt"] as Timestamp).toDate();
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: status == "pending"
                        ? Colors.orange
                        : status == "delivered"
                        ? Colors.green
                        : Colors.red,
                    child: const Icon(Icons.shopping_bag, color: Colors.white),
                  ),

                  title: Text(number),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == "pending"
                              ? Colors.orange
                              : status == "delivered"
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text("$items ${items == 1 ? "Product" : "Products"}"),

                      if (createdAt != null)
                        Text(
                          "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                          "${createdAt.hour.toString().padLeft(2, '0')}:"
                          "${createdAt.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.grey),
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
                        builder: (_) =>
                            AdminOrderDetailsPage(orderId: order.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
