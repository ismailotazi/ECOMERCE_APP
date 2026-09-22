import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
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
  late Future<DocumentSnapshot<Map<String, dynamic>>> productFuture;
  int currentImage = 0;

  String getLocalizedCategory(BuildContext context, String category) {
    final t = AppLocalizations.of(context)!;

    switch (category) {
      case "Electronics":
        return t.electronics;
      case "Smartphones":
        return t.smartphones;
      case "Laptops":
        return t.laptops;
      case "Tablets":
        return t.tablets;
      case "Smartwatches":
        return t.smartwatches;
      case "Accessories":
        return t.accessories;
      case "Audio":
        return t.audio;
      case "Gaming":
        return t.gaming;
      case "Home Appliances":
        return t.homeAppliances;
      case "Perfumes":
        return t.perfumes;
      case "Beauty":
        return t.beauty;
      case "Clothing":
        return t.clothing;
      case "Shoes":
        return t.shoes;
      case "Bags":
        return t.bags;
      case "Watches":
        return t.watches;
      case "Jewelry":
        return t.jewelry;
      case "Glasses":
        return t.glasses;
      case "Sports":
        return t.sports;
      case "Books":
        return t.books;
      case "Toys":
        return t.toys;
      case "Furniture":
        return t.furniture;
      case "Food":
        return t.food;
      case "Health":
        return t.health;
      case "Automotive":
        return t.automotive;
      case "Other":
        return t.other;
      default:
        return category;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct() {
    return FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .get();
  }

  Future<void> deleteProduct(Map<String, dynamic> product) async {
    final t = AppLocalizations.of(context)!;

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.productDeletedSuccessfully)));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    super.initState();
    productFuture = getProduct();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    final horizontalPadding = isDesktop
        ? 32.0
        : isTablet
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.productDetails),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  t.productNotFound,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final product = snapshot.data!.data()!;
            final List images = product["images"] ?? [];
            final price = (product["price"] as num?)?.toDouble() ?? 0;
            final oldPrice = (product["oldPrice"] as num?)?.toDouble() ?? 0;

            final discount = oldPrice > 0 && price < oldPrice
                ? (((oldPrice - price) / oldPrice) * 100).round()
                : 0;

            final imageHeight = isDesktop
                ? 430.0
                : isTablet
                ? 360.0
                : screenWidth * 0.72;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isDesktop ? 20 : 8,
                      horizontalPadding,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop)
                          _buildDesktopProductTop(
                            context,
                            product,
                            images,
                            imageHeight,
                            t,
                            price,
                            oldPrice,
                            discount,
                          )
                        else
                          _buildMobileProductTop(
                            context,
                            product,
                            images,
                            imageHeight,
                            t,
                            price,
                            oldPrice,
                            discount,
                          ),

                        SizedBox(height: isDesktop ? 28 : 24),

                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildInfoCard(context, t, product),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildDescriptionCard(
                                  context,
                                  t,
                                  product,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildInfoCard(context, t, product),
                          const SizedBox(height: 20),
                          _buildDescriptionCard(context, t, product),
                        ],

                        SizedBox(height: isDesktop ? 30 : 24),

                        Text(
                          t.statistics,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 14),

                        GridView.count(
                          crossAxisCount: isDesktop ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: isDesktop ? 16 : 12,
                          mainAxisSpacing: isDesktop ? 16 : 12,
                          childAspectRatio: isDesktop ? 1.7 : 1.35,
                          children: [
                            _buildStatCard(
                              Icons.star_rounded,
                              t.rating,
                              "${product["rating"] ?? 0}",
                              Colors.amber,
                            ),
                            _buildStatCard(
                              Icons.rate_review_rounded,
                              t.reviews,
                              "${product["reviewsCount"] ?? 0}",
                              AppColors.info,
                            ),
                            _buildStatCard(
                              Icons.inventory_2_rounded,
                              t.stock,
                              "${product["stock"] ?? 0}",
                              AppColors.success,
                            ),
                            _buildStatCard(
                              Icons.local_offer_rounded,
                              t.discount,
                              "$discount%",
                              AppColors.error,
                            ),
                          ],
                        ),

                        SizedBox(height: isDesktop ? 34 : 30),

                        if (isDesktop)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 230,
                                height: 48,
                                child: _buildEditButton(context, t),
                              ),
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 230,
                                height: 48,
                                child: _buildDeleteButton(context, t, product),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: _buildEditButton(context, t),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: _buildDeleteButton(context, t, product),
                              ),
                            ],
                          ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileProductTop(
    BuildContext context,
    Map<String, dynamic> product,
    List images,
    double imageHeight,
    AppLocalizations t,
    double price,
    double oldPrice,
    int discount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageGallery(context, images, imageHeight),
        const SizedBox(height: 22),
        _buildProductInfo(context, product, t, price, oldPrice, discount),
      ],
    );
  }

  Widget _buildDesktopProductTop(
    BuildContext context,
    Map<String, dynamic> product,
    List images,
    double imageHeight,
    AppLocalizations t,
    double price,
    double oldPrice,
    int discount,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: _buildImageGallery(context, images, imageHeight),
        ),
        const SizedBox(width: 28),
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildProductInfo(
              context,
              product,
              t,
              price,
              oldPrice,
              discount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(
    BuildContext context,
    List images,
    double imageHeight,
  ) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Stack(
              children: [
                if (images.isNotEmpty)
                  PageView.builder(
                    controller: pageController,
                    itemCount: images.length,
                    physics: const PageScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        currentImage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = images[index].toString();

                      return Padding(
                        padding: EdgeInsets.all(imageHeight > 400 ? 30 : 20),
                        child: Image.network(
                          imageUrl,
                          key: ValueKey(imageUrl),
                          width: double.infinity,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 50,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                else
                  Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                if (images.length > 1)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${currentImage + 1}/${images.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (images.length > 1 && currentImage > 0)
                  Positioned(
                    left: 14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildImageNavigationButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ),

                if (images.length > 1 && currentImage < images.length - 1)
                  Positioned(
                    right: 14,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildImageNavigationButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentImage == index ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: currentImage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(
    BuildContext context,
    Map<String, dynamic> product,
    AppLocalizations t,
    double price,
    double oldPrice,
    int discount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product["name"] ?? "",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 5),
              Text(
                "${product["rating"] ?? 0}",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text(
                "(${product["reviewsCount"] ?? 0})",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              "\$${product["price"]}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),

            if (oldPrice > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  "\$$oldPrice",
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 17,
                  ),
                ),
              ),

            if (discount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "-$discount%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    AppLocalizations t,
    Map<String, dynamic> product,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.category_outlined,
              t.category,
              getLocalizedCategory(
                context,
                product["category"]?.toString() ?? "-",
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.branding_watermark_outlined,
              t.brand,
              product["brand"] ?? "-",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    AppLocalizations t,
    Map<String, dynamic> product,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              product["description"] ?? t.noDescriptionAvailable,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, AppLocalizations t) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit_rounded, size: 18),
      label: Text(
        t.editProduct,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProductPage(productId: widget.productId),
          ),
        );

        if (!mounted) return;

        setState(() {
          productFuture = getProduct();
          currentImage = 0;
        });
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    AppLocalizations t,
    Map<String, dynamic> product,
  ) {
    return OutlinedButton.icon(
      icon: Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
      label: Text(
        t.deleteProduct,
        style: TextStyle(
          color: AppColors.error,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: AppColors.error),
      ),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete Product"),
              content: Text(t.deleteProductConfirmation),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(t.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(t.delete),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          await deleteProduct(product);
        }
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 21,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 23),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          width: 40,
          height: 40,
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';

// class AdminProductDetailsPage extends StatefulWidget {
//   const AdminProductDetailsPage({super.key, required this.productId});

//   final String productId;

//   @override
//   State<AdminProductDetailsPage> createState() =>
//       _AdminProductDetailsPageState();
// }

// class _AdminProductDetailsPageState extends State<AdminProductDetailsPage> {
//   final PageController pageController = PageController();
//   late Future<DocumentSnapshot<Map<String, dynamic>>> productFuture;
//   int currentImage = 0;
//   String getLocalizedCategory(BuildContext context, String category) {
//     final t = AppLocalizations.of(context)!;

//     switch (category) {
//       case "Electronics":
//         return t.electronics;
//       case "Smartphones":
//         return t.smartphones;
//       case "Laptops":
//         return t.laptops;
//       case "Tablets":
//         return t.tablets;
//       case "Smartwatches":
//         return t.smartwatches;
//       case "Accessories":
//         return t.accessories;
//       case "Audio":
//         return t.audio;
//       case "Gaming":
//         return t.gaming;
//       case "Home Appliances":
//         return t.homeAppliances;
//       case "Perfumes":
//         return t.perfumes;
//       case "Beauty":
//         return t.beauty;
//       case "Clothing":
//         return t.clothing;
//       case "Shoes":
//         return t.shoes;
//       case "Bags":
//         return t.bags;
//       case "Watches":
//         return t.watches;
//       case "Jewelry":
//         return t.jewelry;
//       case "Glasses":
//         return t.glasses;
//       case "Sports":
//         return t.sports;
//       case "Books":
//         return t.books;
//       case "Toys":
//         return t.toys;
//       case "Furniture":
//         return t.furniture;
//       case "Food":
//         return t.food;
//       case "Health":
//         return t.health;
//       case "Automotive":
//         return t.automotive;
//       case "Other":
//         return t.other;
//       default:
//         return category;
//     }
//   }

//   Future<DocumentSnapshot<Map<String, dynamic>>> getProduct() {
//     return FirebaseFirestore.instance
//         .collection("products")
//         .doc(widget.productId)
//         .get();
//   }

//   Future<void> deleteProduct(Map<String, dynamic> product) async {
//     final t = AppLocalizations.of(context)!;
//     try {
//       final List images = product["images"] ?? [];

//       for (final image in images) {
//         try {
//           await FirebaseStorage.instance.refFromURL(image).delete();
//         } catch (_) {}
//       }

//       await FirebaseFirestore.instance
//           .collection("products")
//           .doc(widget.productId)
//           .delete();

//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(t.productDeletedSuccessfully)));

//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     productFuture = getProduct();
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.productDetails),
//         leading: const CustomBackButton(),
//       ),
//       body: SafeArea(
//         child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//           future: productFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return Center(
//                 child: Text(
//                   t.productNotFound,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final product = snapshot.data!.data()!;
//             final List images = product["images"] ?? [];
//             final price = (product["price"] as num?)?.toDouble() ?? 0;
//             final oldPrice = (product["oldPrice"] as num?)?.toDouble() ?? 0;

//             final discount = oldPrice > 0 && price < oldPrice
//                 ? (((oldPrice - price) / oldPrice) * 100).round()
//                 : 0;
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//                     child: Column(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(24),
//                           child: Container(
//                             height: 280,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.surfaceContainerHighest,
//                               borderRadius: BorderRadius.circular(24),
//                             ),
//                             child: Stack(
//                               children: [
//                                 PageView.builder(
//                                   controller: pageController,
//                                   itemCount: images.length,
//                                   physics: const PageScrollPhysics(),
//                                   onPageChanged: (index) {
//                                     setState(() {
//                                       currentImage = index;
//                                     });
//                                   },
//                                   itemBuilder: (context, index) {
//                                     final imageUrl = images[index].toString();

//                                     return Padding(
//                                       padding: const EdgeInsets.all(20),
//                                       child: Image.network(
//                                         imageUrl,
//                                         key: ValueKey(imageUrl),
//                                         width: double.infinity,
//                                         fit: BoxFit.contain,
//                                         gaplessPlayback: true,
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                               return Center(
//                                                 child: Icon(
//                                                   Icons
//                                                       .image_not_supported_rounded,
//                                                   size: 50,
//                                                   color: Theme.of(context)
//                                                       .colorScheme
//                                                       .onSurfaceVariant,
//                                                 ),
//                                               );
//                                             },
//                                       ),
//                                     );
//                                   },
//                                 ),

//                                 // Image counter
//                                 if (images.length > 1)
//                                   Positioned(
//                                     top: 14,
//                                     right: 14,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 10,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.black.withValues(
//                                           alpha: 0.55,
//                                         ),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Text(
//                                         "${currentImage + 1}/${images.length}",
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ),

//                                 // Previous button
//                                 if (images.length > 1 && currentImage > 0)
//                                   Positioned(
//                                     left: 12,
//                                     top: 0,
//                                     bottom: 0,
//                                     child: Center(
//                                       child: _buildImageNavigationButton(
//                                         icon: Icons.chevron_left_rounded,
//                                         onPressed: () {
//                                           pageController.previousPage(
//                                             duration: const Duration(
//                                               milliseconds: 250,
//                                             ),
//                                             curve: Curves.easeOut,
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),

//                                 // Next button
//                                 if (images.length > 1 &&
//                                     currentImage < images.length - 1)
//                                   Positioned(
//                                     right: 12,
//                                     top: 0,
//                                     bottom: 0,
//                                     child: Center(
//                                       child: _buildImageNavigationButton(
//                                         icon: Icons.chevron_right_rounded,
//                                         onPressed: () {
//                                           pageController.nextPage(
//                                             duration: const Duration(
//                                               milliseconds: 250,
//                                             ),
//                                             curve: Curves.easeOut,
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 14),

//                         // Page indicators
//                         if (images.length > 1)
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(
//                               images.length,
//                               (index) => AnimatedContainer(
//                                 duration: const Duration(milliseconds: 250),
//                                 curve: Curves.easeOut,
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 3,
//                                 ),
//                                 width: currentImage == index ? 24 : 7,
//                                 height: 7,
//                                 decoration: BoxDecoration(
//                                   color: currentImage == index
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Theme.of(
//                                           context,
//                                         ).colorScheme.outlineVariant,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),
//                   const SizedBox(height: 24),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           product["name"] ?? "",
//                           style: Theme.of(context).textTheme.headlineSmall
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 20,
//                             ),

//                             const SizedBox(width: 4),

//                             Text(
//                               "${product["rating"] ?? 0}",
//                               style: Theme.of(context).textTheme.bodyLarge
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),

//                             const SizedBox(width: 8),

//                             Text(
//                               "(${product["reviewsCount"] ?? 0})",
//                               style: TextStyle(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSurfaceVariant,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 20),

//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               "\$${product["price"]}",
//                               style: Theme.of(context).textTheme.headlineSmall
//                                   ?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.success,
//                                   ),
//                             ),

//                             const SizedBox(width: 12),

//                             if (oldPrice > 0)
//                               Text(
//                                 "\$$oldPrice",
//                                 style: TextStyle(
//                                   decoration: TextDecoration.lineThrough,
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onSurfaceVariant,
//                                   fontSize: 18,
//                                 ),
//                               ),

//                             const SizedBox(width: 10),

//                             if (discount > 0)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 5,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.error,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   "-$discount%",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   Card(
//                     elevation: 2,
//                     color: Theme.of(context).colorScheme.surface,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           _buildInfoRow(
//                             Icons.category_outlined,
//                             t.category,
//                             getLocalizedCategory(
//                               context,
//                               product["category"]?.toString() ?? "-",
//                             ),
//                           ),

//                           const Divider(),

//                           _buildInfoRow(
//                             Icons.branding_watermark_outlined,
//                             t.brand,
//                             product["brand"] ?? "-",
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.description_outlined,
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),

//                               const SizedBox(width: 8),

//                               Text(
//                                 t.description,
//                                 style: Theme.of(context).textTheme.titleMedium
//                                     ?.copyWith(fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 16),

//                           Text(
//                             product["description"] ?? t.noDescriptionAvailable,
//                             style: Theme.of(
//                               context,
//                             ).textTheme.bodyMedium?.copyWith(height: 1.6),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   Text(
//                     t.statistics,
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1.2,
//                     children: [
//                       _buildStatCard(
//                         Icons.star_rounded,
//                         t.rating,
//                         "${product["rating"] ?? 0}",
//                         Colors.amber,
//                       ),
//                       _buildStatCard(
//                         Icons.rate_review_rounded,
//                         t.reviews,
//                         "${product["reviewsCount"] ?? 0}",
//                         AppColors.info,
//                       ),
//                       _buildStatCard(
//                         Icons.inventory_2_rounded,
//                         t.stock,
//                         "${product["stock"] ?? 0}",
//                         AppColors.success,
//                       ),
//                       _buildStatCard(
//                         Icons.local_offer_rounded,
//                         t.discount,
//                         "$discount%",
//                         AppColors.error,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),

//                   Center(
//                     child: SizedBox(
//                       width: 220,
//                       height: 44,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.edit_rounded, size: 18),
//                         label: Text(
//                           t.editProduct,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () async {
//                           await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   EditProductPage(productId: widget.productId),
//                             ),
//                           );

//                           if (!mounted) return;

//                           setState(() {
//                             productFuture = getProduct();
//                             currentImage = 0;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   Center(
//                     child: SizedBox(
//                       width: 220,
//                       height: 44,
//                       child: OutlinedButton.icon(
//                         icon: Icon(
//                           Icons.delete_rounded,
//                           color: AppColors.error,
//                           size: 18,
//                         ),
//                         label: Text(
//                           t.deleteProduct,
//                           style: TextStyle(
//                             color: AppColors.error,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           side: const BorderSide(color: AppColors.error),
//                         ),
//                         onPressed: () async {
//                           final confirm = await showDialog<bool>(
//                             context: context,
//                             builder: (context) {
//                               return AlertDialog(
//                                 title: const Text("Delete Product"),
//                                 content: Text(t.deleteProductConfirmation),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () {
//                                       Navigator.pop(context, false);
//                                     },
//                                     child: Text(t.cancel),
//                                   ),
//                                   ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.pop(context, true);
//                                     },
//                                     child: Text(t.delete),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );

//                           if (confirm == true) {
//                             await deleteProduct(product);
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String title, String value) {
//     return Row(
//       children: [
//         Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),

//         const SizedBox(width: 12),

//         Expanded(
//           child: Text(
//             title,
//             style: Theme.of(
//               context,
//             ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
//           ),
//         ),

//         Text(
//           value,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(
//     IconData icon,
//     String title,
//     String value,
//     Color color,
//   ) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//         side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Container(
//               width: 46,
//               height: 46,
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),

//             const SizedBox(width: 12),

//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     value,
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageNavigationButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return Material(
//       color: Colors.black.withValues(alpha: 0.45),
//       shape: const CircleBorder(),
//       child: InkWell(
//         onTap: onPressed,
//         customBorder: const CircleBorder(),
//         child: SizedBox(
//           width: 38,
//           height: 38,
//           child: Icon(icon, color: Colors.white, size: 24),
//         ),
//       ),
//     );
//   }
// }
