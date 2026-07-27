import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("favorites")
            .snapshots(),
        builder: (context, favoriteSnapshot) {
          if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!favoriteSnapshot.hasData ||
              favoriteSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favorite products"));
          }

          final ids = favoriteSnapshot.data!.docs.map((e) => e.id).toList();

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("products")
                .where(FieldPath.documentId, whereIn: ids)
                .get(),
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = productSnapshot.data!.docs;

              return GridView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 260,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final doc = products[index];

                  final item = {
                    "id": doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  };

                  return _buildProductCard(context, uid, item);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String uid,
    Map<String, dynamic> item,
  ) {
    final image = item["image"] ?? "";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: "product_${item["id"]}",
                    child: Image.network(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                  ),

                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(uid)
                            .collection("favorites")
                            .doc(item["id"])
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Removed from favorites ❤️"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                item["name"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Text(
                item["description"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${item["price"]}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () {
                      cartItems.add({...item, "quantity": 1});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart 🛒")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
