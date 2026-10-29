import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_product_details_page.dart';
import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  // 🔥 Fix any type (String / double / int)
  double parsePrice(dynamic price) {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(t.products),
          leading: const CustomBackButton(),
        ),
        body: Center(
          child: Text(
            t.somethingWentWrong,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.products),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final userData = userSnapshot.data!.data();

            if (userData == null ||
                userData['role']?.toString() != 'admin' ||
                userData['isActive'] != true) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final storeId = userData['storeId']?.toString();

            if (storeId == null || storeId.isEmpty) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('storeId', isEqualTo: storeId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      t.noProductsAvailable,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 800;

                    // =========================================================
                    // 📱 MOBILE / TABLET
                    // =========================================================
                    if (!isDesktop) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product =
                              products[index].data() as Map<String, dynamic>;

                          final docId = products[index].id;

                          final double price = parsePrice(product['price']);
                          final double oldPrice = parsePrice(
                            product['oldPrice'],
                          );

                          final int discount = oldPrice > 0 && price < oldPrice
                              ? (((oldPrice - price) / oldPrice) * 100).round()
                              : 0;

                          return _buildProductCard(
                            context: context,
                            product: product,
                            docId: docId,
                            price: price,
                            discount: discount,
                            isDesktop: false,
                            t: t,
                            storeId: storeId,
                          );
                        },
                      );
                    }

                    // =========================================================
                    // 💻 WEB / DESKTOP
                    // =========================================================
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 25,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 380,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.35,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product =
                            products[index].data() as Map<String, dynamic>;

                        final docId = products[index].id;

                        final double price = parsePrice(product['price']);
                        final double oldPrice = parsePrice(product['oldPrice']);

                        final int discount = oldPrice > 0 && price < oldPrice
                            ? (((oldPrice - price) / oldPrice) * 100).round()
                            : 0;

                        return _buildProductCard(
                          context: context,
                          product: product,
                          docId: docId,
                          price: price,
                          discount: discount,
                          isDesktop: true,
                          t: t,
                          storeId: storeId,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required Map<String, dynamic> product,
    required String docId,
    required double price,
    required int discount,
    required bool isDesktop,
    required AppLocalizations t,
    required String storeId,
  }) {
    final imageSize = isDesktop ? 100.0 : 60.0;

    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 18 : 12),
      ),
      elevation: isDesktop ? 2 : 3,
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminProductDetailsPage(productId: docId),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 16 : 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Builder(
                    builder: (context) {
                      String? imageUrl;

                      final productImages = product["images"];

                      if (productImages is List && productImages.isNotEmpty) {
                        final firstImage = productImages.first
                            ?.toString()
                            .trim();

                        if (firstImage != null && firstImage.isNotEmpty) {
                          imageUrl = firstImage;
                        }
                      }

                      // Fallback to the old single image field.
                      if (imageUrl == null || imageUrl.isEmpty) {
                        final singleImage = product["image"]?.toString().trim();

                        if (singleImage != null && singleImage.isNotEmpty) {
                          imageUrl = singleImage;
                        }
                      }

                      if (imageUrl == null || imageUrl.isEmpty) {
                        return SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: const Icon(Icons.image, size: 50),
                        );
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return SizedBox(
                              width: imageSize,
                              height: imageSize,
                              child: const Icon(Icons.image, size: 50),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  if (discount > 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "-$discount%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product['name']?.toString().trim().isNotEmpty ==
                                    true
                                ? product['name'].toString()
                                : t.unknown,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) async {
                            if (value == "edit") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProductPage(productId: docId),
                                ),
                              );
                            }

                            if (value == "delete") {
                              final messenger = ScaffoldMessenger.of(context);

                              final productRef = FirebaseFirestore.instance
                                  .collection("products")
                                  .doc(docId);

                              final productDoc = await productRef.get();

                              if (!productDoc.exists) {
                                return;
                              }

                              final productData = productDoc.data();

                              if (productData == null ||
                                  productData["storeId"]?.toString() !=
                                      storeId) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(t.somethingWentWrong)),
                                );
                                return;
                              }

                              try {
                                await productRef.delete();

                                if (!context.mounted) return;

                                messenger.showSnackBar(
                                  SnackBar(content: Text(t.productDeleted)),
                                );
                              } catch (e) {
                                debugPrint("DELETE PRODUCT ERROR: $e");

                                if (!context.mounted) return;

                                messenger.showSnackBar(
                                  SnackBar(content: Text(t.somethingWentWrong)),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: AppColors.success),
                                  const SizedBox(width: 10),
                                  Text(t.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(t.delete),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      product['description'] ?? "",
                      maxLines: isDesktop ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${price.toStringAsFixed(2)} ${t.currencySymbol}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
