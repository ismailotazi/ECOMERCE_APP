import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/favorite_service.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> products;

  ProductSearchDelegate({required this.products});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where(
          (p) => (p["name"] ?? "").toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        String image = "";

        if (item["images"] != null && (item["images"] as List).isNotEmpty) {
          image = item["images"][0];
        } else {
          image = item["image"] ?? "";
        }

        return ListTile(
          leading: Image.network(image, width: 50),
          title: Text(item["name"]),
          subtitle: Text(item["price"]),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where(
          (p) => (p["name"] ?? "").toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        String image = "";

        if (item["images"] != null && (item["images"] as List).isNotEmpty) {
          image = item["images"][0];
        } else {
          image = item["image"] ?? "";
        }

        return ListTile(
          leading: Image.network(image, width: 50),
          title: Text(item["name"]),
          onTap: () => query = item["name"],
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All";

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.electrical_services, "title": "Electrical"},
    {"icon": Icons.spa, "title": "Parfum"},
    {"icon": Icons.checkroom, "title": "Clothes"},
    {"icon": Icons.directions_run, "title": "Shoes"},
    {"icon": Icons.remove_red_eye, "title": "Glasses"},
    {"icon": Icons.more_horiz, "title": "Others"},
  ];
  final FavoriteService _favoriteService = FavoriteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildHomeContent()));
  }

  Widget _buildHomeContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        final products = snapshot.data!.docs.map((doc) {
          return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();

        final filteredProducts = selectedCategory == "All"
            ? products
            : products.where((p) => p["category"] == selectedCategory).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ===== Search =====
            InkWell(
              onTap: () => showSearch(
                context: context,
                delegate: ProductSearchDelegate(products: filteredProducts),
              ),
              child: TextFormField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Search products",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryItem("All", Icons.apps);
                  }

                  final cat = categories[index - 1];
                  return _buildCategoryItem(cat["title"], cat["icon"]);
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Best Selling",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 260,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return _buildProductCard(filteredProducts[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedCategory = title),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: isSelected
                  ? Colors.deepOrange
                  : Colors.grey[200],
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final image = item["image"];
    final productId = item["id"];

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: "product_${item["id"]}",
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          image,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 6,
                    right: 6,
                    child: StreamBuilder<bool>(
                      stream: _favoriteService.isFavorite(productId),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;

                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              await _favoriteService.toggleFavorite(productId);
                            },
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      cartItems.add(item);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart 🛒")),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
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
