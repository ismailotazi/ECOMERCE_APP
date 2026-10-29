import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/cart_firestore.dart';

import 'package:ecomerce_app/services/favorite_service.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final t = AppLocalizations.of(context)!;
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
            "${item["price"]?.toString() ?? "0"} ${t.currencySymbol}",
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
  final String? storeId;

  const HomePage({super.key, required this.storeId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? storeName;
  String? storeLogoUrl;
  String? whatsappNumber;
  String selectedCategory = "all";
  String selectedSubcategory = "all";
  final Map<String, List<String>> subcategories = {
    'smartphones': ['Android Phones', 'iPhones', 'Phone Accessories', 'Other'],
    'computers': [
      'Laptops',
      'Desktop Computers',
      'Computer Accessories',
      'Monitors',
      'Printers',
      'Other',
    ],
    'electronics': [
      'Televisions',
      'Audio',
      'Cameras',
      'Smart Home',
      'Electronic Accessories',
      'Other',
    ],
    'perfumes': ['Women', 'Men', 'Kids', 'Unisex', 'Other'],
    'accessories': [
      'Watches',
      'Jewelry',
      'Sunglasses',
      'Bags',
      'Wallets',
      'Other',
    ],
    'gold': [
      'Rings',
      'Necklaces',
      'Bracelets',
      'Anklets',
      'Earrings',
      'Gold Chains',
      'Pendants',
      'Gold Sets',
      'Crowns & Tiaras',
      'Other Gold Jewelry',
    ],

    'silver': [
      'Rings',
      'Necklaces',
      'Bracelets',
      'Anklets',
      'Earrings',
      'Silver Chains',
      'Pendants',
      'Silver Sets',
      'Other Silver Jewelry',
    ],
    'fashion': ['Women', 'Men', 'Kids', 'Shoes', 'Bags', 'Other'],
    'beauty': ['Skincare', 'Makeup', 'Hair Care', 'Body Care', 'Other'],
    'furniture': [
      'Living Room',
      'Bedroom',
      'Office',
      'Kitchen',
      'Outdoor Furniture',
      'Other',
    ],
    'sports': [
      'Fitness',
      'Training',
      'Sportswear',
      'Sports Equipment',
      'Other',
    ],
    'gaming': ['Consoles', 'Games', 'Gaming Accessories', 'Other'],
    // 'other': ['Other Products'],
  };
  final ScrollController _categoryScrollController = ScrollController();
  final List<Map<String, dynamic>> categories = [
    {
      "icon": FontAwesomeIcons.mobileScreenButton,
      "key": "Smartphones",
      "titleKey": "smartphones",
    },
    {
      "icon": FontAwesomeIcons.laptop,
      "key": "Computers",
      "titleKey": "computers",
    },
    {
      "icon": FontAwesomeIcons.tv,
      "key": "Electronics",
      "titleKey": "electronics",
    },
    {"icon": FontAwesomeIcons.gamepad, "key": "Gaming", "titleKey": "gaming"},
    {"icon": FontAwesomeIcons.shirt, "key": "Fashion", "titleKey": "fashion"},
    {"icon": FontAwesomeIcons.spa, "key": "Beauty", "titleKey": "beauty"},
    {
      "icon": FontAwesomeIcons.sprayCanSparkles,
      "key": "Perfumes",
      "titleKey": "perfumes",
    },
    {"icon": FontAwesomeIcons.gem, "key": "Gold", "titleKey": "gold"},
    {"icon": FontAwesomeIcons.coins, "key": "Silver", "titleKey": "silver"},
    {
      "icon": FontAwesomeIcons.couch,
      "key": "Furniture",
      "titleKey": "furniture",
    },
    {"icon": FontAwesomeIcons.dumbbell, "key": "Sports", "titleKey": "sports"},
    {
      "icon": FontAwesomeIcons.bagShopping,
      "key": "Accessories",
      "titleKey": "accessories",
    },
    {"icon": FontAwesomeIcons.ellipsis, "key": "Other", "titleKey": "other"},
  ];

  // Translate main categories
  String _getCategoryTitle(AppLocalizations t, String categoryKey) {
    switch (categoryKey.toLowerCase()) {
      case 'smartphones':
        return t.smartphones;
      case 'computers':
        return t.computers;
      case 'electronics':
        return t.electronics;
      case 'gaming':
        return t.gaming;
      case 'fashion':
        return t.fashion;
      case 'gold':
        return t.gold;

      case 'silver':
        return t.silver;

      case 'beauty':
        return t.beauty;
      case 'perfumes':
        return t.perfumes;
      case 'furniture':
        return t.furniture;
      case 'sports':
        return t.sports;
      case 'accessories':
        return t.accessories;
      case 'other':
        return t.other;
      default:
        return categoryKey;
    }
  }

  // Translate subcategories
  String _getSubcategoryTitle(AppLocalizations t, String subcategory) {
    switch (subcategory.toLowerCase()) {
      case 'android phones':
        return t.androidPhones;
      case 'iphones':
        return t.iphones;
      case 'phone accessories':
        return t.phoneAccessories;
      case 'laptops':
        return t.laptops;
      case 'desktop computers':
        return t.desktopComputers;
      case 'computer accessories':
        return t.computerAccessories;
      case 'monitors':
        return t.monitors;
      case 'printers':
        return t.printers;
      case 'televisions':
        return t.televisions;
      case 'audio':
        return t.audio;
      case 'cameras':
        return t.cameras;
      case 'smart home':
        return t.smartHome;
      case 'electronic accessories':
        return t.electronicAccessories;
      case 'women':
        return t.women;
      case 'men':
        return t.men;
      case 'kids':
        return t.kids;
      case 'unisex':
        return t.unisex;
      case 'watches':
        return t.watches;
      case 'jewelry':
        return t.jewelry;
      case 'sunglasses':
        return t.sunglasses;
      case 'bags':
        return t.bags;
      case 'wallets':
        return t.wallets;
      case 'shoes':
        return t.shoes;
      case 'skincare':
        return t.skincare;
      case 'rings':
        return t.rings;
      case 'necklaces':
        return t.necklaces;
      case 'bracelets':
        return t.bracelets;
      case 'anklets':
        return t.anklets;
      case 'earrings':
        return t.earrings;
      case 'gold chains':
        return t.goldChains;
      case 'silver chains':
        return t.silverChains;
      case 'pendants':
        return t.pendants;
      case 'gold sets':
        return t.goldSets;
      case 'silver sets':
        return t.silverSets;
      case 'crowns & tiaras':
        return t.crownsAndTiaras;
      case 'other gold jewelry':
        return t.otherGoldJewelry;
      case 'other silver jewelry':
        return t.otherSilverJewelry;
      case 'makeup':
        return t.makeup;
      case 'hair care':
        return t.hairCare;
      case 'body care':
        return t.bodyCare;
      case 'living room':
        return t.livingRoom;
      case 'bedroom':
        return t.bedroom;
      case 'office':
        return t.office;
      case 'kitchen':
        return t.kitchen;
      case 'outdoor furniture':
        return t.outdoorFurniture;
      case 'fitness':
        return t.fitness;
      case 'training':
        return t.training;
      case 'sportswear':
        return t.sportswear;
      case 'sports equipment':
        return t.sportsEquipment;
      case 'consoles':
        return t.consoles;
      case 'games':
        return t.games;
      case 'gaming accessories':
        return t.gamingAccessories;
      case 'other':
        return t.other;
      case 'other products':
        return t.otherProducts;
      default:
        return subcategory;
    }
  }

  Stream<List<String>> _storeCategoriesStream() {
    final storeId = widget.storeId;

    if (storeId == null || storeId.isEmpty) {
      return Stream.value(<String>[]);
    }

    final validCategoryKeys = categories
        .map((category) => category['titleKey'] as String)
        .toSet();

    return FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .snapshots()
        .map((storeDoc) {
          final savedCategories = storeDoc.data()?['categories'];

          if (savedCategories is! List) {
            return <String>[];
          }

          return savedCategories
              .whereType<String>()
              .where((category) => validCategoryKeys.contains(category))
              .toSet()
              .toList();
        });
  }

  Future<void> _loadStoreInfo() async {
    final storeId = widget.storeId;

    if (storeId == null || storeId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("stores")
          .doc(storeId)
          .get();

      if (!mounted || !doc.exists) return;

      final data = doc.data();

      setState(() {
        storeName = data?["name"]?.toString();
        storeLogoUrl = data?["logoUrl"]?.toString();
        whatsappNumber = data?["whatsappNumber"]?.toString();
      });
    } catch (e) {
      debugPrint("Error loading store info: $e");
    }
  }

  Future<void> _openWhatsApp() async {
    final number = whatsappNumber?.trim() ?? "";

    if (number.isEmpty) return;

    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    final uri = Uri.parse("https://wa.me/$cleanNumber");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();

    _loadStoreInfo();
  }

  final FavoriteService _favoriteService = FavoriteService();
  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  Widget _buildStoreHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    final name = storeName?.trim().isNotEmpty == true
        ? storeName!.trim()
        : "Store";

    final logo = storeLogoUrl?.trim() ?? "";

    return Row(
      children: [
        // STORE LOGO
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(13),
            ),
            clipBehavior: Clip.antiAlias,
            child: logo.isNotEmpty
                ? Image.network(
                    logo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.storefront_rounded,
                      size: 23,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.storefront_rounded,
                    size: 23,
                    color: colorScheme.primary,
                  ),
          ),
        ),

        const SizedBox(width: 12),

        // STORE NAME
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),

        const SizedBox(width: 6),

        // VERIFIED
        Icon(Icons.verified_rounded, size: 20, color: colorScheme.primary),
        // SEARCH
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildHomeContent()),
      floatingActionButton: whatsappNumber?.trim().isNotEmpty == true
          ? FloatingActionButton(
              onPressed: _openWhatsApp,
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const FaIcon(FontAwesomeIcons.whatsapp, size: 28),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    final t = AppLocalizations.of(context)!;

    return StreamBuilder<List<String>>(
      stream: _storeCategoriesStream(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.hasError) {
          return Center(child: Text(t.somethingWentWrong));
        }

        if (categorySnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        final currentCategories = categorySnapshot.data ?? <String>[];

        const categoryOrder = [
          'gold',
          'silver',
          'smartphones',
          'computers',
          'electronics',
          'gaming',
          'fashion',
          'beauty',
          'perfumes',
          'furniture',
          'sports',
          'accessories',
          'other',
        ];

        currentCategories.sort((a, b) {
          final indexA = categoryOrder.indexOf(a.toLowerCase());
          final indexB = categoryOrder.indexOf(b.toLowerCase());

          final orderA = indexA == -1 ? categoryOrder.length : indexA;
          final orderB = indexB == -1 ? categoryOrder.length : indexB;

          return orderA.compareTo(orderB);
        });
        // Reset selection if its category or subcategory is no longer available.
        final selectedCategoryKey = selectedCategory.trim().toLowerCase();

        final selectedCategoryExists = currentCategories.any(
          (category) => category.trim().toLowerCase() == selectedCategoryKey,
        );

        final selectedSubcategoryExists =
            selectedCategory == "all" ||
            (subcategories[selectedCategoryKey]?.any(
                  (subcategory) =>
                      subcategory.toLowerCase() ==
                      selectedSubcategory.trim().toLowerCase(),
                ) ??
                false);

        if (selectedCategory != "all" &&
            (!selectedCategoryExists || !selectedSubcategoryExists)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            final latestCategoryExists = currentCategories.any(
              (category) =>
                  category.trim().toLowerCase() ==
                  selectedCategory.trim().toLowerCase(),
            );

            if (selectedCategory != "all" && !latestCategoryExists) {
              setState(() {
                selectedCategory = "all";
                selectedSubcategory = "all";
              });
            }
          });
        }

        return StreamBuilder<QuerySnapshot>(
          stream: widget.storeId == null || widget.storeId!.isEmpty
              ? const Stream<QuerySnapshot>.empty()
              : FirebaseFirestore.instance
                    .collection("products")
                    .where("storeId", isEqualTo: widget.storeId)
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
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

            final allProducts = snapshot.data!.docs.map((doc) {
              return {"id": doc.id, ...doc.data() as Map<String, dynamic>};
            }).toList();

            // Show only products belonging to enabled store categories.
            final allowedCategorySet = currentCategories
                .map((category) => category.trim().toLowerCase())
                .toSet();

            final products = allProducts.where((product) {
              final category =
                  product["category"]?.toString().trim().toLowerCase() ?? "";

              return allowedCategorySet.contains(category);
            }).toList();

            final normalizedSelectedCategory = selectedCategory
                .trim()
                .toLowerCase();

            final categoryFilteredProducts = normalizedSelectedCategory == "all"
                ? products
                : products.where((product) {
                    final productCategory =
                        product["category"]?.toString().trim().toLowerCase() ??
                        "";

                    return productCategory == normalizedSelectedCategory;
                  }).toList();

            final normalizedSelectedSubcategory = selectedSubcategory
                .trim()
                .toLowerCase();

            final filteredProducts = normalizedSelectedSubcategory == "all"
                ? categoryFilteredProducts
                : categoryFilteredProducts.where((product) {
                    final productSubcategory =
                        product["subcategory"]
                            ?.toString()
                            .trim()
                            .toLowerCase() ??
                        "";

                    return productSubcategory == normalizedSelectedSubcategory;
                  }).toList();

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
                    _buildStoreHeader(),
                    const SizedBox(height: 15),

                    // SEARCH
                    InkWell(
                      onTap: () async {
                        final result = await showSearch<Map<String, dynamic>?>(
                          context: context,
                          delegate: ProductSearchDelegate(
                            products: filteredProducts,
                          ),
                        );

                        if (!context.mounted || result == null) return;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetails(
                                data: result,
                                storeId: widget.storeId,
                              ),
                            ),
                          );
                        });
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

                    const SizedBox(height: 15),

                    // ============================================================
                    // PREMIUM CATEGORY SELECTOR
                    // ============================================================
                    if (currentCategories.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      // CATEGORY TITLE
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 21,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            t.category,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // HORIZONTAL CATEGORIES
                      SizedBox(
                        height: 82,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: currentCategories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final isAll = index == 0;

                            final categoryKey = isAll
                                ? 'all'
                                : currentCategories[index - 1]
                                      .trim()
                                      .toLowerCase();

                            final categoryInfo = isAll
                                ? <String, dynamic>{}
                                : categories.firstWhere(
                                    (category) =>
                                        category['titleKey'] == categoryKey,
                                    orElse: () => <String, dynamic>{},
                                  );

                            final FaIconData? categoryIcon = isAll
                                ? null
                                : categoryInfo['icon'] as FaIconData?;

                            final title = isAll
                                ? t.all
                                : _getCategoryTitle(t, categoryKey);

                            final isSelected = selectedCategory == categoryKey;

                            final colorScheme = Theme.of(context).colorScheme;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = categoryKey;
                                  selectedSubcategory = 'all';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                width: 70,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withValues(
                                          alpha: 0.09,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(17),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.65,
                                          )
                                        : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 43,
                                      height: 43,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  colorScheme.primary,
                                                  colorScheme.primary
                                                      .withValues(alpha: 0.75),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : colorScheme
                                                  .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.20),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: isAll
                                            ? Icon(
                                                Icons.grid_view_rounded,
                                                size: 21,
                                                color: isSelected
                                                    ? colorScheme.onPrimary
                                                    : colorScheme
                                                          .onSurfaceVariant,
                                              )
                                            : FaIcon(
                                                categoryIcon ??
                                                    FontAwesomeIcons.ellipsis,
                                                size: 19,
                                                color: isSelected
                                                    ? colorScheme.onPrimary
                                                    : colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 10.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // SUBCATEGORIES: ONLY FOR THE SELECTED CATEGORY
                      if (selectedCategory != 'all' &&
                          selectedCategory != 'other' &&
                          (subcategories[selectedCategory] ?? [])
                              .isNotEmpty) ...[
                        const SizedBox(height: 12),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            key: ValueKey(selectedCategory),
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  (subcategories[selectedCategory] ?? [])
                                      .length +
                                  1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final items = subcategories[selectedCategory]!;
                                final subcategory = index == 0
                                    ? 'all'
                                    : items[index - 1];

                                final isSelected =
                                    selectedSubcategory.toLowerCase() ==
                                    subcategory.toLowerCase();

                                final colorScheme = Theme.of(
                                  context,
                                ).colorScheme;

                                return ChoiceChip(
                                  label: Text(
                                    subcategory == 'all'
                                        ? t.all
                                        : _getSubcategoryTitle(t, subcategory),
                                  ),
                                  selected: isSelected,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    setState(() {
                                      selectedSubcategory = subcategory;
                                    });
                                  },
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  selectedColor: colorScheme.primary,
                                  side: BorderSide(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant.withValues(
                                            alpha: 0.4,
                                          ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),
                    ],

                    // BEST SELLING
                    Text(
                      t.bestSelling,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 10),

                    // RESPONSIVE PRODUCTS GRID
                    if (filteredProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            t.noProductsFound,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
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
      },
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetails(data: item, storeId: widget.storeId),
          ),
        );
      },
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
                                final user = FirebaseAuth.instance.currentUser;

                                // Guest: redirect to Login
                                if (user == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LoginPage(storeId: widget.storeId),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  await _favoriteService.toggleFavorite(
                                    productId,
                                  );
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'guest-user' &&
                                      context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            LoginPage(storeId: widget.storeId),
                                      ),
                                    );
                                  }
                                }
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
                      "${item["price"]} ${t.currencySymbol}",
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
                      // 1. Guest: redirect to Login
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(storeId: widget.storeId),
                          ),
                        );
                        return;
                      }

                      // 2. Existing cart logic — unchanged
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
                        "storeId": widget.storeId,
                      });

                      await CartFirestore.saveCart(cartItems);

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
