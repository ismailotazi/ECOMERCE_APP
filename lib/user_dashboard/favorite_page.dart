import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/item_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  final bool showArrowBack;

  const FavoritePage({super.key, this.showArrowBack = true});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<List<String>> _loadGuestFavorites() async {
    return await FavoriteStorage.loadFavorites();
  }

  Future<void> _removeFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await FavoriteStorage.removeFavorite(productId);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .doc(productId)
          .delete();
    }
  }

  Future<List<QueryDocumentSnapshot>> _loadGuestProducts(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];

    final List<QueryDocumentSnapshot> products = [];

    // Firestore whereIn has a limit, so load in chunks.
    for (int i = 0; i < ids.length; i += 30) {
      final chunk = ids.skip(i).take(30).toList();

      final snapshot = await FirebaseFirestore.instance
          .collection("products")
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      products.addAll(snapshot.docs);
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.favorites),
        leading: widget.showArrowBack ? const CustomBackButton() : null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: user == null
            ? FutureBuilder<List<String>>(
                future: _loadGuestFavorites(),
                builder: (context, favoriteSnapshot) {
                  if (favoriteSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }

                  final ids = favoriteSnapshot.data ?? [];

                  if (ids.isEmpty) {
                    return Center(
                      child: Text(
                        t.noFavoriteProducts,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _loadGuestProducts(ids),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }

                      if (!productSnapshot.hasData ||
                          productSnapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            t.noFavoriteProducts,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }

                      final products = productSnapshot.data!;

                      return _buildProductsGrid(context, products, t);
                    },
                  );
                },
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("favorites")
                    .snapshots(),
                builder: (context, favoriteSnapshot) {
                  if (favoriteSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }

                  if (!favoriteSnapshot.hasData ||
                      favoriteSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        t.noFavoriteProducts,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  final ids = favoriteSnapshot.data!.docs
                      .map((e) => e.id)
                      .toList();

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("products")
                        .where(FieldPath.documentId, whereIn: ids)
                        .get(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }

                      if (!productSnapshot.hasData ||
                          productSnapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            t.noFavoriteProducts,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }

                      final products = productSnapshot.data!.docs;

                      return _buildProductsGrid(context, products, t);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildProductsGrid(
    BuildContext context,
    List<QueryDocumentSnapshot> products,
    AppLocalizations t,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isDesktop = width >= 1200;
        final isTablet = width >= 700;

        final crossAxisCount = isDesktop
            ? 4
            : isTablet
            ? 3
            : 2;

        final horizontalPadding = isDesktop
            ? 32.0
            : isTablet
            ? 24.0
            : 15.0;

        final spacing = isDesktop ? 20.0 : 12.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: GridView.builder(
              padding: EdgeInsets.all(horizontalPadding),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: isDesktop
                    ? 310
                    : isTablet
                    ? 295
                    : 270,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemBuilder: (context, index) {
                final doc = products[index];

                final item = {
                  "id": doc.id,
                  ...doc.data() as Map<String, dynamic>,
                };

                return _buildProductCard(context, item, t);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> item,
    AppLocalizations t,
  ) {
    final List images = item["images"] is List ? item["images"] : [];

    final String image = images.isNotEmpty
        ? images.first.toString().trim()
        : (item["image"]?.toString().trim() ?? "");

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
        );
      },
      child: Card(
        elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Hero(
                      tag: "product_${item["id"]}",
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }

                                  return Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                      ),
                    ),

                    // 🔥 PROMOTION BADGE
                    if (discount > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
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
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "-$discount%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ❤️ FAVORITE
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () async {
                            final productId = item["id"].toString();

                            await _removeFavorite(productId);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                content: Text(
                                  t.removedFromFavorites,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );

                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                item["name"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              Text(
                item["description"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 6),

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

                  Text(
                    "($reviewsCount)",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "\$${item["price"]}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: () async {
                      final productId = item["id"].toString();

                      final alreadyInCart = cartItems.any(
                        (cartItem) => cartItem["id"].toString() == productId,
                      );

                      if (alreadyInCart) {
                        if (!context.mounted) return;

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
                        "oldPrice": item["oldPrice"] ?? 0,
                        "image": image,
                        "images": images,
                        "brand": item["brand"],
                        "category": item["category"],
                        "quantity": 1,
                      });

                      await CartStorage.saveCart(cartItems);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          content: Text(
                            t.addToCart,
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/services/cart_data.dart';
// import 'package:ecomerce_app/services/cart_storage.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/user_dashboard/item_details.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class FavoritePage extends StatelessWidget {
//   final bool showArrowBack;
//   const FavoritePage({super.key, this.showArrowBack = true});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.favorites),
//         leading: showArrowBack ? const CustomBackButton() : null,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("users")
//               .doc(uid)
//               .collection("favorites")
//               .snapshots(),
//           builder: (context, favoriteSnapshot) {
//             if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!favoriteSnapshot.hasData ||
//                 favoriteSnapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   t.noFavoriteProducts,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final ids = favoriteSnapshot.data!.docs.map((e) => e.id).toList();

//             return FutureBuilder<QuerySnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection("products")
//                   .where(FieldPath.documentId, whereIn: ids)
//                   .get(),
//               builder: (context, productSnapshot) {
//                 if (!productSnapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   );
//                 }

//                 final products = productSnapshot.data!.docs;

//                 return GridView.builder(
//                   padding: const EdgeInsets.all(15),
//                   itemCount: products.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisExtent: 270,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                   ),
//                   itemBuilder: (context, index) {
//                     final doc = products[index];

//                     final item = {
//                       "id": doc.id,
//                       ...doc.data() as Map<String, dynamic>,
//                     };

//                     return _buildProductCard(context, uid, item, t);
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(
//     BuildContext context,
//     String uid,
//     Map<String, dynamic> item,
//     AppLocalizations t,
//   ) {
//     final List images = item["images"] is List ? item["images"] : [];

//     final String image = images.isNotEmpty
//         ? images.first.toString().trim()
//         : (item["image"]?.toString().trim() ?? "");
//     final rating = (item["rating"] as num?)?.toDouble() ?? 0.0;
//     final reviewsCount = (item["reviewsCount"] as num?)?.toInt() ?? 0;

//     final double price = (item["price"] as num?)?.toDouble() ?? 0;

//     final double oldPrice = (item["oldPrice"] as num?)?.toDouble() ?? 0;

//     final int discount = oldPrice > 0 && price < oldPrice
//         ? (((oldPrice - price) / oldPrice) * 100).round()
//         : 0;
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => ItemDetails(data: item)),
//         );
//       },
//       child: Card(
//         elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Hero(
//                     tag: "product_${item["id"]}",
//                     child: Container(
//                       height: 120,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       child: image.isNotEmpty
//                           ? Image.network(
//                               image,
//                               fit: BoxFit.contain,
//                               loadingBuilder: (context, child, progress) {
//                                 if (progress == null) return child;

//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.primary,
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (_, _, _) {
//                                 return Center(
//                                   child: Icon(
//                                     Icons.image_not_supported_outlined,
//                                     size: 40,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.outline,
//                                   ),
//                                 );
//                               },
//                             )
//                           : Center(
//                               child: Icon(
//                                 Icons.image_not_supported_outlined,
//                                 size: 40,
//                                 color: Theme.of(context).colorScheme.outline,
//                               ),
//                             ),
//                     ),
//                   ),

//                   // 🔥 PROMOTION BADGE
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

//                   // ❤️ FAVORITE
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.surface,
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.favorite,
//                           color: Theme.of(context).colorScheme.error,
//                         ),
//                         onPressed: () async {
//                           await FirebaseFirestore.instance
//                               .collection("users")
//                               .doc(uid)
//                               .collection("favorites")
//                               .doc(item["id"])
//                               .delete();

//                           if (!context.mounted) return;

//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               backgroundColor: Theme.of(
//                                 context,
//                               ).colorScheme.surface,
//                               content: Text(
//                                 t.removedFromFavorites,
//                                 style: TextStyle(
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onSurface,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
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
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       final productId = item["id"].toString();

//                       final alreadyInCart = cartItems.any(
//                         (cartItem) => cartItem["id"].toString() == productId,
//                       );

//                       if (alreadyInCart) {
//                         if (!context.mounted) return;

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
//                         "oldPrice": item["oldPrice"] ?? 0,
//                         "image": image,
//                         "images": images,
//                         "brand": item["brand"],
//                         "category": item["category"],
//                         "quantity": 1,
//                       });

//                       await CartStorage.saveCart(cartItems);

//                       if (!context.mounted) return;

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           backgroundColor: Theme.of(
//                             context,
//                           ).colorScheme.surface,
//                           content: Text(
//                             t.addToCart,
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
