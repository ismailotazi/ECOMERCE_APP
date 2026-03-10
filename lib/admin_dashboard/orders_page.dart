import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  // Sample order data
  final List<Map<String, dynamic>> orders = const [
    {
      "id": "#1001",
      "customer": "Ismail Tazi",
      "total": "\$1200",
      "status": "Delivered",
      "date": "2026-03-10",
    },
    {
      "id": "#1002",
      "customer": "Sara Ahmed",
      "total": "\$450",
      "status": "Pending",
      "date": "2026-03-09",
    },
    {
      "id": "#1003",
      "customer": "Ali Khan",
      "total": "\$300",
      "status": "Cancelled",
      "date": "2026-03-08",
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "Delivered":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(
                order["customer"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Order ID: ${order["id"]}"),
                  Text("Date: ${order["date"]}"),
                  Text(
                    order["status"],
                    style: TextStyle(
                      color: getStatusColor(order["status"]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                order["total"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // T9dr dir navigate l Order Details Page
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Order ${order["id"]} Details"),
                    content: Text(
                      "Customer: ${order["customer"]}\nTotal: ${order["total"]}\nStatus: ${order["status"]}\nDate: ${order["date"]}",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
