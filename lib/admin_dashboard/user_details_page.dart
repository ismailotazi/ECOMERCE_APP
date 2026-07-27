import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

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
          "Users Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          data["photoUrl"] != null &&
                              data["photoUrl"].toString().isNotEmpty
                          ? NetworkImage(data["photoUrl"])
                          : null,
                      child:
                          data["photoUrl"] == null ||
                              data["photoUrl"].toString().isEmpty
                          ? const Icon(Icons.person, size: 55)
                          : null,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "${data["firstName"]} ${data["lastName"]}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "@${data["username"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      data["email"] ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (data["role"] == "admin")
                            ? Colors.deepOrange.withValues(alpha: .15)
                            : Colors.blue.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        (data["role"] ?? "user").toUpperCase(),
                        style: TextStyle(
                          color: (data["role"] == "admin")
                              ? Colors.deepOrange
                              : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(Icons.email, color: Colors.blue),
                        ),
                        title: const Text("Email"),
                        subtitle: Text(data["email"] ?? "-"),
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(Icons.phone, color: Colors.green),
                        ),
                        title: const Text("Phone"),
                        subtitle: Text(data["phone"] ?? "-"),
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(Icons.people, color: Colors.orange),
                        ),
                        title: const Text("Gender"),
                        subtitle: Text(data["gender"] ?? "-"),
                      ),

                      const Divider(),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF3E5F5),
                          child: Icon(Icons.cake, color: Colors.purple),
                        ),
                        title: const Text("Date of Birth"),
                        subtitle: Text(
                          data["birthDate"] != null
                              ? "${(data["birthDate"] as Timestamp).toDate().day}/"
                                    "${(data["birthDate"] as Timestamp).toDate().month}/"
                                    "${(data["birthDate"] as Timestamp).toDate().year}"
                              : "-",
                        ),
                      ),
                      const SizedBox(height: 25),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Shipping Address",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE8F5E9),
                                  child: Icon(
                                    Icons.public,
                                    color: Colors.green,
                                  ),
                                ),
                                title: const Text("Country"),
                                subtitle: Text(data["country"] ?? "-"),
                              ),

                              const Divider(),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE3F2FD),
                                  child: Icon(
                                    Icons.location_city,
                                    color: Colors.blue,
                                  ),
                                ),
                                title: const Text("City"),
                                subtitle: Text(data["city"] ?? "-"),
                              ),

                              const Divider(),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFFFF3E0),
                                  child: Icon(Icons.home, color: Colors.orange),
                                ),
                                title: const Text("Street Address"),
                                subtitle: Text(data["address"] ?? "-"),
                              ),

                              const Divider(),

                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFF3E5F5),
                                  child: Icon(
                                    Icons.markunread_mailbox,
                                    color: Colors.purple,
                                  ),
                                ),
                                title: const Text("ZIP Code"),
                                subtitle: Text(data["zipCode"] ?? "-"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("orders")
                            .where("userId", isEqualTo: userId)
                            .get(),
                        builder: (context, orderSnapshot) {
                          if (!orderSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final orders = orderSnapshot.data!.docs;

                          double totalSpent = 0;

                          for (var order in orders) {
                            final data = order.data() as Map<String, dynamic>;

                            totalSpent += (data["totalPrice"] ?? 0).toDouble();
                          }

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Customer Statistics",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFE3F2FD),
                                      child: Icon(
                                        Icons.shopping_bag,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    title: const Text("Total Orders"),
                                    trailing: Text(
                                      orders.length.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const Divider(),

                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFE8F5E9),
                                      child: Icon(
                                        Icons.payments,
                                        color: Colors.green,
                                      ),
                                    ),
                                    title: const Text("Total Spent"),
                                    trailing: Text(
                                      "\$${totalSpent.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const Divider(),

                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFFFF3E0),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    title: const Text("Member Since"),
                                    subtitle: Text(
                                      data["createdAt"] != null
                                          ? (data["createdAt"] as Timestamp)
                                                .toDate()
                                                .toString()
                                                .split(" ")
                                                .first
                                          : "-",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Quick Actions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    // TODO: Open all orders of this user
                                  },
                                  icon: const Icon(Icons.shopping_bag_outlined),
                                  label: const Text("View Orders"),
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    // TODO: Edit user
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit User"),
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Delete User"),
                                        content: const Text(
                                          "Are you sure you want to delete this user?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(userId)
                                          .delete();

                                      if (context.mounted) {
                                        Navigator.pop(context);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "User deleted successfully",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Delete User"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
