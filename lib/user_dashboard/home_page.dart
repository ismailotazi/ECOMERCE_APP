import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_service.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> products;

  ProductSearchDelegate({required this.products});

  String _getProductImage(Map<String, dynamic> item) {
    final List images = item["images"] is List ? item["images"] : [];

    if (images.isNotEmpty) {
      final image = images.first?.toString().trim() ?? "";

      if (image.isNotEmpty) {
        return image;
      }
    }

    return item["image"]?.toString().trim() ?? "";
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Theme.of(context).colorScheme.onSurface,
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final image = _getProductImage(item);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    image,
                    width: 55,
                    height: 55,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                )
              : const Icon(Icons.image_not_supported_outlined, size: 40),
          title: Text(
            item["name"]?.toString() ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            "\$${item["price"]?.toString() ?? "0"}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () {
            close(context, item);
          },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        final image = _getProductImage(item);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    image,
                    width: 55,
                    height: 55,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                )
              : const Icon(Icons.image_not_supported_outlined, size: 40),
          title: Text(
            item["name"]?.toString() ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () {
            close(context, item);
          },
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
  bool _guestCartLoaded = false;
  String selectedCategory = "all";
  final ScrollController _categoryScrollController = ScrollController();
  final List<Map<String, dynamic>> categories = [
    {
      "icon": Icons.phone_android,
      "key": "Smartphones",
      "titleKey": "smartphones",
    },
    {"icon": Icons.laptop_mac, "key": "Laptops", "titleKey": "laptops"},
    {"icon": Icons.tablet_mac, "key": "Tablets", "titleKey": "tablets"},
    {"icon": Icons.watch, "key": "Smartwatches", "titleKey": "smartwatches"},
    {"icon": Icons.headphones, "key": "Audio", "titleKey": "audio"},
    {"icon": Icons.sports_esports, "key": "Gaming", "titleKey": "gaming"},
    {"icon": Icons.tv, "key": "Electronics", "titleKey": "electronics"},
    {
      "icon": Icons.kitchen,
      "key": "Home Appliances",
      "titleKey": "homeAppliances",
    },
    {"icon": Icons.spa, "key": "Perfumes", "titleKey": "perfumes"},
    {
      "icon": Icons.face_retouching_natural,
      "key": "Beauty",
      "titleKey": "beauty",
    },
    {"icon": Icons.checkroom, "key": "Clothing", "titleKey": "clothing"},
    {"icon": Icons.directions_run, "key": "Shoes", "titleKey": "shoes"},
    {"icon": Icons.shopping_bag, "key": "Bags", "titleKey": "bags"},
    {"icon": Icons.remove_red_eye, "key": "Glasses", "titleKey": "glasses"},
    {"icon": Icons.watch_outlined, "key": "Watches", "titleKey": "watches"},
    {"icon": Icons.diamond, "key": "Jewelry", "titleKey": "jewelry"},
    {"icon": Icons.fitness_center, "key": "Sports", "titleKey": "sports"},
    {"icon": Icons.menu_book, "key": "Books", "titleKey": "books"},
    {"icon": Icons.toys, "key": "Toys", "titleKey": "toys"},
    {"icon": Icons.chair, "key": "Furniture", "titleKey": "furniture"},
    {"icon": Icons.restaurant, "key": "Food", "titleKey": "food"},
    {"icon": Icons.favorite, "key": "Health", "titleKey": "health"},
    {
      "icon": Icons.directions_car,
      "key": "Automotive",
      "titleKey": "automotive",
    },
    {"icon": Icons.more_horiz, "key": "Other", "titleKey": "other"},
  ];

  String _getCategoryTitle(AppLocalizations t, String key) {
    switch (key) {
      case "smartphones":
        return t.smartphones;
      case "laptops":
        return t.laptops;
      case "tablets":
        return t.tablets;
      case "smartwatches":
        return t.smartwatches;
      case "audio":
        return t.audio;
      case "gaming":
        return t.gaming;
      case "electronics":
        return t.electronics;
      case "homeAppliances":
        return t.homeAppliances;
      case "perfumes":
        return t.perfumes;
      case "beauty":
        return t.beauty;
      case "clothing":
        return t.clothing;
      case "shoes":
        return t.shoes;
      case "bags":
        return t.bags;
      case "glasses":
        return t.glasses;
      case "watches":
        return t.watches;
      case "jewelry":
        return t.jewelry;
      case "sports":
        return t.sports;
      case "books":
        return t.books;
      case "toys":
        return t.toys;
      case "furniture":
        return t.furniture;
      case "food":
        return t.food;
      case "health":
        return t.health;
      case "automotive":
        return t.automotive;
      case "other":
        return t.other;
      default:
        return key;
    }
  }

  late final Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();

    _productsStream = FirebaseFirestore.instance
        .collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots();
    _loadGuestCart();
  }

  Future<void> _loadGuestCart() async {
    if (FirebaseAuth.instance.currentUser != null) {
      _guestCartLoaded = true;
      return;
    }

    final savedCart = await CartStorage.loadCart();

    if (!mounted) return;

    cartItems.clear();
    cartItems.addAll(savedCart);

    setState(() {
      _guestCartLoaded = true;
    });
  }

  final FavoriteService _favoriteService = FavoriteService();
  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollCategories(bool forward) {
    if (!_categoryScrollController.hasClients) return;

    final position = _categoryScrollController.position;

    final target = forward ? position.pixels + 220 : position.pixels - 220;

    _categoryScrollController.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildHomeContent()));
  }

  Widget _buildHomeContent() {
    final t = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text(t.somethingWentWrong));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              t.noProductsFound,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        final products = snapshot.data!.docs.map((doc) {
          return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();

        final filteredProducts = selectedCategory == "all"
            ? products
            : products.where((p) => p["category"] == selectedCategory).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            int crossAxisCount;

            if (width < 600) {
              crossAxisCount = 2;
            } else if (width < 900) {
              crossAxisCount = 3;
            } else if (width < 1200) {
              crossAxisCount = 4;
            } else if (width < 1600) {
              crossAxisCount = 5;
            } else {
              crossAxisCount = 6;
            }

            final horizontalPadding = width >= 1200 ? 32.0 : 20.0;

            final spacing = width >= 900 ? 16.0 : 10.0;

            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              children: [
                // ==========================================================
                // SEARCH
                // ==========================================================
                InkWell(
                  onTap: () async {
                    final result = await showSearch<Map<String, dynamic>?>(
                      context: context,
                      delegate: ProductSearchDelegate(
                        products: filteredProducts,
                      ),
                    );

                    if (!mounted || result == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetails(data: result),
                      ),
                    );
                  },
                  child: TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: t.searchProducts,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================================
                // CATEGORIES
                // ==========================================================
                Text(
                  t.categories,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 10),
                SizedBox(
                  height: 125,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _categoryScrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: kIsWeb ? 48 : 16,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          itemBuilder: (context, index) {
                            final t = AppLocalizations.of(context)!;

                            if (index == 0) {
                              return _buildCategoryItem(
                                "all",
                                t.all,
                                Icons.apps,
                              );
                            }

                            final cat = categories[index - 1];

                            return _buildCategoryItem(
                              cat["key"],
                              _getCategoryTitle(t, cat["titleKey"]),
                              cat["icon"],
                            );
                          },
                        ),

                        // LEFT ARROW - WEB ONLY
                        if (kIsWeb)
                          Positioned(
                            left: 4,
                            top: 30,
                            child: Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _scrollCategories(false),
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // RIGHT ARROW - WEB ONLY
                        if (kIsWeb)
                          Positioned(
                            right: 4,
                            top: 30,
                            child: Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _scrollCategories(true),
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ==========================================================
                // BEST SELLING
                // ==========================================================
                Text(
                  t.bestSelling,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 10),

                // ==========================================================
                // RESPONSIVE PRODUCTS GRID
                // ==========================================================
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,

                    // Responsive card height
                    childAspectRatio: width < 600
                        ? 0.70
                        : width < 900
                        ? 0.76
                        : width < 1200
                        ? 0.80
                        : 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return _buildProductCard(filteredProducts[index]);
                  },
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryItem(String categoryKey, String title, IconData icon) {
    final isSelected = selectedCategory == categoryKey;
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    final double circleSize;
    final double iconSize;
    final double itemWidth;
    final double fontSize;

    if (width < 600) {
      // PHONE
      circleSize = 58;
      iconSize = 25;
      itemWidth = 72;
      fontSize = 11.5;
    } else if (width < 900) {
      // TABLET
      circleSize = 62;
      iconSize = 27;
      itemWidth = 76;
      fontSize = 12;
    } else {
      // WEB / DESKTOP
      circleSize = 68;
      iconSize = 29;
      itemWidth = 82;
      fontSize = 12.5;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = categoryKey;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final t = AppLocalizations.of(context)!;

    final List images = item["images"] is List ? item["images"] : [];

    final String image = images.isNotEmpty
        ? images.first.toString()
        : (item["image"]?.toString() ?? "");

    final productId = item["id"].toString();

    final rating = (item["rating"] as num?)?.toDouble() ?? 0.0;

    final reviewsCount = (item["reviewsCount"] as num?)?.toInt() ?? 0;

    final double price = (item["price"] as num?)?.toDouble() ?? 0;

    final double oldPrice = (item["oldPrice"] as num?)?.toDouble() ?? 0;

    final int discount = oldPrice > 0 && price < oldPrice
        ? (((oldPrice - price) / oldPrice) * 100).round()
        : 0;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // IMAGE
              // ==========================================================
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Hero(
                      tag: "product_${item["id"]}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) {
                                        return child;
                                      }

                                      return Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, _, _) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // ======================================================
                    // DISCOUNT
                    // ======================================================
                    if (discount > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "-$discount%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ======================================================
                    // FAVORITE
                    // ======================================================
                    Positioned(
                      top: 5,
                      right: 5,
                      child: StreamBuilder<bool>(
                        stream: _favoriteService.isFavorite(productId),
                        builder: (context, snapshot) {
                          final isFav = snapshot.data ?? false;

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(7),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav
                                    ? AppColors.error
                                    : Theme.of(context).colorScheme.outline,
                                size: 20,
                              ),
                              onPressed: () async {
                                await _favoriteService.toggleFavorite(
                                  productId,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              // ==========================================================
              // NAME
              // ==========================================================
              Text(
                item["name"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              // ==========================================================
              // DESCRIPTION
              // ==========================================================
              Text(
                item["description"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 5),

              // ==========================================================
              // RATING
              // ==========================================================
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      "($reviewsCount)",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // ==========================================================
              // PRICE + CART
              // ==========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "\$${item["price"]}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  GestureDetector(
                    onTap: () async {
                      if (!_guestCartLoaded) {
                        return;
                      }

                      final productId = item["id"].toString();

                      final alreadyInCart = cartItems.any(
                        (cartItem) => cartItem["id"]?.toString() == productId,
                      );

                      if (alreadyInCart) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            content: Text(
                              t.alreadyInCart,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );

                        return;
                      }

                      cartItems.add({
                        "id": item["id"],
                        "name": item["name"],
                        "price": item["price"],
                        "oldPrice": item["oldPrice"],
                        "image": image,
                        "quantity": 1,
                      });

                      await CartStorage.saveCart(cartItems);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          content: Text(
                            t.addedToCart,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        color: Theme.of(context).colorScheme.onPrimary,
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

// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/services/cart_data.dart';
// import 'package:ecomerce_app/services/cart_storage.dart';
// import 'package:ecomerce_app/services/favorite_service.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/user_dashboard/item_details.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// class ProductSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
//   final List<Map<String, dynamic>> products;

//   ProductSearchDelegate({required this.products});

//   String _getProductImage(Map<String, dynamic> item) {
//     final List images = item["images"] is List ? item["images"] : [];

//     if (images.isNotEmpty) {
//       final image = images.first?.toString().trim() ?? "";

//       if (image.isNotEmpty) {
//         return image;
//       }
//     }

//     return item["image"]?.toString().trim() ?? "";
//   }

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(
//         Icons.arrow_back_ios_new_rounded,
//         color: Theme.of(context).colorScheme.onSurface,
//       ),
//       onPressed: () => close(context, null),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     final results = products
//         .where(
//           (p) => (p["name"] ?? "").toString().toLowerCase().contains(
//             query.toLowerCase(),
//           ),
//         )
//         .toList();

//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final item = results[index];
//         final image = _getProductImage(item);

//         return ListTile(
//           leading: image.isNotEmpty
//               ? Image.network(
//                   image,
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, _, _) =>
//                       const Icon(Icons.image_not_supported_outlined),
//                 )
//               : const Icon(Icons.image_not_supported_outlined, size: 40),

//           title: Text(
//             item["name"]?.toString() ?? "",
//             style: Theme.of(context).textTheme.titleMedium,
//           ),

//           subtitle: Text(
//             item["price"]?.toString() ?? "0",
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),

//           onTap: () {
//             close(context, item);
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = products
//         .where(
//           (p) => (p["name"] ?? "").toString().toLowerCase().contains(
//             query.toLowerCase(),
//           ),
//         )
//         .toList();

//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final item = suggestions[index];
//         final image = _getProductImage(item);

//         return ListTile(
//           leading: image.isNotEmpty
//               ? Image.network(
//                   image,
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, _, _) =>
//                       const Icon(Icons.image_not_supported_outlined),
//                 )
//               : const Icon(Icons.image_not_supported_outlined, size: 40),

//           title: Text(
//             item["name"]?.toString() ?? "",
//             style: Theme.of(context).textTheme.titleMedium,
//           ),

//           onTap: () {
//             close(context, item);
//           },
//         );
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String selectedCategory = "all";

//   final List<Map<String, dynamic>> categories = [
//     {
//       "icon": Icons.phone_android,
//       "key": "Smartphones",
//       "titleKey": "smartphones",
//     },
//     {"icon": Icons.laptop_mac, "key": "Laptops", "titleKey": "laptops"},
//     {"icon": Icons.tablet_mac, "key": "Tablets", "titleKey": "tablets"},
//     {"icon": Icons.watch, "key": "Smartwatches", "titleKey": "smartwatches"},
//     {"icon": Icons.headphones, "key": "Audio", "titleKey": "audio"},
//     {"icon": Icons.sports_esports, "key": "Gaming", "titleKey": "gaming"},
//     {"icon": Icons.tv, "key": "Electronics", "titleKey": "electronics"},
//     {
//       "icon": Icons.kitchen,
//       "key": "Home Appliances",
//       "titleKey": "homeAppliances",
//     },
//     {"icon": Icons.spa, "key": "Perfumes", "titleKey": "perfumes"},
//     {
//       "icon": Icons.face_retouching_natural,
//       "key": "Beauty",
//       "titleKey": "beauty",
//     },
//     {"icon": Icons.checkroom, "key": "Clothing", "titleKey": "clothing"},
//     {"icon": Icons.directions_run, "key": "Shoes", "titleKey": "shoes"},
//     {"icon": Icons.shopping_bag, "key": "Bags", "titleKey": "bags"},
//     {"icon": Icons.remove_red_eye, "key": "Glasses", "titleKey": "glasses"},
//     {"icon": Icons.watch_outlined, "key": "Watches", "titleKey": "watches"},
//     {"icon": Icons.diamond, "key": "Jewelry", "titleKey": "jewelry"},
//     {"icon": Icons.fitness_center, "key": "Sports", "titleKey": "sports"},
//     {"icon": Icons.menu_book, "key": "Books", "titleKey": "books"},
//     {"icon": Icons.toys, "key": "Toys", "titleKey": "toys"},
//     {"icon": Icons.chair, "key": "Furniture", "titleKey": "furniture"},
//     {"icon": Icons.restaurant, "key": "Food", "titleKey": "food"},
//     {"icon": Icons.favorite, "key": "Health", "titleKey": "health"},
//     {
//       "icon": Icons.directions_car,
//       "key": "Automotive",
//       "titleKey": "automotive",
//     },
//     {"icon": Icons.more_horiz, "key": "Other", "titleKey": "other"},
//   ];
//   String _getCategoryTitle(AppLocalizations t, String key) {
//     switch (key) {
//       case "smartphones":
//         return t.smartphones;
//       case "laptops":
//         return t.laptops;
//       case "tablets":
//         return t.tablets;
//       case "smartwatches":
//         return t.smartwatches;
//       case "audio":
//         return t.audio;
//       case "gaming":
//         return t.gaming;
//       case "electronics":
//         return t.electronics;
//       case "homeAppliances":
//         return t.homeAppliances;
//       case "perfumes":
//         return t.perfumes;
//       case "beauty":
//         return t.beauty;
//       case "clothing":
//         return t.clothing;
//       case "shoes":
//         return t.shoes;
//       case "bags":
//         return t.bags;
//       case "glasses":
//         return t.glasses;
//       case "watches":
//         return t.watches;
//       case "jewelry":
//         return t.jewelry;
//       case "sports":
//         return t.sports;
//       case "books":
//         return t.books;
//       case "toys":
//         return t.toys;
//       case "furniture":
//         return t.furniture;
//       case "food":
//         return t.food;
//       case "health":
//         return t.health;
//       case "automotive":
//         return t.automotive;
//       case "other":
//         return t.other;
//       default:
//         return key;
//     }
//   }

//   final FavoriteService _favoriteService = FavoriteService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: SafeArea(child: _buildHomeContent()));
//   }

//   Widget _buildHomeContent() {
//     final t = AppLocalizations.of(context)!;
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection("products")
//           .orderBy("createdAt", descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text(t.somethingWentWrong));
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(
//               t.noProductsFound,
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           );
//         }

//         final products = snapshot.data!.docs.map((doc) {
//           return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
//         }).toList();

//         final filteredProducts = selectedCategory == "all"
//             ? products
//             : products.where((p) => p["category"] == selectedCategory).toList();

//         return ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             // ===== Search =====
//             InkWell(
//               onTap: () async {
//                 final result = await showSearch<Map<String, dynamic>?>(
//                   context: context,
//                   delegate: ProductSearchDelegate(products: filteredProducts),
//                 );

//                 if (!mounted || result == null) return;

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => ItemDetails(data: result)),
//                 );
//               },
//               child: TextFormField(
//                 enabled: false,
//                 decoration: InputDecoration(
//                   hintText: t.searchProducts,
//                   prefixIcon: const Icon(Icons.search),
//                   filled: true,
//                   fillColor: Theme.of(
//                     context,
//                   ).colorScheme.surfaceContainerHighest,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             Text(t.categories, style: Theme.of(context).textTheme.titleLarge),

//             const SizedBox(height: 10),

//             SizedBox(
//               height: 100,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length + 1,
//                 itemBuilder: (context, index) {
//                   final t = AppLocalizations.of(context)!;

//                   if (index == 0) {
//                     return _buildCategoryItem("all", t.all, Icons.apps);
//                   }

//                   final cat = categories[index - 1];

//                   return _buildCategoryItem(
//                     cat["key"],
//                     _getCategoryTitle(t, cat["titleKey"]),
//                     cat["icon"],
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             Text(t.bestSelling, style: Theme.of(context).textTheme.titleLarge),

//             const SizedBox(height: 10),

//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: filteredProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisExtent: 270,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemBuilder: (context, index) {
//                 return _buildProductCard(filteredProducts[index]);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCategoryItem(String categoryKey, String title, IconData icon) {
//     final isSelected = selectedCategory == categoryKey;

//     return Padding(
//       padding: const EdgeInsets.only(right: 12),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = categoryKey;
//               });
//             },
//             child: CircleAvatar(
//               radius: 35,
//               backgroundColor: isSelected
//                   ? AppColors.primary
//                   : Theme.of(context).colorScheme.surfaceContainerHighest,
//               child: Icon(
//                 icon,
//                 color: isSelected
//                     ? Theme.of(context).colorScheme.onPrimary
//                     : Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(title, style: Theme.of(context).textTheme.bodySmall),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductCard(Map<String, dynamic> item) {
//     final t = AppLocalizations.of(context)!;
//     final List images = item["images"] is List ? item["images"] : [];
//     final String image = images.isNotEmpty
//         ? images.first.toString()
//         : (item["image"]?.toString() ?? "");

//     final productId = item["id"];

//     final rating = (item["rating"] as num?)?.toDouble() ?? 0.0;

//     final reviewsCount = (item["reviewsCount"] as num?)?.toInt() ?? 0;

//     final double price = (item["price"] as num?)?.toDouble() ?? 0;

//     final double oldPrice = (item["oldPrice"] as num?)?.toDouble() ?? 0;

//     final int discount = oldPrice > 0 && price < oldPrice
//         ? (((oldPrice - price) / oldPrice) * 100).round()
//         : 0;
//     return InkWell(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
//       ),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Hero(
//                     tag: "product_${item["id"]}",
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Container(
//                         height: 145,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.surfaceContainerHighest,
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(14),
//                           child: image.isNotEmpty
//                               ? Image.network(
//                                   image,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.contain,
//                                   gaplessPlayback: true,
//                                   loadingBuilder: (context, child, progress) {
//                                     if (progress == null) return child;

//                                     return Center(
//                                       child: SizedBox(
//                                         width: 22,
//                                         height: 22,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Theme.of(
//                                             context,
//                                           ).colorScheme.primary,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (_, _, _) {
//                                     return Center(
//                                       child: Icon(
//                                         Icons.image_not_supported_outlined,
//                                         size: 40,
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.outline,
//                                       ),
//                                     );
//                                   },
//                                 )
//                               : Center(
//                                   child: Icon(
//                                     Icons.image_not_supported_outlined,
//                                     size: 40,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.outline,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (discount > 0)
//                     Positioned(
//                       top: 6,
//                       left: 6,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 9,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.error,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.18),
//                               blurRadius: 6,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.local_offer_rounded,
//                               size: 14,
//                               color: Colors.white,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               "-$discount%",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: StreamBuilder<bool>(
//                       stream: _favoriteService.isFavorite(productId),
//                       builder: (context, snapshot) {
//                         final isFav = snapshot.data ?? false;

//                         return Container(
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).colorScheme.surface,
//                             shape: BoxShape.circle,
//                           ),
//                           child: IconButton(
//                             icon: Icon(
//                               isFav ? Icons.favorite : Icons.favorite_border,
//                               color: isFav
//                                   ? AppColors.error
//                                   : Theme.of(context).colorScheme.outline,
//                             ),
//                             onPressed: () async {
//                               await _favoriteService.toggleFavorite(productId);
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 8),

//               Text(
//                 item["name"] ?? "",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),

//               Text(
//                 item["description"] ?? "",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),

//               const SizedBox(height: 6),

//               Row(
//                 children: [
//                   const Icon(Icons.star_rounded, color: Colors.amber, size: 16),

//                   const SizedBox(width: 4),

//                   Text(
//                     rating.toStringAsFixed(1),
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),

//                   const SizedBox(width: 4),

//                   Text(
//                     "($reviewsCount)",
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Theme.of(context).colorScheme.outline,
//                     ),
//                   ),
//                 ],
//               ),

//               const Spacer(),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "\$${item["price"]}",
//                     style: TextStyle(
//                       color: AppColors.success,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       final productId = item["id"].toString();

//                       final alreadyInCart = cartItems.any(
//                         (cartItem) => cartItem["id"].toString() == productId,
//                       );

//                       if (alreadyInCart) {
//                         if (!mounted) return;

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             backgroundColor: Theme.of(
//                               context,
//                             ).colorScheme.surface,
//                             content: Text(
//                               t.alreadyInCart,
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.onSurface,
//                               ),
//                             ),
//                           ),
//                         );

//                         return;
//                       }

//                       cartItems.add({
//                         "id": item["id"],
//                         "name": item["name"],
//                         "price": item["price"],
//                         "oldPrice": item["oldPrice"],
//                         "image": image,
//                         "quantity": 1,
//                       });

//                       await CartStorage.saveCart(cartItems);

//                       if (!mounted) return;

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           backgroundColor: Theme.of(
//                             context,
//                           ).colorScheme.surface,
//                           content: Text(
//                             t.addedToCart,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primary,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         Icons.add_shopping_cart,
//                         color: Theme.of(context).colorScheme.onPrimary,
//                         size: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
