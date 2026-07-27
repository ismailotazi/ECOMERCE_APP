import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_notifications_page.dart';
import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/edit_admin_profile.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileAdminPage extends StatelessWidget {
  const ProfileAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
        FirebaseFirestore.instance.collection("orders").get(),
        FirebaseFirestore.instance.collection("users").get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        final userDoc = snapshot.data![0] as DocumentSnapshot;
        final orders = snapshot.data![1] as QuerySnapshot;
        final users = snapshot.data![2] as QuerySnapshot;

        final data = userDoc.data() as Map<String, dynamic>;

        final firstName = data["firstName"] ?? "";
        final lastName = data["lastName"] ?? "";
        final role = data["role"] ?? "Administrator";
        final photoUrl = data["photoUrl"] ?? "";

        double revenue = 0;

        for (final doc in orders.docs) {
          final order = doc.data() as Map<String, dynamic>;
          revenue += (order["totalPrice"] ?? 0).toDouble();
        }

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepOrange, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl.isEmpty
                            ? const Icon(
                                Icons.admin_panel_settings,
                                size: 32,
                                color: Colors.deepOrange,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Text(
                      "$firstName $lastName",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _HeaderStat(
                          title: "Revenue",
                          value: "\$${revenue.toStringAsFixed(0)}",
                        ),
                        _HeaderStat(
                          title: "Orders",
                          value: "${orders.docs.length}",
                        ),
                        _HeaderStat(
                          title: "Users",
                          value: "${users.docs.length}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF3E0),
                        child: Icon(Icons.person, color: Colors.deepOrange),
                      ),
                      title: const Text("Edit Profile"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditAdminProfile()),
                        );
                      },
                    ),
                    const Divider(height: 1),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.notifications, color: Colors.green),
                      ),
                      title: const Text("Notifications"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminNotificationsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "Store Management",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF3E5F5),
                        child: Icon(Icons.inventory, color: Colors.purple),
                      ),
                      title: const Text("Products"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProductPage()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF8E1),
                        child: Icon(Icons.shopping_bag, color: Colors.orange),
                      ),
                      title: const Text("Orders"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AdminOrdersPage()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.people, color: Colors.blue),
                      ),
                      title: const Text("Users"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UsersPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/login",
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
