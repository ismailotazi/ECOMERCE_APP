import 'package:ecomerce_app/cart_data.dart';
import 'package:ecomerce_app/cart_page.dart';
import 'package:ecomerce_app/item_details.dart';
import 'package:ecomerce_app/profil_page.dart';
import 'package:flutter/material.dart';

// -----------------
// Search Delegate
// -----------------
class ProductSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> products;
  ProductSearchDelegate({required this.products});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where((p) => p["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Image.asset(item["image"], width: 50),
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
        return ListTile(
          leading: Image.asset(item["image"], width: 50),
          title: Text(item["title"]),
          onTap: () => query = item["title"],
        );
      },
    );
  }
}

// -----------------
// Home Page
// -----------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  String selectedCategory = "All";

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.electrical_services, "title": "Electrical"},
    {"icon": Icons.spa, "title": "Parfum"},
    {"icon": Icons.checkroom, "title": "Clothes"},
    {"icon": Icons.directions_run, "title": "Shoes"},
    {"icon": Icons.remove_red_eye, "title": "Glasses"},
  ];

  final List<Map<String, dynamic>> bestSelling = [
    {
      "image": "images/phone17.png",
      "title": "Iphone 17 Pro Max",
      "subtitle": "Original • High Quality",
      "price": "\$1000",
      "category": "Electrical",
    },
    {
      "image": "images/watch.jpg",
      "title": "Apple Watch S9",
      "subtitle": "Original • High Quality",
      "price": "\$700",
      "category": "Electrical",
    },
    {
      "image": "images/shirt.jpg",
      "title": "T-shirt Adidas",
      "subtitle": "Original • High Quality",
      "price": "\$300",
      "category": "Clothes",
    },
    {
      "image": "images/adidas.jpg",
      "title": "Espadrille Adidas",
      "subtitle": "Original • High Quality",
      "price": "\$300",
      "category": "Shoes",
    },
    {
      "image": "images/rayban.jpg",
      "title": "Glasses Rayban",
      "subtitle": "Original • High Quality",
      "price": "\$120",
      "category": "Glasses",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      CartPage(data: {}),
      const ProfilPage(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.orange,
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
      body: SafeArea(child: pages[currentIndex]),
    );
  }

  Widget _buildHomeContent() {
    // Filter products
    List<Map<String, dynamic>> filteredProducts = selectedCategory == "All"
        ? bestSelling
        : bestSelling.where((p) => p["category"] == selectedCategory).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 🔍 Search Field
        InkWell(
          onTap: () {
            showSearch(
              context: context,
              delegate: ProductSearchDelegate(products: filteredProducts),
            );
          },
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

        // Categories
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
                // All button
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => selectedCategory = "All"),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: selectedCategory == "All"
                              ? Colors.orange
                              : Colors.grey[200],
                          child: const Icon(
                            Icons.apps,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "All",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              } else {
                final category = categories[index - 1]["title"];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: selectedCategory == category
                              ? Colors.orange
                              : Colors.grey[200],
                          child: Icon(
                            categories[index - 1]["icon"],
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 20),

        // Best Selling Grid
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
            mainAxisExtent: 250,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = filteredProducts[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
              ),
              child: Hero(
                tag: item["image"],
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            item["image"],
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          item["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          item["subtitle"],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          item["price"],
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
