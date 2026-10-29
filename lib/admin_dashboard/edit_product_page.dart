import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? selectedSubcategory;

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
    'other': ['Other Products'],
  };
  final List<String> categories = [
    'smartphones',
    'computers',
    'electronics',
    'perfumes',
    'accessories',
    'fashion',
    'beauty',
    'gold',
    'silver',
    'furniture',
    'sports',
    'gaming',
    'other',
  ];
  List<String> allowedCategories = [];
  bool isLoadingCategories = true;
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
      case 'smartphones':
        return t.smartphones;
      case 'computers':
        return t.computers;
      case 'electronics':
        return t.electronics;
      case 'perfumes':
        return t.perfumes;
      case 'accessories':
        return t.accessories;
      case 'fashion':
        return t.fashion;
      case 'gold':
        return t.gold;
      case 'silver':
        return t.silver;
      case 'beauty':
        return t.beauty;
      case 'furniture':
        return t.furniture;
      case 'sports':
        return t.sports;
      case 'gaming':
        return t.gaming;
      case 'other':
        return t.other;
      default:
        return category;
    }
  }

  String getLocalizedSubcategory(BuildContext context, String subcategory) {
    final t = AppLocalizations.of(context)!;

    switch (subcategory) {
      case "Android Phones":
        return t.androidPhones;

      case "iPhones":
        return t.iphones;

      case "Phone Accessories":
        return t.phoneAccessories;

      case "Laptops":
        return t.laptops;

      case "Desktop Computers":
        return t.desktopComputers;

      case "Computer Accessories":
        return t.computerAccessories;

      case "Monitors":
        return t.monitors;

      case "Printers":
        return t.printers;

      case "Televisions":
        return t.televisions;

      case "Audio":
        return t.audio;

      case "Cameras":
        return t.cameras;

      case "Smart Home":
        return t.smartHome;

      case "Electronic Accessories":
        return t.electronicAccessories;

      case "Women":
        return t.women;

      case "Men":
        return t.men;

      case "Kids":
        return t.kids;

      case "Unisex":
        return t.unisex;

      case "Watches":
        return t.watches;

      case "Jewelry":
        return t.jewelry;

      case "Sunglasses":
        return t.sunglasses;

      case "Bags":
        return t.bags;

      case "Wallets":
        return t.wallets;

      case "Shoes":
        return t.shoes;

      case "Skincare":
        return t.skincare;

      case "Makeup":
        return t.makeup;

      case "Hair Care":
        return t.hairCare;

      case "Body Care":
        return t.bodyCare;
      case 'Rings':
        return t.rings;
      case 'Necklaces':
        return t.necklaces;
      case 'Bracelets':
        return t.bracelets;
      case 'Anklets':
        return t.anklets;
      case 'Earrings':
        return t.earrings;
      case 'Gold Chains':
        return t.goldChains;
      case 'Silver Chains':
        return t.silverChains;
      case 'Pendants':
        return t.pendants;
      case 'Gold Sets':
        return t.goldSets;
      case 'Silver Sets':
        return t.silverSets;
      case 'Crowns & Tiaras':
        return t.crownsAndTiaras;
      case 'Other Gold Jewelry':
        return t.otherGoldJewelry;
      case 'Other Silver Jewelry':
        return t.otherSilverJewelry;
      case "Living Room":
        return t.livingRoom;

      case "Bedroom":
        return t.bedroom;

      case "Office":
        return t.office;

      case "Kitchen":
        return t.kitchen;

      case "Outdoor Furniture":
        return t.outdoorFurniture;

      case "Fitness":
        return t.fitness;

      case "Training":
        return t.training;

      case "Sportswear":
        return t.sportswear;

      case "Sports Equipment":
        return t.sportsEquipment;

      case "Consoles":
        return t.consoles;

      case "Games":
        return t.games;

      case "Gaming Accessories":
        return t.gamingAccessories;

      case "Other":
        return t.other;

      case "Other Products":
        return t.otherProducts;

      default:
        return subcategory;
    }
  }

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final oldPriceController = TextEditingController();

  final stockController = TextEditingController();

  bool isLoading = true;
  Future<void> loadStoreCategories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final storeId = userDoc.data()?['storeId']?.toString();

      if (storeId == null || storeId.isEmpty) {
        throw Exception('Store ID not found');
      }

      final storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get();

      if (!storeDoc.exists) {
        throw Exception('Store not found');
      }

      final savedCategories = storeDoc.data()?['categories'];

      if (savedCategories is! List) {
        throw Exception('Store categories are not configured');
      }

      final loadedCategories = savedCategories
          .whereType<String>()
          .map((category) => category.trim().toLowerCase())
          .where((category) => categories.contains(category))
          .toSet()
          .toList();

      if (!mounted) return;

      setState(() {
        allowedCategories = loadedCategories;
        isLoadingCategories = false;

        // إلا كانت الفئة الحالية مسموح بها، نخليوها مختارة.
        if (selectedCategory != null &&
            !allowedCategories.contains(selectedCategory)) {
          selectedCategory = null;
          selectedSubcategory = null;
        }
      });
    } catch (e) {
      debugPrint('LOAD STORE CATEGORIES ERROR: $e');

      if (!mounted) return;

      setState(() {
        allowedCategories = [];
        isLoadingCategories = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProduct();
    loadStoreCategories();
  }

  // update product
  Future<void> updateProduct() async {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    final storeId = userData?["storeId"]?.toString();

    if (storeId == null || storeId.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

      return;
    }
    if (!mounted) return;
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

    if (oldProductData["storeId"]?.toString() != storeId) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

      return;
    }

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

    final imageUrls = await uploadEditedImages(storeId);
    await productRef.update({
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "price": newPrice,
      "oldPrice": newOldPrice,
      "stock": int.tryParse(stockController.text) ?? 0,
      "category": selectedCategory,
      "subcategory": selectedSubcategory,
      "brand": selectedBrand,
      "image": imageUrls.first,
      "images": imageUrls,
    });
    for (final url in oldImages) {
      if (!imageUrls.contains(url)) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (e) {
          debugPrint("Error deleting old image: $e");
        }
      }
    }
    // Send promotion notification only when a new promotion starts
    if (isPromotion && !wasPromotion) {
      final productSnapshot = await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.productId)
          .get();

      if (!productSnapshot.exists) return;

      final productData = productSnapshot.data();

      if (productData == null) return;

      final storeId = productData["storeId"]?.toString();

      if (storeId == null || storeId.isEmpty) return;

      final usersSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("role", isEqualTo: "user")
          .where("storeId", isEqualTo: storeId)
          .get();

      final eligibleUsers = usersSnapshot.docs.where((userDoc) {
        final data = userDoc.data();

        final stores = data["stores"];

        if (stores is! Map<String, dynamic>) {
          return data["storeId"] == storeId;
        }

        final membership = stores[storeId];

        return membership is Map<String, dynamic> &&
            membership["role"] == "user" &&
            membership["isActive"] == true;
      }).toList();

      for (var i = 0; i < eligibleUsers.length; i += 500) {
        final batch = FirebaseFirestore.instance.batch();

        final chunk = eligibleUsers.skip(i).take(500);

        for (final userDoc in chunk) {
          final notificationRef = FirebaseFirestore.instance
              .collection("notifications")
              .doc();

          batch.set(notificationRef, {
            "title": "promotionNotification",
            "body": "promotionNotificationBody",
            "productId": widget.productId,
            "userId": userDoc.id,
            "storeId": storeId,
            "recipient": "user",
            "type": "promotion",
            "isRead": false,
            "createdAt": FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
      }
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
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final storeId = userData?["storeId"]?.toString();

      if (storeId == null || storeId.isEmpty) {
        if (!mounted) return;

        final t = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("products")
          .doc(widget.productId)
          .get();

      if (!doc.exists) {
        return;
      }

      final data = doc.data();

      if (data == null) {
        return;
      }

      // 🔐 Tenant protection
      if (data["storeId"]?.toString() != storeId) {
        if (!mounted) return;

        final t = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));

        return;
      }

      nameController.text = data["name"]?.toString() ?? "";
      descriptionController.text = data["description"]?.toString() ?? "";
      priceController.text = data["price"]?.toString() ?? "0";
      oldPriceController.text = data["oldPrice"]?.toString() ?? "0";
      stockController.text = data["stock"]?.toString() ?? "0";

      final productImages = data["images"];

      final loadedImages = productImages is List
          ? productImages
                .where((e) => e != null && e.toString().trim().isNotEmpty)
                .map(
                  (e) => EditableImage(url: e.toString(), oldUrl: e.toString()),
                )
                .toList()
          : <EditableImage>[];

      // Fallback to old single image field if images is empty.
      if (loadedImages.isEmpty) {
        final singleImage = data["image"]?.toString();

        if (singleImage != null && singleImage.trim().isNotEmpty) {
          loadedImages.add(
            EditableImage(url: singleImage, oldUrl: singleImage),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        selectedCategory = data["category"]?.toString();
        selectedSubcategory = data["subcategory"]?.toString();
        selectedBrand = data["brand"]?.toString();
        images = loadedImages;
      });
    } catch (e) {
      debugPrint("LOAD PRODUCT ERROR: $e");

      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.somethingWentWrong)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<String> get availableSubcategories {
    final categoryKey = selectedCategory?.trim().toLowerCase();

    if (categoryKey == null || categoryKey.isEmpty) {
      return [];
    }

    return subcategories[categoryKey] ?? ['Other'];
  }

  Widget _buildSubcategoryDropdown(BuildContext context) {
    final options = availableSubcategories;
    final t = AppLocalizations.of(context)!;

    final currentValue = options.contains(selectedSubcategory)
        ? selectedSubcategory
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey(selectedCategory),
      initialValue: currentValue,
      isExpanded: true,
      decoration: inputDecoration(
        context: context,
        label: t.subcategory,
        icon: Icons.account_tree_outlined,
      ),
      items: options.map((subcategory) {
        return DropdownMenuItem<String>(
          value: subcategory,
          child: Text(
            getLocalizedSubcategory(context, subcategory),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: options.isEmpty
          ? null
          : (value) {
              setState(() {
                selectedSubcategory = value;
              });
            },
      validator: (value) {
        if (options.isNotEmpty && (value == null || value.isEmpty)) {
          return t.pleaseSelectSubcategory;
        }
        return null;
      },
    );
  }

  Future<void> pickFromGallery() async {
    final pickedImages = await picker.pickMultiImage();

    if (pickedImages.isEmpty) return;

    setState(() {
      images.addAll(pickedImages.map((e) => EditableImage(file: File(e.path))));
    });
  }

  Future<List<String>> uploadEditedImages(String storeId) async {
    List<String> finalUrls = [];

    for (final image in images) {
      if (image.file != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();

        final ref = FirebaseStorage.instance.ref("products/$storeId/$fileName");

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

                            final price = double.tryParse(
                              priceController.text.trim(),
                            );

                            if (price != null && oldPrice <= price) {
                              return t.oldPriceMustBeHigher;
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
                          key: const ValueKey('editProductCategory'),
                          initialValue:
                              allowedCategories.contains(selectedCategory)
                              ? selectedCategory
                              : null,
                          isExpanded: true,
                          decoration:
                              inputDecoration(
                                context: context,
                                label: t.category,
                                icon: Icons.category,
                              ).copyWith(
                                hintText: isLoadingCategories
                                    ? 'Loading categories...'
                                    : null,
                              ),
                          items: allowedCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                getLocalizedCategory(context, category),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged:
                              isLoadingCategories || allowedCategories.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    if (selectedCategory != value) {
                                      selectedSubcategory = null;
                                    }
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
                        _buildSubcategoryDropdown(context),

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
