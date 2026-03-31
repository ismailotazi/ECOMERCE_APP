import 'package:flutter/material.dart';
import 'package:ecomerce_app/item_details.dart';

class ProductSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> products;

  ProductSearchDelegate({required this.products});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
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
          (item) => item["title"].toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();

    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where(
          (item) => item["title"].toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();

    return _buildList(suggestions);
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No product found"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];

        // ===== get image safely =====
        String image = "";
        if (item.containsKey("images") &&
            item["images"] is List &&
            item["images"].isNotEmpty) {
          image = item["images"][0];
        } else if (item.containsKey("image")) {
          image = item["image"];
        }

        return ListTile(
          leading: image.isNotEmpty
              ? Image.asset(image, width: 50, height: 50, fit: BoxFit.cover)
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 24),
                ),
          title: Text(item["title"] ?? "No title"),
          subtitle: Text(item["price"] ?? ""),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
            );
          },
        );
      },
    );
  }
}
