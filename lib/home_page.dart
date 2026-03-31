import 'package:flutter/material.dart';
import 'package:ecomerce_app/cart_data.dart';
import 'package:ecomerce_app/cart_page.dart';
import 'package:ecomerce_app/item_details.dart';
import 'package:ecomerce_app/profil_page.dart';

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
        .where((p) => p["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final image = (item["images"] ?? [item["image"]])[0];

        return ListTile(
          leading: Image.asset(image, width: 50),
          title: Text(item["title"]),
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
        .where((p) => p["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        final image = (item["images"] ?? [item["image"]])[0];

        return ListTile(
          leading: Image.asset(image, width: 50),
          title: Text(item["title"]),
          onTap: () => query = item["title"],
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
  int currentIndex = 0;
  String selectedCategory = "All";
  List favorites = [];

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.electrical_services, "title": "Electrical"},
    {"icon": Icons.spa, "title": "Parfum"},
    {"icon": Icons.checkroom, "title": "Clothes"},
    {"icon": Icons.directions_run, "title": "Shoes"},
    {"icon": Icons.remove_red_eye, "title": "Glasses"},
    {"icon": Icons.more_horiz, "title": "Others"},
  ];

  final List<Map<String, dynamic>> bestSelling = [
    {
      "images": [
        "images/phone17.png",
        "images/phone17.png",
        "images/phone17.png",
      ],
      "title": "Iphone 17 Pro Max",
      "subtitle": "Original • High Quality",
      "price": "\$1000",
      "category": "Electrical",
    },
    {
      "images": ["images/watch.jpg", "images/watch.jpg", "images/watch.jpg"],
      "title": "Apple Watch S9",
      "subtitle": "Original • High Quality",
      "price": "\$700",
      "category": "Electrical",
    },
    {
      "images": ["images/shirt.jpg", "images/shirt.jpg", "images/shirt.jpg"],
      "title": "T-shirt Adidas",
      "subtitle": "Original • High Quality",
      "price": "\$300",
      "category": "Clothes",
    },
    {
      "images": ["images/adidas.jpg", "images/adidas.jpg", "images/adidas.jpg"],
      "title": "Espadrille Adidas",
      "subtitle": "Original • High Quality",
      "price": "\$300",
      "category": "Shoes",
    },
    {
      "images": ["images/rayban.jpg", "images/rayban.jpg", "images/rayban.jpg"],
      "title": "Glasses Rayban",
      "subtitle": "Original • High Quality",
      "price": "\$120",
      "category": "Glasses",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHomeContent(), CartPage(), const ProfilPage()];

    return Scaffold(
      body: SafeArea(child: pages[currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "",
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    final filteredProducts = selectedCategory == "All"
        ? bestSelling
        : bestSelling.where((p) => p["category"] == selectedCategory).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ===== Search Field =====
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

        // ===== Categories List =====
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

        // ===== Products Grid =====
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
            final item = filteredProducts[index];
            return _buildProductCard(item);
          },
        ),
      ],
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
    final image = item["images"][0];
    final isFav = favorites.contains(item);

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
                    tag: image,
                    child: Image.asset(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(
                        () => isFav
                            ? favorites.remove(item)
                            : favorites.add(item),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item["title"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item["subtitle"],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item["price"],
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
                      setState(() {});
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
