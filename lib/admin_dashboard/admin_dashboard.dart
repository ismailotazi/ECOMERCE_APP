import 'package:ecomerce_app/admin_dashboard/add_product.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const ProductPage(),
    const AddProductPage(),
    const OrdersPage(),
    const UsersPage(),
    const HomePage(),
  ];

  final List<String> titles = [
    "Products",
    "Add Product",
    "Orders",
    "Users",
    "Home",
  ];

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // remove saved role/email
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout: use drawer for small screens, sidebar for large
    final bool isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: "Go to Home",
            onPressed: () => setState(() => selectedIndex = 4),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: logout,
          ),
        ],
      ),
      drawer: isLargeScreen ? null : _buildDrawer(),
      body: Row(
        children: [
          if (isLargeScreen)
            _buildDrawer(), // permanent drawer for large screens
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: Colors.deepOrange,
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 35,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _drawerItem(Icons.inventory, "Products", 0),
          _drawerItem(Icons.add_box, "Add Product", 1),
          _drawerItem(Icons.list_alt, "Orders", 2),
          _drawerItem(Icons.people, "Users", 3),
          _drawerItem(Icons.home, "Home", 4),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: logout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final bool selected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.deepOrange : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.deepOrange : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: () {
        setState(() => selectedIndex = index);
        if (MediaQuery.of(context).size.width < 800) Navigator.pop(context);
      },
    );
  }
}
