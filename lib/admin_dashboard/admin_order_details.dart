import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  const AdminOrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  String selectedStatus = "pending";
  final List<Map<String, dynamic>> statuses = [
    {"value": "pending", "icon": Icons.hourglass_top, "color": Colors.orange},
    {"value": "processing", "icon": Icons.sync, "color": Colors.blue},
    {"value": "shipped", "icon": Icons.local_shipping, "color": Colors.purple},
    {"value": "delivered", "icon": Icons.check_circle, "color": Colors.green},
    {"value": "cancelled", "icon": Icons.cancel, "color": Colors.red},
  ];

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
          "Orders Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.orderId)
            .get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (selectedStatus == "pending") {
            selectedStatus = data["status"] ?? "pending";
          }

          final orderNumber = data["orderNumber"];
          final userName = data["userName"];
          final email = data["email"];
          final total = data["totalPrice"];
          final userId = data["userId"];

          final createdAt = (data["createdAt"] as Timestamp).toDate();
          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              Text(
                orderNumber,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                "${createdAt.hour.toString().padLeft(2, '0')}:"
                "${createdAt.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              const Text(
                "Customer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),

                title: Text(userName),

                subtitle: Text(email),
              ),

              const SizedBox(height: 20),
              const Text(
                "Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("orders")
                    .doc(widget.orderId)
                    .collection("items")
                    .get(),

                builder: (context, itemsSnapshot) {
                  if (!itemsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = itemsSnapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),

                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item["image"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image),
                                );
                              },
                            ),
                          ),

                          title: Text(item["name"]),

                          subtitle: Text("Qty: ${item["quantity"]}"),

                          trailing: Text(
                            "\$${item["price"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 5),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments, color: Colors.green),

                  title: const Text("Order Total"),

                  trailing: Text(
                    "\$$total",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Order Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status["value"],
                    child: Row(
                      children: [
                        Icon(status["icon"], color: status["color"], size: 20),
                        const SizedBox(width: 10),
                        Text(status["value"].toString().toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),

                  label: const Text("Save Changes"),

                  onPressed: () async {
                    // Update main order
                    await FirebaseFirestore.instance
                        .collection("orders")
                        .doc(widget.orderId)
                        .update({"status": selectedStatus});

                    // Find the user's order by orderNumber then update it
                    final query = await FirebaseFirestore.instance
                        .collection("users")
                        .doc(userId)
                        .collection("orders")
                        .where("orderNumber", isEqualTo: orderNumber)
                        .limit(1)
                        .get();

                    if (query.docs.isNotEmpty) {
                      await query.docs.first.reference.update({
                        "status": selectedStatus,
                      });
                    }

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Order updated successfully"),
                      ),
                    );

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
