import 'package:ecomerce_app/admin_dashboard/add_product.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:flutter/material.dart';

import 'orders_page.dart';
import 'product_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final pages = [
    const ProductPage(),
    const AddProductPage(),
    const OrdersPage(),
  ];

  final titles = ["Products", "Add Product", "Orders"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "login");
            },
          ),
        ],
      ),
      body: pages[selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                "Admin Panel",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Products"),
              selected: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Product"),
              selected: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("Orders"),
              selected: selectedIndex == 2,
              onTap: () => setState(() => selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}
