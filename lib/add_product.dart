import 'package:flutter/material.dart';

class AddProduct extends StatelessWidget {
  const AddProduct({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    TextEditingController price = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: price,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                print(name.text);
                print(price.text);
              },
              child: const Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }
}
