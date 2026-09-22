import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_product_details_page.dart';
import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.products),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
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
                        isDesktop: false,
                        t: t,
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
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                  product["images"] != null &&
                          product["images"] is List &&
                          (product["images"] as List).isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            (product["images"] as List).first.toString(),
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
                        )
                      : SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: const Icon(Icons.image, size: 50),
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

                              await FirebaseFirestore.instance
                                  .collection("products")
                                  .doc(docId)
                                  .delete();

                              messenger.showSnackBar(
                                SnackBar(content: Text(t.productDeleted)),
                              );
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
                      "\$${price.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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

// import 'package:ecomerce_app/admin_dashboard/admin_product_details_page.dart';
// import 'package:ecomerce_app/admin_dashboard/edit_product_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductPage extends StatelessWidget {
//   const ProductPage({super.key});

//   // 🔥 Fix any type (String / double / int)
//   double parsePrice(dynamic price) {
//     if (price is double) return price;
//     if (price is int) return price.toDouble();
//     if (price is String) return double.tryParse(price) ?? 0;
//     return 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(t.products),
//         leading: const CustomBackButton(),
//       ),
//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('products')
//               .orderBy('createdAt', descending: true)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text(
//                   t.noProductsAvailable,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final products = snapshot.data!.docs;

//             return ListView.builder(
//               padding: const EdgeInsets.all(15),
//               itemCount: products.length,
//               itemBuilder: (context, index) {
//                 final product = products[index].data() as Map<String, dynamic>;

//                 final docId = products[index].id;

//                 final double price = parsePrice(product['price']);
//                 final double oldPrice = parsePrice(product['oldPrice']);

//                 final int discount = oldPrice > 0 && price < oldPrice
//                     ? (((oldPrice - price) / oldPrice) * 100).round()
//                     : 0;
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 3,
//                   color: Theme.of(context).colorScheme.surface,

//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               AdminProductDetailsPage(productId: docId),
//                         ),
//                       );
//                     },
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.all(10),
//                       leading: Stack(
//                         children: [
//                           product["images"] != null &&
//                                   product["images"] is List &&
//                                   (product["images"] as List).isNotEmpty
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     (product["images"] as List).first
//                                         .toString(),
//                                     width: 60,
//                                     height: 60,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (_, _, _) {
//                                       return const Icon(Icons.image, size: 50);
//                                     },
//                                   ),
//                                 )
//                               : const SizedBox(
//                                   width: 60,
//                                   height: 60,
//                                   child: Icon(Icons.image, size: 50),
//                                 ),

//                           if (discount > 0)
//                             Positioned(
//                               top: 2,
//                               left: 2,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 5,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).colorScheme.error,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Text(
//                                   "-$discount%",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 8,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       title: Text(
//                         product['name']?.toString().trim().isNotEmpty == true
//                             ? product['name'].toString()
//                             : t.unknown,
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product['description'] ?? "",
//                             style: TextStyle(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           Text(
//                             "\$${price.toStringAsFixed(2)}",
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                         ],
//                       ),
//                       trailing: PopupMenuButton<String>(
//                         onSelected: (value) async {
//                           if (value == "edit") {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     EditProductPage(productId: docId),
//                               ),
//                             );
//                           }

//                           if (value == "delete") {
//                             final messenger = ScaffoldMessenger.of(context);

//                             await FirebaseFirestore.instance
//                                 .collection("products")
//                                 .doc(docId)
//                                 .delete();

//                             messenger.showSnackBar(
//                               SnackBar(content: Text(t.productDeleted)),
//                             );
//                           }
//                         },
//                         itemBuilder: (context) => [
//                           PopupMenuItem(
//                             value: "edit",
//                             child: Row(
//                               children: [
//                                 Icon(Icons.edit, color: AppColors.success),
//                                 SizedBox(width: 10),
//                                 Text(t.edit),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem(
//                             value: "delete",
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.delete,
//                                   color: Theme.of(context).colorScheme.error,
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(t.delete),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
