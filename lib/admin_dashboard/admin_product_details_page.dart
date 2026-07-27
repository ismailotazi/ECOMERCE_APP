import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AdminProductDetailsPage extends StatefulWidget {
  const AdminProductDetailsPage({super.key, required this.productId});

  final String productId;

  @override
  State<AdminProductDetailsPage> createState() =>
      _AdminProductDetailsPageState();
}

class _AdminProductDetailsPageState extends State<AdminProductDetailsPage> {
  final PageController pageController = PageController();

  int currentImage = 0;

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct() {
    return FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .get();
  }

  Future<void> deleteProduct(Map<String, dynamic> product) async {
    try {
      final List images = product["images"] ?? [];

      for (final image in images) {
        try {
          await FirebaseStorage.instance.refFromURL(image).delete();
        } catch (_) {}
      }

      await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.productId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getProduct(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Product not found"));
            }

            final product = snapshot.data!.data()!;
            final List images = product["images"] ?? [];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 320,
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentImage = index;
                            });
                          },
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: "${widget.productId}_$index",
                              child: InteractiveViewer(
                                child: Image.network(
                                  images[index],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentImage == index ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentImage == index
                                  ? Colors.orange
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product["name"] ?? "",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${product["rating"] ?? 0}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "(${product["reviewsCount"] ?? 0} Reviews)",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${product["price"]}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            const SizedBox(width: 12),

                            if ((product["oldPrice"] ?? 0) > 0)
                              Text(
                                "\$${product["oldPrice"]}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),

                            const SizedBox(width: 10),

                            if ((product["discount"] ?? 0) > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "-${product["discount"]}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.category_outlined,
                            "Category",
                            product["category"] ?? "-",
                          ),

                          const Divider(),

                          _buildInfoRow(
                            Icons.branding_watermark_outlined,
                            "Brand",
                            product["brand"] ?? "-",
                          ),

                          const Divider(),

                          _buildInfoRow(
                            Icons.inventory_2_outlined,
                            "Stock",
                            "${product["stock"] ?? 0}",
                          ),

                          const Divider(),

                          _buildInfoRow(
                            Icons.rate_review_outlined,
                            "Reviews",
                            "${product["reviewsCount"] ?? 0}",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description_outlined),
                              SizedBox(width: 8),
                              Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            product["description"] ??
                                "No description available.",
                            style: const TextStyle(fontSize: 15, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Statistics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildStatCard(
                        Icons.star,
                        "Rating",
                        "${product["rating"] ?? 0}",
                        Colors.amber,
                      ),
                      _buildStatCard(
                        Icons.rate_review,
                        "Reviews",
                        "${product["reviewsCount"] ?? 0}",
                        Colors.blue,
                      ),
                      _buildStatCard(
                        Icons.inventory,
                        "Stock",
                        "${product["stock"] ?? 0}",
                        Colors.green,
                      ),
                      _buildStatCard(
                        Icons.discount,
                        "Discount",
                        "${product["discount"] ?? 0}%",
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Product"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProductPage(productId: widget.productId),
                          ),
                        );

                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Delete Product",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Delete Product"),
                              content: const Text(
                                "Are you sure you want to delete this product?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await deleteProduct(product);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
