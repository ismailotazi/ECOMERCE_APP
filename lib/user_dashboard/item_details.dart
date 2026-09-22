import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_data.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/cart_page.dart';
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
  final PageController imagePageController = PageController();
  int quantity = 1;
  bool isFavorite = false;

  Future<void> checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    final productId = widget.data["id"].toString();

    if (user == null) {
      final favorite = await FavoriteStorage.isFavorite(productId);

      if (mounted) {
        setState(() {
          isFavorite = favorite;
        });
      }

      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(productId)
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
  void dispose() {
    imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final List<String> images = List<String>.from(widget.data["images"] ?? []);

    final String brand = widget.data["brand"] ?? "Unknown";

    final String category = (widget.data["category"] ?? "").toString().trim();

    final String categoryKey = category.toLowerCase();

    final String localizedCategory = _getCategoryTitle(t, categoryKey);

    final int stock = widget.data["stock"] ?? 0;

    final double price = (widget.data["price"] ?? 0).toDouble();

    final double oldPrice = (widget.data["oldPrice"] ?? 0).toDouble();

    final int discount = oldPrice > 0 && price < oldPrice
        ? (((oldPrice - price) / oldPrice) * 100).round()
        : 0;

    final double rating = (widget.data["rating"] ?? 0).toDouble();

    final int reviews = widget.data["reviewsCount"] ?? 0;

    if (images.isEmpty && widget.data["image"] != null) {
      images.add(widget.data["image"]);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(t.productDetails),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.outline,
            ),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              final productId = widget.data["id"].toString();

              if (user == null) {
                if (isFavorite) {
                  await FavoriteStorage.removeFavorite(productId);
                } else {
                  await FavoriteStorage.addFavorite(productId);
                }
              } else {
                final ref = FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("favorites")
                    .doc(productId);

                if (isFavorite) {
                  await ref.delete();
                } else {
                  await ref.set({"createdAt": FieldValue.serverTimestamp()});
                }
              }

              if (!mounted) return;

              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isDesktop = width >= 1100;
          final bool isTablet = width >= 700 && width < 1100;

          final double horizontalPadding = isDesktop
              ? 32
              : isTablet
              ? 24
              : 20;

          final double maxContentWidth = isDesktop
              ? 1200
              : isTablet
              ? 950
              : double.infinity;

          final double galleryWidth = isDesktop
              ? 750
              : isTablet
              ? 650
              : width;

          final double galleryHeight = galleryWidth * 0.8;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                children: [
                  // ===== Product Image Gallery =====
                  if (images.isEmpty)
                    SizedBox(
                      height: galleryHeight,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          height: galleryHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PageView.builder(
                                controller: imagePageController,
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final imageUrl = images[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ZoomImagePage(image: imageUrl),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: imageUrl,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isDesktop
                                              ? 100
                                              : isTablet
                                              ? 70
                                              : 45,
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          loadingBuilder:
                                              (context, child, progress) {
                                                if (progress == null) {
                                                  return child;
                                                }

                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                      ),
                                                );
                                              },
                                          errorBuilder: (_, _, _) {
                                            return Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 60,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // ===== Previous Button =====
                              if (images.length > 1 && currentImageIndex > 0)
                                Positioned(
                                  left: 12,
                                  child: _buildImageNavigationButton(
                                    icon: Icons.chevron_left,
                                    onPressed: () {
                                      imagePageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                ),

                              // ===== Next Button =====
                              if (images.length > 1 &&
                                  currentImageIndex < images.length - 1)
                                Positioned(
                                  right: 12,
                                  child: _buildImageNavigationButton(
                                    icon: Icons.chevron_right,
                                    onPressed: () {
                                      imagePageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                ),

                              // ===== Image Counter =====
                              if (images.length > 1)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.55,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${currentImageIndex + 1}/${images.length}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

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
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                  ),

                  const SizedBox(height: 20),

                  // ===== Product Info =====
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (discount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.error
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_offer_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "-$discount%",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onError,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 12),

                            Text(
                              widget.data["name"],
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                  ),

                                if (oldPrice > 0) const SizedBox(width: 10),

                                Text(
                                  "\$${widget.data["price"]}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              t.taxIncluded,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.business,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        brand,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.category,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        localizedCategory,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
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
                                index < rating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 22,
                              );
                            }),

                            const SizedBox(width: 8),

                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "($reviews ${t.reviews})",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
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
                                  builder: (_) => WriteReviewPage(
                                    productId: widget.data["id"],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.rate_review,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            label: Text(t.writeReview),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: stock > 0
                                ? Colors.green.withValues(alpha: 0.12)
                                : Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: stock > 0
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Theme.of(
                                      context,
                                    ).colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                stock > 0 ? Icons.check_circle : Icons.cancel,
                                color: stock > 0
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  stock > 0
                                      ? t.itemsLeftInStock(stock)
                                      : t.outOfStock,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: stock > 0
                                            ? Colors.green
                                            : Theme.of(
                                                context,
                                              ).colorScheme.error,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        Text(
                          t.quantity,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                        Text(
                          t.description,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          widget.data["description"] ??
                              t.noDescriptionAvailable,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          t.relatedProducts,
                          style: Theme.of(context).textTheme.titleLarge,
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
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                );
                              }

                              final products = snapshot.data!.docs
                                  .where((doc) => doc.id != widget.data["id"])
                                  .toList();

                              if (products.isEmpty) {
                                return Center(
                                  child: Text(
                                    t.noRelatedProducts,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                );
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      products[index].data()
                                          as Map<String, dynamic>;

                                  final relatedPrice =
                                      (product["price"] as num?)?.toDouble() ??
                                      0;

                                  final relatedOldPrice =
                                      (product["oldPrice"] as num?)
                                          ?.toDouble() ??
                                      0;

                                  final relatedDiscount =
                                      relatedOldPrice > 0 &&
                                          relatedPrice < relatedOldPrice
                                      ? (((relatedOldPrice - relatedPrice) /
                                                    relatedOldPrice) *
                                                100)
                                            .round()
                                      : 0;

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
                                          builder: (_) =>
                                              ItemDetails(data: item),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: isDesktop
                                          ? 190
                                          : isTablet
                                          ? 180
                                          : 170,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Card(
                                        elevation:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? 0
                                            : 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                    child: Image.network(
                                                      (product["images"] !=
                                                                  null &&
                                                              (product["images"]
                                                                      as List)
                                                                  .isNotEmpty)
                                                          ? product["images"][0]
                                                          : product["image"] ??
                                                                "",
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            progress,
                                                          ) {
                                                            if (progress ==
                                                                null) {
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
                                                        return Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.outline,
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  if (relatedDiscount > 0)
                                                    Positioned(
                                                      top: 8,
                                                      left: 8,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 9,
                                                              vertical: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.error,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.18,
                                                                  ),
                                                              blurRadius: 6,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    3,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .local_offer_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              "-$relatedDiscount%",
                                                              style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                product["name"] ?? "",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),

                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                "\$${product["price"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: AppColors.success,
                                                      fontWeight:
                                                          FontWeight.bold,
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

                        Text(
                          t.customerReviews,
                          style: Theme.of(context).textTheme.titleLarge,
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
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }

                            final reviews = snapshot.data!.docs;

                            if (reviews.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    t.noReviewsYet,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                final review =
                                    reviews[index].data()
                                        as Map<String, dynamic>;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 0
                                      : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
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
                                          ? Icon(
                                              Icons.person,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      review["userName"] ?? "",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              i <
                                                      (review["rating"] as num)
                                                          .toInt()
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            );
                                          }),
                                        ),

                                        const SizedBox(height: 5),

                                        Text(
                                          review["comment"] ?? "",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
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
                                  onPressed: () async {
                                    final productId = widget.data["id"]
                                        .toString();

                                    final index = cartItems.indexWhere(
                                      (item) =>
                                          item["id"].toString() == productId,
                                    );

                                    if (index != -1) {
                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(t.alreadyInCart),
                                        ),
                                      );

                                      return;
                                    }

                                    cartItems.add({
                                      "id": widget.data["id"],
                                      "name": widget.data["name"],
                                      "price": widget.data["price"],
                                      "oldPrice": widget.data["oldPrice"] ?? 0,
                                      "image": widget.data["image"],
                                      "images": widget.data["images"] ?? [],
                                      "brand": widget.data["brand"],
                                      "category": widget.data["category"],
                                      "quantity": quantity,
                                    });

                                    await CartStorage.saveCart(cartItems);

                                    if (!context.mounted) {
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(t.addedToCart)),
                                    );

                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                  ),
                                  label: Text(t.addToCart),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    side: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton.icon(
                                  onPressed: stock > 0
                                      ? () async {
                                          cartItems.clear();

                                          cartItems.add({
                                            "id": widget.data["id"],
                                            "name": widget.data["name"],
                                            "price": widget.data["price"],
                                            "image": widget.data["image"],
                                            "images":
                                                widget.data["images"] ?? [],
                                            "brand": widget.data["brand"],
                                            "category": widget.data["category"],
                                            "quantity": quantity,
                                          });

                                          await CartStorage.saveCart(cartItems);

                                          if (!context.mounted) {
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const CartPage(),
                                            ),
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.flash_on),
                                  label: Text(t.buyNow),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
            ),
          );
        },
      ),
    );
  }

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
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(
                image,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (_, _, _) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white,
                    size: 60,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildImageNavigationButton({
  required IconData icon,
  required VoidCallback onPressed,
}) {
  return Material(
    color: Colors.black.withValues(alpha: 0.45),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: const SizedBox(
        width: 42,
        height: 42,
        child: Icon(Icons.chevron_left, color: Colors.white, size: 26),
      ),
    ),
  );
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/services/cart_data.dart';
// import 'package:ecomerce_app/services/cart_storage.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/user_dashboard/cart_page.dart';
// import 'package:ecomerce_app/user_dashboard/write_review_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ItemDetails extends StatefulWidget {
//   final Map<String, dynamic> data;

//   const ItemDetails({super.key, required this.data});

//   @override
//   State<ItemDetails> createState() => _ItemDetailsState();
// }

// class _ItemDetailsState extends State<ItemDetails> {
//   int currentImageIndex = 0;
//   final PageController imagePageController = PageController();
//   int quantity = 1;
//   bool isFavorite = false;

//   String get uid => FirebaseAuth.instance.currentUser!.uid;
//   Future<void> checkFavorite() async {
//     final doc = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .collection("favorites")
//         .doc(widget.data["id"])
//         .get();

//     if (mounted) {
//       setState(() {
//         isFavorite = doc.exists;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     checkFavorite();
//   }

//   @override
//   void dispose() {
//     imagePageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final List<String> images = List<String>.from(widget.data["images"] ?? []);
//     final String brand = widget.data["brand"] ?? "Unknown";

//     final String category = (widget.data["category"] ?? "")
//         .toString()
//         .trim()
//         .toLowerCase();

//     final String localizedCategory = _getCategoryTitle(t, category);

//     final int stock = widget.data["stock"] ?? 0;

//     final double price = (widget.data["price"] ?? 0).toDouble();

//     final double oldPrice = (widget.data["oldPrice"] ?? 0).toDouble();

//     final int discount = oldPrice > 0 && price < oldPrice
//         ? (((oldPrice - price) / oldPrice) * 100).round()
//         : 0;

//     final double rating = (widget.data["rating"] ?? 0).toDouble();

//     final int reviews = widget.data["reviewsCount"] ?? 0;
//     if (images.isEmpty && widget.data["image"] != null) {
//       images.add(widget.data["image"]);
//     }

//     return Scaffold(
//       appBar: AppBar(
//         leading: const CustomBackButton(),
//         title: Text(t.productDetails),

//         actions: [
//           IconButton(
//             icon: Icon(
//               isFavorite ? Icons.favorite : Icons.favorite_border,
//               color: isFavorite
//                   ? Theme.of(context).colorScheme.error
//                   : Theme.of(context).colorScheme.outline,
//             ),
//             onPressed: () async {
//               final ref = FirebaseFirestore.instance
//                   .collection("users")
//                   .doc(uid)
//                   .collection("favorites")
//                   .doc(widget.data["id"]);

//               if (isFavorite) {
//                 await ref.delete();
//               } else {
//                 await ref.set({"createdAt": FieldValue.serverTimestamp()});
//               }

//               setState(() {
//                 isFavorite = !isFavorite;
//               });
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           // ===== Product Image Gallery =====
//           if (images.isEmpty)
//             SizedBox(
//               height: screenWidth * 0.8,
//               child: Center(
//                 child: Icon(
//                   Icons.image_not_supported_outlined,
//                   size: 80,
//                   color: Theme.of(context).colorScheme.outline,
//                 ),
//               ),
//             )
//           else
//             Column(
//               children: [
//                 SizedBox(
//                   height: screenWidth * 0.8,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       PageView.builder(
//                         controller: imagePageController,
//                         itemCount: images.length,
//                         onPageChanged: (index) {
//                           setState(() {
//                             currentImageIndex = index;
//                           });
//                         },
//                         itemBuilder: (context, index) {
//                           final imageUrl = images[index];

//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       ZoomImagePage(image: imageUrl),
//                                 ),
//                               );
//                             },
//                             child: Hero(
//                               tag: imageUrl,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 45,
//                                 ),
//                                 child: Image.network(
//                                   imageUrl,
//                                   fit: BoxFit.contain,
//                                   loadingBuilder: (context, child, progress) {
//                                     if (progress == null) return child;

//                                     return Center(
//                                       child: CircularProgressIndicator(
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.primary,
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (_, _, _) {
//                                     return Icon(
//                                       Icons.image_not_supported_outlined,
//                                       size: 60,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.outline,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),

//                       // ===== Previous Button =====
//                       if (images.length > 1 && currentImageIndex > 0)
//                         Positioned(
//                           left: 12,
//                           child: _buildImageNavigationButton(
//                             icon: Icons.chevron_left,
//                             onPressed: () {
//                               imagePageController.previousPage(
//                                 duration: const Duration(milliseconds: 250),
//                                 curve: Curves.easeInOut,
//                               );
//                             },
//                           ),
//                         ),

//                       // ===== Next Button =====
//                       if (images.length > 1 &&
//                           currentImageIndex < images.length - 1)
//                         Positioned(
//                           right: 12,
//                           child: _buildImageNavigationButton(
//                             icon: Icons.chevron_right,
//                             onPressed: () {
//                               imagePageController.nextPage(
//                                 duration: const Duration(milliseconds: 250),
//                                 curve: Curves.easeInOut,
//                               );
//                             },
//                           ),
//                         ),

//                       // ===== Image Counter =====
//                       if (images.length > 1)
//                         Positioned(
//                           top: 12,
//                           right: 12,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withValues(alpha: 0.55),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               "${currentImageIndex + 1}/${images.length}",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//           const SizedBox(height: 20),
//           // ===== Rectangular Indicator =====
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: images.isEmpty
//                 ? []
//                 : List.generate(images.length, (index) {
//                     return AnimatedContainer(
//                       duration: const Duration(milliseconds: 250),
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 8,
//                       ),
//                       width: currentImageIndex == index ? 24 : 16,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: currentImageIndex == index
//                             ? Theme.of(context).colorScheme.primary
//                             : Theme.of(context).colorScheme.outline,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     );
//                   }),
//           ),

//           const SizedBox(height: 20),

//           // ===== Product Info =====
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (discount > 0)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 7,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).colorScheme.error,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.error.withValues(alpha: 0.25),
//                               blurRadius: 8,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.local_offer_rounded,
//                               size: 16,
//                               color: Colors.white,
//                             ),
//                             const SizedBox(width: 5),
//                             Text(
//                               "-$discount%",
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.onError,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     const SizedBox(height: 12),

//                     Text(
//                       widget.data["name"],
//                       style: Theme.of(context).textTheme.headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         if (oldPrice > 0)
//                           Text(
//                             "\$${oldPrice.toStringAsFixed(0)}",
//                             style: Theme.of(context).textTheme.bodyLarge
//                                 ?.copyWith(
//                                   color: Theme.of(context).colorScheme.outline,
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                           ),

//                         if (oldPrice > 0) const SizedBox(width: 10),

//                         Text(
//                           "\$${widget.data["price"]}",
//                           style: Theme.of(context).textTheme.headlineMedium
//                               ?.copyWith(
//                                 color: AppColors.success,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 6),

//                     Text(
//                       t.taxIncluded,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Theme.of(context).colorScheme.outline,
//                       ),
//                     ),
//                     const SizedBox(height: 18),

//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.primaryContainer,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.business,
//                                 size: 18,
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onPrimaryContainer,
//                               ),

//                               const SizedBox(width: 6),

//                               Text(
//                                 brand,
//                                 style: Theme.of(context).textTheme.bodyMedium
//                                     ?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimaryContainer,
//                                     ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.secondaryContainer,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.category,
//                                 size: 18,
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSecondaryContainer,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 localizedCategory,
//                                 style: Theme.of(context).textTheme.bodyMedium
//                                     ?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onSecondaryContainer,
//                                     ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // ===== Rating Stars =====
//                 Row(
//                   children: [
//                     ...List.generate(5, (index) {
//                       return Icon(
//                         index < rating.floor() ? Icons.star : Icons.star_border,
//                         color: Colors.amber,
//                         size: 22,
//                       );
//                     }),

//                     const SizedBox(width: 8),

//                     Text(
//                       rating.toStringAsFixed(1),
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(width: 8),

//                     Text(
//                       "($reviews ${t.reviews})",
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Theme.of(context).colorScheme.outline,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               WriteReviewPage(productId: widget.data["id"]),
//                         ),
//                       );
//                     },
//                     icon: Icon(
//                       Icons.rate_review,
//                       color: Theme.of(context).colorScheme.onPrimary,
//                     ),
//                     label: Text(t.writeReview),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).colorScheme.primary,
//                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     color: stock > 0
//                         ? Colors.green.withValues(alpha: 0.12)
//                         : Theme.of(
//                             context,
//                           ).colorScheme.error.withValues(alpha: 0.12),

//                     borderRadius: BorderRadius.circular(12),

//                     border: Border.all(
//                       color: stock > 0
//                           ? Colors.green.withValues(alpha: 0.3)
//                           : Theme.of(
//                               context,
//                             ).colorScheme.error.withValues(alpha: 0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         stock > 0 ? Icons.check_circle : Icons.cancel,
//                         color: stock > 0
//                             ? Colors.green
//                             : Theme.of(context).colorScheme.error,
//                       ),

//                       const SizedBox(width: 10),

//                       Expanded(
//                         child: Text(
//                           stock > 0 ? t.itemsLeftInStock(stock) : t.outOfStock,
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: stock > 0
//                                     ? Colors.green
//                                     : Theme.of(context).colorScheme.error,
//                               ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Text(
//                   t.quantity,
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),

//                 const SizedBox(height: 10),

//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.surfaceContainerHighest,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         onPressed: quantity > 1
//                             ? () {
//                                 setState(() {
//                                   quantity--;
//                                 });
//                               }
//                             : null,
//                         icon: const Icon(Icons.remove_circle_outline),
//                       ),

//                       Text(
//                         quantity.toString(),
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       IconButton(
//                         onPressed: quantity < stock
//                             ? () {
//                                 setState(() {
//                                   quantity++;
//                                 });
//                               }
//                             : null,
//                         icon: const Icon(Icons.add_circle_outline),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // ===== Description Section =====
//                 Text(
//                   t.description,
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   widget.data["description"] ?? t.noDescriptionAvailable,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 const SizedBox(height: 30),

//                 Text(
//                   t.relatedProducts,
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   height: 280,
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection("products")
//                         .where("category", isEqualTo: category)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return Center(
//                           child: CircularProgressIndicator(
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         );
//                       }

//                       final products = snapshot.data!.docs
//                           .where((doc) => doc.id != widget.data["id"])
//                           .toList();

//                       if (products.isEmpty) {
//                         return Center(
//                           child: Text(
//                             t.noRelatedProducts,
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         );
//                       }

//                       return ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: products.length,
//                         itemBuilder: (context, index) {
//                           final product =
//                               products[index].data() as Map<String, dynamic>;
//                           final relatedPrice =
//                               (product["price"] as num?)?.toDouble() ?? 0;

//                           final relatedOldPrice =
//                               (product["oldPrice"] as num?)?.toDouble() ?? 0;

//                           final relatedDiscount =
//                               relatedOldPrice > 0 &&
//                                   relatedPrice < relatedOldPrice
//                               ? (((relatedOldPrice - relatedPrice) /
//                                             relatedOldPrice) *
//                                         100)
//                                     .round()
//                               : 0;
//                           product["id"] = products[index].id;

//                           return GestureDetector(
//                             onTap: () {
//                               final item = {
//                                 ...product,
//                                 "id": products[index].id,
//                               };

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => ItemDetails(data: item),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               width: 170,
//                               margin: const EdgeInsets.only(right: 12),
//                               child: Card(
//                                 elevation:
//                                     Theme.of(context).brightness ==
//                                         Brightness.dark
//                                     ? 0
//                                     : 3,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       child: Stack(
//                                         children: [
//                                           ClipRRect(
//                                             borderRadius:
//                                                 const BorderRadius.vertical(
//                                                   top: Radius.circular(12),
//                                                 ),
//                                             child: Image.network(
//                                               (product["images"] != null &&
//                                                       (product["images"]
//                                                               as List)
//                                                           .isNotEmpty)
//                                                   ? product["images"][0]
//                                                   : product["image"] ?? "",
//                                               width: double.infinity,
//                                               fit: BoxFit.cover,
//                                               loadingBuilder:
//                                                   (context, child, progress) {
//                                                     if (progress == null) {
//                                                       return child;
//                                                     }

//                                                     return Center(
//                                                       child:
//                                                           CircularProgressIndicator(
//                                                             strokeWidth: 2,
//                                                             color:
//                                                                 Theme.of(
//                                                                       context,
//                                                                     )
//                                                                     .colorScheme
//                                                                     .primary,
//                                                           ),
//                                                     );
//                                                   },
//                                               errorBuilder: (_, _, _) {
//                                                 return Icon(
//                                                   Icons
//                                                       .image_not_supported_outlined,
//                                                   color: Theme.of(
//                                                     context,
//                                                   ).colorScheme.outline,
//                                                 );
//                                               },
//                                             ),
//                                           ),

//                                           if (relatedDiscount > 0)
//                                             Positioned(
//                                               top: 8,
//                                               left: 8,
//                                               child: Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 9,
//                                                       vertical: 6,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   color: Theme.of(
//                                                     context,
//                                                   ).colorScheme.error,
//                                                   borderRadius:
//                                                       BorderRadius.circular(20),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black
//                                                           .withValues(
//                                                             alpha: 0.18,
//                                                           ),
//                                                       blurRadius: 6,
//                                                       offset: const Offset(
//                                                         0,
//                                                         3,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     const Icon(
//                                                       Icons.local_offer_rounded,
//                                                       size: 14,
//                                                       color: Colors.white,
//                                                     ),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       "-$relatedDiscount%",
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 11,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8),
//                                       child: Text(
//                                         product["name"] ?? "",
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium
//                                             ?.copyWith(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                       ),
//                                       child: Text(
//                                         "\$${product["price"]}",
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium
//                                             ?.copyWith(
//                                               color: AppColors.success,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   t.customerReviews,
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),

//                 const SizedBox(height: 15),

//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection("products")
//                       .doc(widget.data["id"])
//                       .collection("reviews")
//                       .orderBy("createdAt", descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       );
//                     }

//                     final reviews = snapshot.data!.docs;

//                     if (reviews.isEmpty) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         child: Center(
//                           child: Text(
//                             t.noReviewsYet,
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ),
//                       );
//                     }

//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: reviews.length,
//                       itemBuilder: (context, index) {
//                         final review =
//                             reviews[index].data() as Map<String, dynamic>;

//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           elevation:
//                               Theme.of(context).brightness == Brightness.dark
//                               ? 0
//                               : 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage:
//                                   review["photoUrl"] != null &&
//                                       review["photoUrl"] != ""
//                                   ? NetworkImage(review["photoUrl"])
//                                   : null,
//                               child:
//                                   review["photoUrl"] == null ||
//                                       review["photoUrl"] == ""
//                                   ? Icon(
//                                       Icons.person,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onSurface,
//                                     )
//                                   : null,
//                             ),
//                             title: Text(
//                               review["userName"] ?? "",
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: List.generate(5, (i) {
//                                     return Icon(
//                                       i < (review["rating"] as num).toInt()
//                                           ? Icons.star
//                                           : Icons.star_border,
//                                       color: Colors.amber,
//                                       size: 18,
//                                     );
//                                   }),
//                                 ),

//                                 const SizedBox(height: 5),

//                                 Text(
//                                   review["comment"] ?? "",
//                                   style: Theme.of(context).textTheme.bodyMedium,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 30),
//                 // ===== Add To Cart Button =====
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         height: 55,
//                         child: OutlinedButton.icon(
//                           onPressed: () async {
//                             final productId = widget.data["id"].toString();

//                             final index = cartItems.indexWhere(
//                               (item) => item["id"].toString() == productId,
//                             );

//                             if (index != -1) {
//                               if (!context.mounted) return;

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text(t.alreadyInCart)),
//                               );

//                               return;
//                             }

//                             cartItems.add({
//                               "id": widget.data["id"],
//                               "name": widget.data["name"],
//                               "price": widget.data["price"],
//                               "oldPrice": widget.data["oldPrice"] ?? 0,
//                               "image": widget.data["image"],
//                               "images": widget.data["images"] ?? [],
//                               "brand": widget.data["brand"],
//                               "category": widget.data["category"],
//                               "quantity": quantity,
//                             });

//                             await CartStorage.saveCart(cartItems);

//                             if (!context.mounted) return;

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(t.addedToCart)),
//                             );

//                             setState(() {});
//                           },
//                           icon: const Icon(Icons.shopping_cart_outlined),
//                           label: Text(t.addToCart),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Theme.of(
//                               context,
//                             ).colorScheme.primary,
//                             side: BorderSide(
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: SizedBox(
//                         height: 55,
//                         child: ElevatedButton.icon(
//                           onPressed: stock > 0
//                               ? () async {
//                                   cartItems.clear();

//                                   cartItems.add({
//                                     "id": widget.data["id"],
//                                     "name": widget.data["name"],
//                                     "price": widget.data["price"],
//                                     "image": widget.data["image"],
//                                     "images": widget.data["images"] ?? [],
//                                     "brand": widget.data["brand"],
//                                     "category": widget.data["category"],
//                                     "quantity": quantity,
//                                   });

//                                   await CartStorage.saveCart(cartItems);

//                                   if (!context.mounted) return;

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => const CartPage(),
//                                     ),
//                                   );
//                                 }
//                               : null,
//                           icon: const Icon(Icons.flash_on),
//                           label: Text(t.buyNow),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(
//                               context,
//                             ).colorScheme.primary,
//                             foregroundColor: Theme.of(
//                               context,
//                             ).colorScheme.onPrimary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

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
// }

// // ===== Zoom Image Page =====
// class ZoomImagePage extends StatelessWidget {
//   final String image;
//   const ZoomImagePage({super.key, required this.image});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: Center(
//           child: Hero(
//             tag: image,
//             child: InteractiveViewer(
//               minScale: 0.8,
//               maxScale: 4,
//               child: Image.network(
//                 image,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) return child;

//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   );
//                 },
//                 errorBuilder: (_, _, _) {
//                   return const Icon(
//                     Icons.image_not_supported_outlined,
//                     color: Colors.white,
//                     size: 60,
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// Widget _buildImageNavigationButton({
//   required IconData icon,
//   required VoidCallback onPressed,
// }) {
//   return Material(
//     color: Colors.black.withValues(alpha: 0.45),
//     shape: const CircleBorder(),
//     child: InkWell(
//       onTap: onPressed,
//       customBorder: const CircleBorder(),
//       child: const SizedBox(
//         width: 42,
//         height: 42,
//         child: Icon(Icons.chevron_left, color: Colors.white, size: 26),
//       ),
//     ),
//   );
// }
