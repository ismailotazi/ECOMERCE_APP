import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({super.key, required this.productId});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class EditableImage {
  String? url;
  String? oldUrl;
  File? file;

  EditableImage({this.url, this.oldUrl, this.file});

  bool get isNew => file != null;
}

class _EditProductPageState extends State<EditProductPage> {
  List<EditableImage> images = [];
  final ImagePicker picker = ImagePicker();

  String? selectedBrand;
  String? selectedCategory;
  final List<String> categories = [
    "Electronics",
    "Smartphones",
    "Laptops",
    "Tablets",
    "Smartwatches",
    "Accessories",
    "Audio",
    "Gaming",
    "Home Appliances",
    "Perfumes",
    "Beauty",
    "Clothing",
    "Shoes",
    "Bags",
    "Watches",
    "Jewelry",
    "Glasses",
    "Sports",
    "Books",
    "Toys",
    "Furniture",
    "Food",
    "Health",
    "Automotive",
    "Other",
  ];
  final List<String> brands = [
    "Apple",
    "Samsung",
    "Sony",
    "LG",
    "Xiaomi",
    "Huawei",
    "Google",
    "Dell",
    "HP",
    "Lenovo",
    "ASUS",
    "Acer",
    "MSI",

    "Nike",
    "Adidas",
    "Puma",
    "Reebok",
    "New Balance",
    "ASICS",
    "Under Armour",
    "Converse",
    "Vans",
    "Jordan",
    "Skechers",
    "Timberland",

    "Zara",
    "H&M",
    "Uniqlo",
    "Pull&Bear",
    "Bershka",
    "Stradivarius",
    "Mango",
    "Massimo Dutti",
    "Levi's",
    "Tommy Hilfiger",
    "Calvin Klein",
    "Lacoste",
    "Ralph Lauren",

    "Ray-Ban",
    "Oakley",
    "Persol",
    "Gucci",
    "Prada",
    "Versace",
    "Dior",

    "Chanel",
    "Dior",
    "Yves Saint Laurent",
    "Armani",
    "Givenchy",
    "Tom Ford",
    "Jo Malone",
    "Creed",
    "Dolce & Gabbana",

    "Rolex",
    "Casio",
    "Seiko",
    "Tissot",
    "Omega",

    "Louis Vuitton",
    "Hermès",
    "Burberry",
    "Balenciaga",
    "Fendi",

    "Other",
  ];

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

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final oldPriceController = TextEditingController();

  final stockController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  // update product
  Future<void> updateProduct() async {
    final t = AppLocalizations.of(context)!;

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.pleaseAddAtLeastOneImage),
        ),
      );
      return;
    }

    final productRef = FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId);

    final oldProductSnapshot = await productRef.get();

    if (!oldProductSnapshot.exists) return;

    final oldProductData = oldProductSnapshot.data()!;

    final previousPrice = (oldProductData["price"] as num?)?.toDouble() ?? 0;

    final previousOldPrice =
        (oldProductData["oldPrice"] as num?)?.toDouble() ?? 0;

    final newPrice = double.tryParse(priceController.text.trim()) ?? 0;

    final newOldPrice = double.tryParse(oldPriceController.text.trim()) ?? 0;

    final wasPromotion =
        previousOldPrice > 0 && previousPrice < previousOldPrice;

    final isPromotion = newOldPrice > 0 && newPrice < newOldPrice;

    final oldImages = images
        .where((e) => e.oldUrl != null)
        .map((e) => e.oldUrl!)
        .toList();

    final imageUrls = await uploadEditedImages();

    for (final url in oldImages) {
      if (!imageUrls.contains(url)) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (e) {
          debugPrint("Error deleting image: $e");
        }
      }
    }

    await productRef.update({
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "price": newPrice,
      "oldPrice": newOldPrice,
      "stock": int.tryParse(stockController.text) ?? 0,
      "category": selectedCategory,
      "brand": selectedBrand,
      "image": imageUrls.first,
      "images": imageUrls,
    });

    // Send promotion notification only when a new promotion starts
    if (isPromotion && !wasPromotion) {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("role", isEqualTo: "user")
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final userDoc in usersSnapshot.docs) {
        final notificationRef = FirebaseFirestore.instance
            .collection("notifications")
            .doc();

        batch.set(notificationRef, {
          "title": "promotionNotification",
          "body": "promotionNotificationBody",
          "type": "promotion",
          "recipient": "user",
          "isRead": false,
          "createdAt": FieldValue.serverTimestamp(),
          "productName": nameController.text.trim(),
          "productId": widget.productId,
          "oldPrice": newOldPrice,
          "newPrice": newPrice,
          "userId": userDoc.id,
        });
      }

      await batch.commit();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(t.productUpdatedSuccessfully),
      ),
    );

    Navigator.pop(context);
  }

  // load product
  Future<void> loadProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    nameController.text = data["name"] ?? "";
    descriptionController.text = data["description"] ?? "";
    priceController.text = data["price"].toString();
    oldPriceController.text = data["oldPrice"].toString();
    stockController.text = data["stock"].toString();

    setState(() {
      selectedCategory = data["category"];
      selectedBrand = data["brand"];

      images = (data["images"] as List)
          .map((e) => EditableImage(url: e, oldUrl: e))
          .toList();

      isLoading = false;
    });
  }

  Future<void> pickFromGallery() async {
    final pickedImages = await picker.pickMultiImage();

    if (pickedImages.isEmpty) return;

    setState(() {
      images.addAll(pickedImages.map((e) => EditableImage(file: File(e.path))));
    });
  }

  Future<List<String>> uploadEditedImages() async {
    List<String> finalUrls = [];

    for (final image in images) {
      if (image.file != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();

        final ref = FirebaseStorage.instance.ref("products/$fileName");

        final snapshot = await ref.putFile(image.file!);

        final url = await snapshot.ref.getDownloadURL();

        finalUrls.add(url);
      } else if (image.url != null) {
        finalUrls.add(image.url!);
      }
    }

    return finalUrls;
  }

  void showImagePickerDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.selectImages),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.photo,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                pickFromGallery();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showImageOptions(int index) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(t.replaceImage),
                onTap: () {
                  Navigator.pop(context);
                  pickReplacementImage(index);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  t.deleteImage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  deleteImage(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  Future<void> pickReplacementImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      images[index] = EditableImage(
        oldUrl: images[index].oldUrl,
        file: File(picked.path),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 28.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.editProduct),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Form(
                key: _formKey,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      children: [
                        SizedBox(
                          height: isDesktop ? 125 : 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length + 1,
                            itemBuilder: (_, index) {
                              if (index == images.length) {
                                return GestureDetector(
                                  onTap: () {
                                    showImagePickerDialog();
                                  },
                                  child: Container(
                                    width: isDesktop ? 115 : 100,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: isDesktop ? 42 : 40,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                );
                              }

                              final image = images[index];

                              return GestureDetector(
                                onTap: () => showImageOptions(index),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: image.file != null
                                        ? Image.file(
                                            image.file!,
                                            width: isDesktop ? 115 : 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            image.url!,
                                            width: isDesktop ? 115 : 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) {
                                              return Container(
                                                width: isDesktop ? 115 : 100,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: isDesktop ? 20 : 15),

                        TextFormField(
                          controller: nameController,
                          maxLength: 25,
                          textCapitalization: TextCapitalization.words,
                          decoration:
                              inputDecoration(
                                context: context,
                                label: t.productName,
                                icon: Icons.drive_file_rename_outline,
                              ).copyWith(
                                counterText: "",
                                hintText: t.productNameHint,
                              ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return t.enterProductName;
                            }

                            final name = val.trim();

                            if (name.length < 3) {
                              return t.nameIsTooShort;
                            }

                            if (name.length > 25) {
                              return t.maximum25Characters;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          maxLength: 80,
                          textCapitalization: TextCapitalization.sentences,
                          decoration:
                              inputDecoration(
                                context: context,
                                label: t.description,
                                icon: Icons.description,
                              ).copyWith(
                                counterText: "",
                                hintText: t.shortDescriptionHint,
                              ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return t.enterDescription;
                            }

                            final description = val.trim();

                            if (description.length < 3) {
                              return t.descriptionIsTooShort;
                            }

                            if (description.length > 80) {
                              return t.maximum80Characters;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          maxLength: 8,
                          decoration: inputDecoration(
                            context: context,
                            label: t.price,
                            icon: Icons.attach_money,
                          ).copyWith(counterText: "", hintText: t.priceHint),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return t.enterPrice;
                            }

                            final price = double.tryParse(val);

                            if (price == null) {
                              return t.invalidPrice;
                            }

                            if (price <= 0) {
                              return t.priceMustBeGreaterThanZero;
                            }

                            if (price > 99999.99) {
                              return t.maximumPrice;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: oldPriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          maxLength: 8,
                          decoration: inputDecoration(
                            context: context,
                            label: t.oldPrice,
                            icon: Icons.money_off,
                          ).copyWith(counterText: "", hintText: t.oldPriceHint),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return null; // اختياري
                            }

                            final oldPrice = double.tryParse(val);

                            if (oldPrice == null) {
                              return t.invalidOldPrice;
                            }

                            if (oldPrice <= 0) {
                              return t.oldPriceMustBeGreaterThanZero;
                            }

                            if (oldPrice > 99999.99) {
                              return t.maximumPrice;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: inputDecoration(
                            context: context,
                            label: t.stock,
                            icon: Icons.inventory,
                          ).copyWith(counterText: "", hintText: t.stockHint),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return t.enterStockQuantity;
                            }

                            final stock = int.tryParse(val);

                            if (stock == null) {
                              return t.invalidStock;
                            }

                            if (stock < 0) {
                              return t.stockCannotBeNegative;
                            }

                            if (stock > 999999) {
                              return t.maximumStock;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: inputDecoration(
                            context: context,
                            label: t.category,
                            icon: Icons.category,
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                getLocalizedCategory(context, category),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.pleaseSelectCategory;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          initialValue: selectedBrand,
                          decoration: inputDecoration(
                            context: context,
                            label: t.brand,
                            icon: Icons.business,
                          ),
                          items: brands.map((brand) {
                            return DropdownMenuItem(
                              value: brand,
                              child: Text(brand),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBrand = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.pleaseSelectBrand;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isDesktop ? 36 : 30),

                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await updateProduct();
                              }
                            },
                            child: Text(
                              t.updateProduct,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/theme/input_decoration.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProductPage extends StatefulWidget {
//   final String productId;

//   const EditProductPage({super.key, required this.productId});

//   @override
//   State<EditProductPage> createState() => _EditProductPageState();
// }

// class EditableImage {
//   String? url;
//   String? oldUrl;
//   File? file;

//   EditableImage({this.url, this.oldUrl, this.file});

//   bool get isNew => file != null;
// }

// class _EditProductPageState extends State<EditProductPage> {
//   List<EditableImage> images = [];
//   final ImagePicker picker = ImagePicker();

//   String? selectedBrand;
//   String? selectedCategory;
//   final List<String> categories = [
//     "Electronics",
//     "Smartphones",
//     "Laptops",
//     "Tablets",
//     "Smartwatches",
//     "Accessories",
//     "Audio",
//     "Gaming",
//     "Home Appliances",
//     "Perfumes",
//     "Beauty",
//     "Clothing",
//     "Shoes",
//     "Bags",
//     "Watches",
//     "Jewelry",
//     "Glasses",
//     "Sports",
//     "Books",
//     "Toys",
//     "Furniture",
//     "Food",
//     "Health",
//     "Automotive",
//     "Other",
//   ];
//   final List<String> brands = [
//     "Apple",
//     "Samsung",
//     "Sony",
//     "LG",
//     "Xiaomi",
//     "Huawei",
//     "Google",
//     "Dell",
//     "HP",
//     "Lenovo",
//     "ASUS",
//     "Acer",
//     "MSI",

//     "Nike",
//     "Adidas",
//     "Puma",
//     "Reebok",
//     "New Balance",
//     "ASICS",
//     "Under Armour",
//     "Converse",
//     "Vans",
//     "Jordan",
//     "Skechers",
//     "Timberland",

//     "Zara",
//     "H&M",
//     "Uniqlo",
//     "Pull&Bear",
//     "Bershka",
//     "Stradivarius",
//     "Mango",
//     "Massimo Dutti",
//     "Levi's",
//     "Tommy Hilfiger",
//     "Calvin Klein",
//     "Lacoste",
//     "Ralph Lauren",

//     "Ray-Ban",
//     "Oakley",
//     "Persol",
//     "Gucci",
//     "Prada",
//     "Versace",
//     "Dior",

//     "Chanel",
//     "Dior",
//     "Yves Saint Laurent",
//     "Armani",
//     "Givenchy",
//     "Tom Ford",
//     "Jo Malone",
//     "Creed",
//     "Dolce & Gabbana",

//     "Rolex",
//     "Casio",
//     "Seiko",
//     "Tissot",
//     "Omega",

//     "Louis Vuitton",
//     "Hermès",
//     "Burberry",
//     "Balenciaga",
//     "Fendi",

//     "Other",
//   ];
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

//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final priceController = TextEditingController();
//   final oldPriceController = TextEditingController();

//   final stockController = TextEditingController();

//   bool isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     loadProduct();
//   }

//   // update product
//   Future<void> updateProduct() async {
//     final t = AppLocalizations.of(context)!;

//     if (images.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Theme.of(context).colorScheme.error,
//           content: Text(t.pleaseAddAtLeastOneImage),
//         ),
//       );
//       return;
//     }

//     final productRef = FirebaseFirestore.instance
//         .collection("products")
//         .doc(widget.productId);

//     final oldProductSnapshot = await productRef.get();

//     if (!oldProductSnapshot.exists) return;

//     final oldProductData = oldProductSnapshot.data()!;

//     final previousPrice = (oldProductData["price"] as num?)?.toDouble() ?? 0;

//     final previousOldPrice =
//         (oldProductData["oldPrice"] as num?)?.toDouble() ?? 0;

//     final newPrice = double.tryParse(priceController.text.trim()) ?? 0;

//     final newOldPrice = double.tryParse(oldPriceController.text.trim()) ?? 0;

//     final wasPromotion =
//         previousOldPrice > 0 && previousPrice < previousOldPrice;

//     final isPromotion = newOldPrice > 0 && newPrice < newOldPrice;

//     final oldImages = images
//         .where((e) => e.oldUrl != null)
//         .map((e) => e.oldUrl!)
//         .toList();

//     final imageUrls = await uploadEditedImages();

//     for (final url in oldImages) {
//       if (!imageUrls.contains(url)) {
//         try {
//           await FirebaseStorage.instance.refFromURL(url).delete();
//         } catch (e) {
//           debugPrint("Error deleting image: $e");
//         }
//       }
//     }

//     await productRef.update({
//       "name": nameController.text.trim(),
//       "description": descriptionController.text.trim(),
//       "price": newPrice,
//       "oldPrice": newOldPrice,
//       "stock": int.tryParse(stockController.text) ?? 0,
//       "category": selectedCategory,
//       "brand": selectedBrand,
//       "image": imageUrls.first,
//       "images": imageUrls,
//     });

//     // Send promotion notification only when a new promotion starts
//     if (isPromotion && !wasPromotion) {
//       final usersSnapshot = await FirebaseFirestore.instance
//           .collection("users")
//           .where("role", isEqualTo: "user")
//           .get();

//       final batch = FirebaseFirestore.instance.batch();

//       for (final userDoc in usersSnapshot.docs) {
//         final notificationRef = FirebaseFirestore.instance
//             .collection("notifications")
//             .doc();

//         batch.set(notificationRef, {
//           "title": "promotionNotification",
//           "body": "promotionNotificationBody",
//           "type": "promotion",
//           "recipient": "user",
//           "isRead": false,
//           "createdAt": FieldValue.serverTimestamp(),
//           "productName": nameController.text.trim(),
//           "productId": widget.productId,
//           "oldPrice": newOldPrice,
//           "newPrice": newPrice,
//           "userId": userDoc.id,
//         });
//       }

//       await batch.commit();
//     }

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         content: Text(t.productUpdatedSuccessfully),
//       ),
//     );

//     Navigator.pop(context);
//   }

//   // load product
//   Future<void> loadProduct() async {
//     final doc = await FirebaseFirestore.instance
//         .collection("products")
//         .doc(widget.productId)
//         .get();

//     if (!doc.exists) return;

//     final data = doc.data()!;

//     nameController.text = data["name"] ?? "";
//     descriptionController.text = data["description"] ?? "";
//     priceController.text = data["price"].toString();
//     oldPriceController.text = data["oldPrice"].toString();
//     stockController.text = data["stock"].toString();

//     setState(() {
//       selectedCategory = data["category"];
//       selectedBrand = data["brand"];

//       images = (data["images"] as List)
//           .map((e) => EditableImage(url: e, oldUrl: e))
//           .toList();

//       isLoading = false;
//     });
//   }

//   Future<void> pickFromGallery() async {
//     final pickedImages = await picker.pickMultiImage();

//     if (pickedImages.isEmpty) return;

//     setState(() {
//       images.addAll(pickedImages.map((e) => EditableImage(file: File(e.path))));
//     });
//   }

//   Future<List<String>> uploadEditedImages() async {
//     List<String> finalUrls = [];

//     for (final image in images) {
//       if (image.file != null) {
//         final fileName = DateTime.now().millisecondsSinceEpoch.toString();

//         final ref = FirebaseStorage.instance.ref("products/$fileName");

//         final snapshot = await ref.putFile(image.file!);

//         final url = await snapshot.ref.getDownloadURL();

//         finalUrls.add(url);
//       } else if (image.url != null) {
//         finalUrls.add(image.url!);
//       }
//     }

//     return finalUrls;
//   }

//   void showImagePickerDialog() {
//     final t = AppLocalizations.of(context)!;
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(t.selectImages),

//         content: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             IconButton(
//               icon: Icon(
//                 Icons.photo,
//                 size: 40,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               onPressed: () {
//                 pickFromGallery();
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void showImageOptions(int index) {
//     final t = AppLocalizations.of(context)!;
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: Icon(
//                   Icons.photo,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 title: Text(t.replaceImage),
//                 onTap: () {
//                   Navigator.pop(context);
//                   pickReplacementImage(index);
//                 },
//               ),

//               ListTile(
//                 leading: Icon(
//                   Icons.delete,
//                   color: Theme.of(context).colorScheme.error,
//                 ),
//                 title: Text(
//                   t.deleteImage,
//                   style: TextStyle(color: Theme.of(context).colorScheme.error),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   deleteImage(index);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void deleteImage(int index) {
//     setState(() {
//       images.removeAt(index);
//     });
//   }

//   Future<void> pickReplacementImage(int index) async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);

//     if (picked == null) return;

//     setState(() {
//       images[index] = EditableImage(
//         oldUrl: images[index].oldUrl,
//         file: File(picked.path),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.editProduct),
//         leading: const CustomBackButton(),
//       ),
//       body: SafeArea(
//         child: isLoading
//             ? Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               )
//             : Form(
//                 key: _formKey,
//                 child: ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     SizedBox(
//                       height: 110,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: images.length + 1,
//                         itemBuilder: (_, index) {
//                           if (index == images.length) {
//                             return GestureDetector(
//                               onTap: () {
//                                 showImagePickerDialog();
//                               },
//                               child: Container(
//                                 width: 100,
//                                 margin: const EdgeInsets.only(right: 10),
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.surfaceContainerHighest,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 child: Icon(
//                                   Icons.add,
//                                   size: 40,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),
//                             );
//                           }

//                           final image = images[index];

//                           return GestureDetector(
//                             onTap: () => showImageOptions(index),
//                             child: Padding(
//                               padding: const EdgeInsets.only(right: 10),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(15),
//                                 child: image.file != null
//                                     ? Image.file(
//                                         image.file!,
//                                         width: 100,
//                                         fit: BoxFit.cover,
//                                       )
//                                     : Image.network(
//                                         image.url!,
//                                         width: 100,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (_, _, _) {
//                                           return Container(
//                                             width: 100,
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .surfaceContainerHighest,
//                                             child: Icon(
//                                               Icons.image_not_supported,
//                                               color: Theme.of(
//                                                 context,
//                                               ).colorScheme.onSurfaceVariant,
//                                             ),
//                                           );
//                                         },
//                                       ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     TextFormField(
//                       controller: nameController,
//                       maxLength: 25,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: inputDecoration(
//                         context: context,
//                         label: t.productName,
//                         icon: Icons.drive_file_rename_outline,
//                       ).copyWith(counterText: "", hintText: t.productNameHint),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return t.enterProductName;
//                         }

//                         final name = val.trim();

//                         if (name.length < 3) {
//                           return t.nameIsTooShort;
//                         }

//                         if (name.length > 25) {
//                           return t.maximum25Characters;
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 15),

//                     TextFormField(
//                       controller: descriptionController,
//                       maxLines: 3,
//                       maxLength: 80,
//                       textCapitalization: TextCapitalization.sentences,
//                       decoration:
//                           inputDecoration(
//                             context: context,
//                             label: t.description,
//                             icon: Icons.description,
//                           ).copyWith(
//                             counterText: "",
//                             hintText: t.shortDescriptionHint,
//                           ),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return t.enterDescription;
//                         }

//                         final description = val.trim();

//                         if (description.length < 3) {
//                           return t.descriptionIsTooShort;
//                         }

//                         if (description.length > 80) {
//                           return t.maximum80Characters;
//                         }

//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 15),

//                     TextFormField(
//                       controller: priceController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       maxLength: 8,
//                       decoration: inputDecoration(
//                         context: context,
//                         label: t.price,
//                         icon: Icons.attach_money,
//                       ).copyWith(counterText: "", hintText: t.priceHint),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return t.enterPrice;
//                         }

//                         final price = double.tryParse(val);

//                         if (price == null) {
//                           return t.invalidPrice;
//                         }

//                         if (price <= 0) {
//                           return t.priceMustBeGreaterThanZero;
//                         }

//                         if (price > 99999.99) {
//                           return t.maximumPrice;
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 15),

//                     TextFormField(
//                       controller: oldPriceController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       maxLength: 8,
//                       decoration: inputDecoration(
//                         context: context,
//                         label: t.oldPrice,
//                         icon: Icons.money_off,
//                       ).copyWith(counterText: "", hintText: t.oldPriceHint),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return null; // اختياري
//                         }

//                         final oldPrice = double.tryParse(val);

//                         if (oldPrice == null) {
//                           return t.invalidOldPrice;
//                         }

//                         if (oldPrice <= 0) {
//                           return t.oldPriceMustBeGreaterThanZero;
//                         }

//                         if (oldPrice > 99999.99) {
//                           return t.maximumPrice;
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 15),

//                     const SizedBox(height: 15),

//                     TextFormField(
//                       controller: stockController,
//                       keyboardType: TextInputType.number,
//                       maxLength: 6,
//                       decoration: inputDecoration(
//                         context: context,
//                         label: t.stock,
//                         icon: Icons.inventory,
//                       ).copyWith(counterText: "", hintText: t.stockHint),
//                       validator: (val) {
//                         if (val == null || val.trim().isEmpty) {
//                           return t.enterStockQuantity;
//                         }

//                         final stock = int.tryParse(val);

//                         if (stock == null) {
//                           return t.invalidStock;
//                         }

//                         if (stock < 0) {
//                           return t.stockCannotBeNegative;
//                         }

//                         if (stock > 999999) {
//                           return t.maximumStock;
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 15),

//                     DropdownButtonFormField<String>(
//                       initialValue: selectedCategory,
//                       decoration: inputDecoration(
//                         context: context,
//                         label: t.category,
//                         icon: Icons.category,
//                       ),
//                       items: categories.map((category) {
//                         return DropdownMenuItem(
//                           value: category,
//                           child: Text(getLocalizedCategory(context, category)),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedCategory = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return t.pleaseSelectCategory;
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 15),

//                     DropdownButtonFormField<String>(
//                       initialValue: selectedBrand,
//                       decoration: inputDecoration(
//                         context: context,
//                         label: t.brand,
//                         icon: Icons.business,
//                       ),
//                       items: brands.map((brand) {
//                         return DropdownMenuItem(
//                           value: brand,
//                           child: Text(brand),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedBrand = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return t.pleaseSelectBrand;
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 30),

//                     SizedBox(
//                       height: 55,
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           if (_formKey.currentState!.validate()) {
//                             await updateProduct();
//                           }
//                         },
//                         child: Text(
//                           t.updateProduct,
//                           style: TextStyle(fontSize: 18),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
