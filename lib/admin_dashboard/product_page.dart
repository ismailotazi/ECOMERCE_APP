import 'package:ecomerce_app/admin_dashboard/admin_product_details_page.dart';
import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // 🔥 Fix any type (String / double / int)
  double parsePrice(dynamic price) {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0;
    return 0;
  }

  Color getPriceColor(double price) {
    if (price > 500) return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          "Products",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products available"));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final docId = products[index].id;

              final double price = parsePrice(product['price']);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminProductDetailsPage(productId: docId),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: product['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(
                      product['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['description']),
                        const SizedBox(height: 5),
                        Text(
                          "\$${price.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: getPriceColor(price),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == "edit") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductPage(productId: docId),
                            ),
                          );
                        }

                        if (value == "delete") {
                          final messenger = ScaffoldMessenger.of(context);

                          await FirebaseFirestore.instance
                              .collection("products")
                              .doc(docId)
                              .delete();

                          messenger.showSnackBar(
                            const SnackBar(content: Text("Product deleted")),
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 10),
                              Text("Edit"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
