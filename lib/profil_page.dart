import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final List<Map<String, dynamic>> orderHistory = [
    {
      "image": "images/phone17.png",
      "title": "Iphone 17 Pro Max",
      "status": "Delivered",
      "price": "\$1000",
    },
    {
      "image": "images/shirt.jpg",
      "title": "T-shirt Adidas",
      "status": "Pending",
      "price": "\$300",
    },
    {
      "image": "images/rayban.jpg",
      "title": "Glasses Rayban",
      "status": "Delivered",
      "price": "\$120",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // هنا يمكن تضيف Edit Profile functionality
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---------------- User Info ----------------
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    "images/user.png",
                  ), // replace with your user image
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ismail Tazi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "ismail@example.com",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // ---------------- Order History ----------------
          const Text(
            "Order History",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...orderHistory.map(
            (order) => Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Image.asset(
                  order["image"],
                  width: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(order["title"]),
                subtitle: Text(
                  order["status"],
                  style: TextStyle(
                    color: order["status"] == "Delivered"
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                trailing: Text(
                  order["price"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // تقدر تدير navigate ل ItemDetails
                },
              ),
            ),
          ),

          const SizedBox(height: 30),
          const Divider(),

          // ---------------- Account Settings ----------------
          const Text(
            "Account Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Address"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Payment Methods"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log Out", style: TextStyle(color: Colors.red)),
            onTap: () async {
              // هنا دير تسجيل الخروج

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // clear role
              Navigator.pushReplacementNamed(context, "login");
            },
          ),
        ],
      ),
    );
  }
}
