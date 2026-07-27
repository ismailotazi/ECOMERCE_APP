import 'package:ecomerce_app/admin_dashboard/admin_drawer.dart';
import 'package:ecomerce_app/admin_dashboard/admin_notifications_page.dart';

import 'package:ecomerce_app/admin_dashboard/dashboard_page.dart';
import 'package:ecomerce_app/admin_dashboard/profile_admin_page.dart';

import 'package:ecomerce_app/admin_dashboard/add_product.dart';
import 'package:flutter/material.dart';

class MainNavAdmin extends StatefulWidget {
  const MainNavAdmin({super.key});

  @override
  State<MainNavAdmin> createState() => _MainNavAdminState();
}

class _MainNavAdminState extends State<MainNavAdmin> {
  int currentIndex = 0;
  bool get showDrawer => currentIndex == 0;
  final List<Widget> pages = const [
    DashboardPage(),

    AddProductPage(),

    ProfileAdminPage(),
  ];

  final List<String> titles = const ["Home", "Add Product", "Profile"];

  // Future<void> logout() async {
  //   await GoogleSignIn().signOut();
  //   await FirebaseAuth.instance.signOut();

  //   if (!mounted) return;

  //   Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,

        automaticallyImplyLeading: showDrawer,

        actions: showDrawer
            ? [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminNotificationsPage(),
                      ),
                    );
                  },
                ),
              ]
            : [],
      ),
      drawer: showDrawer ? const AdminDrawer() : null,
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: "Home",
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.inventory_2_outlined),
          //   selectedIcon: Icon(Icons.inventory_2),
          //   label: "Products",
          // ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: "Add",
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.receipt_long_outlined),
          //   selectedIcon: Icon(Icons.receipt_long),
          //   label: "Orders",
          // ),
          // NavigationDestination(
          //   icon: Icon(Icons.people_outline),
          //   selectedIcon: Icon(Icons.people),
          //   label: "Users",
          // ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
