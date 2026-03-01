import 'package:ecomerce_app/cart_page.dart';
import 'package:ecomerce_app/home_page.dart';
import 'package:ecomerce_app/profil_page.dart';
import 'package:flutter/material.dart';

class ItemDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const ItemDetails({super.key, required this.data});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int currentPage = 0;

  void navigate(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProfilPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shop_outlined, color: Colors.black),
            SizedBox(width: 5),
            Text("Milo", style: TextStyle(color: Colors.black)),
            Text("Store", style: TextStyle(color: Colors.deepPurple)),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
          navigate(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Image.asset(
                  widget.data["image"],
                  height: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 15),

                Text(
                  widget.data["title"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.data["subtitle"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.data["price"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Color:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(radius: 10, backgroundColor: Colors.grey),
                    SizedBox(width: 5),
                    Text("Grey"),
                    SizedBox(width: 15),
                    CircleAvatar(radius: 10, backgroundColor: Colors.black),
                    SizedBox(width: 5),
                    Text("Black"),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Size: 35  36  37  38  39  40  41  42  43  44",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 30),

                Center(
                  child: MaterialButton(
                    height: 45,
                    minWidth: 180,
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart 🛒")),
                      );
                    },
                    child: const Text(
                      "Add To Cart",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
