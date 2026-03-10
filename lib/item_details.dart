import 'package:ecomerce_app/cart_data.dart';

import 'package:flutter/material.dart';

class ItemDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const ItemDetails({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: data["image"],
            child: Image.asset(data["image"], height: 250, fit: BoxFit.contain),
          ),
          const SizedBox(height: 15),
          Text(
            data["title"],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            data["subtitle"],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            data["price"],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.deepOrange,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
                cartItems.add(data);

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
    );
  }
}
