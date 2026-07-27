import 'package:ecomerce_app/user_dashboard/cart_page.dart';
import 'package:ecomerce_app/user_dashboard/favorite_page.dart';
import 'package:ecomerce_app/user_dashboard/home_page.dart';
import 'package:ecomerce_app/user_dashboard/profil_page.dart';
import 'package:flutter/material.dart';

class MainNavUser extends StatefulWidget {
  const MainNavUser({super.key});

  @override
  State<MainNavUser> createState() => _MainNavUserState();
}

class _MainNavUserState extends State<MainNavUser> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    CartPage(),
    FavoritePage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
