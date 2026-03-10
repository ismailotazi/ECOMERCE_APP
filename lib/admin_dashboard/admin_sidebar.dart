import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final Function(int) onSelect;

  const AdminSidebar({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 40),

          const Text(
            "ADMIN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 40),

          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.white),
            title: const Text(
              "Products",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              onSelect(0);
            },
          ),

          ListTile(
            leading: const Icon(Icons.add_box, color: Colors.white),
            title: const Text(
              "Add Product",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              onSelect(1);
            },
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.white),
            title: const Text("Orders", style: TextStyle(color: Colors.white)),
            onTap: () {
              onSelect(2);
            },
          ),

          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text("Users", style: TextStyle(color: Colors.white)),
            onTap: () {
              onSelect(3);
            },
          ),
        ],
      ),
    );
  }
}
