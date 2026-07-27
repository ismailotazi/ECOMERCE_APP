import 'package:ecomerce_app/models/order_item_model.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/order_service.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, int> quantities = {};

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < cartItems.length; i++) {
      quantities[i] = cartItems[i]["quantity"] ?? 1;
    }
  }

  double _calculateTotal(int index) {
    final price = (cartItems[index]["price"] as num?)?.toDouble() ?? 0.0;
    return price * (quantities[index] ?? 1);
  }

  double get cartTotal => List.generate(
    cartItems.length,
    (i) => _calculateTotal(i),
  ).fold(0.0, (a, b) => a + b);

  String _getImage(Map<String, dynamic> item) {
    return item["image"] ?? "";
  }

  Future<void> _checkout() async {
    try {
      if (cartItems.isEmpty) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final items = cartItems.map((e) {
        return OrderItemModel(
          productId: e["id"],
          name: e["name"],
          image: e["image"],
          price: (e["price"] as num).toDouble(),
          quantity: e["quantity"] ?? 1,
        );
      }).toList();

      await OrderService().createOrder(
        userId: user.uid,
        userName: user.displayName ?? "User",
        email: user.email ?? "",
        items: items,
        totalPrice: cartTotal,
      );

      setState(() {
        cartItems.clear();
        quantities.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully!")),
      );
    } catch (e) {
      debugPrint("ORDER ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ERROR: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart"), centerTitle: true),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty 😢"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final img = _getImage(item);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              img.isNotEmpty
                                  ? Image.network(
                                      img,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) {
                                        return const SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox(width: 80, height: 80),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"] ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${item["price"]}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => setState(() {
                                            if ((quantities[index] ?? 1) > 1) {
                                              quantities[index] =
                                                  (quantities[index] ?? 1) - 1;

                                              cartItems[index]["quantity"] =
                                                  quantities[index];
                                            }
                                          }),
                                        ),
                                        Text(
                                          "${quantities[index] ?? 1}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => setState(() {
                                            quantities[index] =
                                                (quantities[index] ?? 1) + 1;

                                            cartItems[index]["quantity"] =
                                                quantities[index];
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "\$${_calculateTotal(index).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${cartTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Checkout",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
