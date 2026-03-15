import 'package:flutter/material.dart';
import 'package:ecomerce_app/cart_data.dart';

class ItemDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const ItemDetails({super.key, required this.data});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int currentImageIndex = 0;
  bool isFavorite = false;
  double rating = 4.0; // Default rating

  @override
  Widget build(BuildContext context) {
    final List<String> images = List<String>.from(
      widget.data["images"] ?? [widget.data["image"]],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data["title"]),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? "Added to favorites ❤️"
                        : "Removed from favorites",
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // ===== Image Slider =====
          SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoomImagePage(image: images[index]),
                      ),
                    );
                  },
                  child: Hero(
                    tag: images[index],
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),

          // ===== Rectangular Indicator =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                width: currentImageIndex == index ? 24 : 16,
                height: 8,
                decoration: BoxDecoration(
                  color: currentImageIndex == index
                      ? Colors.orange
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
                Text(
                  widget.data["title"],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data["subtitle"] ?? "",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.data["price"],
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ===== Rating Stars =====
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
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

                // ===== Add To Cart Button =====
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      cartItems.add(widget.data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart 🛒")),
                      );
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add To Cart",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
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
            child: InteractiveViewer(child: Image.asset(image)),
          ),
        ),
      ),
    );
  }
}
