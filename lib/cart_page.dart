// cart_page.dart
import 'package:flutter/material.dart';
import 'cart_data.dart'; // hna l-list dyal cartItems

class CartPage extends StatelessWidget {
  // optional data
  final Map<String, dynamic>? data;

  const CartPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    // ila jatch data jdida f ItemDetails, zidha l cartItems
    if (data != null && data!.isNotEmpty && !cartItems.contains(data)) {
      cartItems.add(data!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: Image.asset(item["image"], width: 50),
            title: Text(item["title"]),
            subtitle: Text(item["price"]),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                cartItems.removeAt(index);
                (context as Element).markNeedsBuild();
              },
            ),
          );
        },
      ),
    );
  }
}
