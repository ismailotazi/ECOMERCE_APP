import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Drawer(child: Center(child: Text("No user found")));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Drawer(child: Center(child: Text("User not found")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final firstName = data["firstName"] ?? "";
        final lastName = data["lastName"] ?? "";
        final email = data["email"] ?? "";
        final photoUrl = data["photoUrl"] ?? "";
        final role = data["role"] ?? "Administrator";

        return Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.deepOrange,
                            width: 2,
                          ),
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

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$firstName $lastName",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    role.toUpperCase(),
                                    style: const TextStyle(
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
                    ],
                  ),
                ),

                const Divider(indent: 20, endIndent: 20),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Text(
                    "MENU",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.orange,
                  title: "Orders",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminOrdersPage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.people_outline,
                  color: Colors.blue,
                  title: "Customers",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UsersPage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.inventory_2_outlined,
                  color: Colors.purple,
                  title: "Products",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductPage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                  title: "Revenue",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RevenuePage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.analytics_outlined,
                  color: Colors.indigo,
                  title: "Analytics",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnalyticsPage()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                const Divider(indent: 20, endIndent: 20),

                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Text(
                    "SYSTEM",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.settings_outlined,
                  color: Colors.grey,
                  title: "Settings",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open Settings
                  },
                ),

                const Divider(indent: 20, endIndent: 20),

                _buildMenuTile(
                  context,
                  icon: Icons.logout_rounded,
                  color: Colors.red,
                  title: "Logout",
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                  },
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
