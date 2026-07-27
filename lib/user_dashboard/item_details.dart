import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/user_dashboard/write_review_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const ItemDetails({super.key, required this.data});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int currentImageIndex = 0;

  double rating = 4.0; // Default rating
  int quantity = 1;
  bool isFavorite = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  Future<void> checkFavorite() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(widget.data["id"])
        .get();

    if (mounted) {
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final List<String> images = List<String>.from(widget.data["images"] ?? []);
    final String brand = widget.data["brand"] ?? "Unknown";

    final String category = widget.data["category"] ?? "";

    final int stock = widget.data["stock"] ?? 0;

    final int discount = widget.data["discount"] ?? 0;

    final double oldPrice = (widget.data["oldPrice"] ?? 0).toDouble();

    final double rating = (widget.data["rating"] ?? 0).toDouble();

    final int reviews = widget.data["reviewsCount"] ?? 0;
    if (images.isEmpty && widget.data["image"] != null) {
      images.add(widget.data["image"]);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        centerTitle: true,

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
          "Product Dtails",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              final ref = FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection("favorites")
                  .doc(widget.data["id"]);

              if (isFavorite) {
                await ref.delete();
              } else {
                await ref.set({"createdAt": FieldValue.serverTimestamp()});
              }

              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // ===== Image Slider =====
          SizedBox(
            height: screenWidth * 0.8,

            child: images.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  )
                : PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => currentImageIndex = index),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZoomImagePage(image: images[index]),
                        ),
                      ),
                      child: Hero(
                        tag: images[index],
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
          ),

          // ===== Rectangular Indicator =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.isEmpty
                ? []
                : List.generate(images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      width: currentImageIndex == index ? 24 : 16,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentImageIndex == index
                            ? Colors.deepOrange
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
          ),

          const SizedBox(height: 20),

          // ===== Product Info =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (discount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "-$discount%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    Text(
                      widget.data["name"],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (oldPrice > 0)
                          Text(
                            "\$${oldPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),

                        if (oldPrice > 0) const SizedBox(width: 10),

                        Text(
                          "\$${widget.data["price"]}",
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Tax included",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.business,
                                size: 18,
                                color: Colors.deepOrange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                brand,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category,
                                size: 18,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== Rating Stars =====
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 22,
                      );
                    }),

                    const SizedBox(width: 8),

                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "($reviews Reviews)",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WriteReviewPage(productId: widget.data["id"]),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text("Write Review"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: stock > 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stock > 0
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        stock > 0 ? Icons.check_circle : Icons.cancel,
                        color: stock > 0 ? Colors.green : Colors.red,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          stock > 0
                              ? "Only $stock items left in stock"
                              : "Out of Stock",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  "Quantity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () {
                                setState(() {
                                  quantity--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),

                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: quantity < stock
                            ? () {
                                setState(() {
                                  quantity++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ===== Description Section =====
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data["description"] ?? "No description available.",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Related Products",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 280,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("products")
                        .where("category", isEqualTo: category)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final products = snapshot.data!.docs
                          .where((doc) => doc.id != widget.data["id"])
                          .toList();

                      if (products.isEmpty) {
                        return const Center(child: Text("No related products"));
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product =
                              products[index].data() as Map<String, dynamic>;

                          product["id"] = products[index].id;

                          return GestureDetector(
                            onTap: () {
                              final item = {
                                ...product,
                                "id": products[index].id,
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemDetails(data: item),
                                ),
                              );
                            },
                            child: Container(
                              width: 170,
                              margin: const EdgeInsets.only(right: 12),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          (product["images"] != null &&
                                                  (product["images"] as List)
                                                      .isNotEmpty)
                                              ? product["images"][0]
                                              : product["image"] ?? "",
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        product["name"] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        "\$${product["price"]}",
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Customer Reviews",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("products")
                      .doc(widget.data["id"])
                      .collection("reviews")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reviews = snapshot.data!.docs;

                    if (reviews.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("No reviews yet")),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review =
                            reviews[index].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  review["photoUrl"] != null &&
                                      review["photoUrl"] != ""
                                  ? NetworkImage(review["photoUrl"])
                                  : null,
                              child:
                                  review["photoUrl"] == null ||
                                      review["photoUrl"] == ""
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(review["userName"] ?? ""),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < (review["rating"] as num).toInt()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    );
                                  }),
                                ),

                                const SizedBox(height: 5),

                                Text(review["comment"] ?? ""),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),
                // ===== Add To Cart Button =====
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final index = cartItems.indexWhere(
                              (item) => item["id"] == widget.data["id"],
                            );

                            if (index != -1) {
                              cartItems[index]["quantity"] =
                                  (cartItems[index]["quantity"] ?? 1) +
                                  quantity;
                            } else {
                              cartItems.add({
                                ...widget.data,
                                "quantity": quantity,
                              });
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Added to cart 🛒")),
                            );

                            setState(() {});
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text("Add to Cart"),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: stock > 0
                              ? () {
                                  cartItems.clear();

                                  cartItems.add({
                                    ...widget.data,
                                    "quantity": quantity,
                                  });

                                  Navigator.pushNamed(context, "/cart");
                                }
                              : null,
                          icon: const Icon(Icons.flash_on),
                          label: const Text("Buy Now"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Zoom Image Page =====
class ZoomImagePage extends StatelessWidget {
  final String image;
  const ZoomImagePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: image,
            child: InteractiveViewer(child: Image.network(image)),
          ),
        ),
      ),
    );
  }
}
