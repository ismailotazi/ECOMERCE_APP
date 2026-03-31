import 'package:flutter/material.dart';
import 'cart_data.dart'; // global cartItems

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
      quantities[i] = 1;
    }
  }

  double _calculateTotal(int index) {
    String priceText = cartItems[index]["price"] ?? "\$0";
    double price = double.tryParse(priceText.replaceAll("\$", "")) ?? 0.0;
    return price * (quantities[index] ?? 1);
  }

  double get cartTotal => List.generate(
    cartItems.length,
    (i) => _calculateTotal(i),
  ).fold(0.0, (a, b) => a + b);

  String _getImage(Map<String, dynamic> item) {
    if (item.containsKey("images") &&
        item["images"] is List &&
        item["images"].isNotEmpty)
      return item["images"][0];
    if (item.containsKey("image")) return item["image"];
    return "";
  }

  void _checkout() {
    if (cartItems.isEmpty) return;

    setState(() {
      cartItems.clear();
      quantities.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Order placed successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart"), backgroundColor: Colors.orange),
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
                                  ? Image.asset(
                                      img,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                    )
                                  : const SizedBox(width: 80, height: 80),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"] ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item["price"] ?? "",
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
