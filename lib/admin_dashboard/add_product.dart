import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController oldPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String? selectedBrand;
  String? selectedCategory;
  String? selectedSubcategory;
  List<String> allowedCategories = [];
  bool isLoadingCategories = true;

  final List<String> categories = [
    'smartphones',
    'computers',
    'electronics',
    'perfumes',
    'accessories',
    'fashion',
    'gold',
    'silver',
    'beauty',
    'furniture',
    'sports',
    'gaming',
    'other',
  ];

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

  List<XFile> selectedImages = [];

  final ImagePicker picker = ImagePicker();

  bool isLoading = false;
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

      case "Body Care":
        return t.bodyCare;

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

  List<String> get availableSubcategories {
    final categoryKey = selectedCategory?.trim().toLowerCase();

    if (categoryKey == null || categoryKey.isEmpty) {
      return [];
    }

    return subcategories[categoryKey] ?? ['Other'];
  }

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
          .where((category) => categories.contains(category))
          .toList();

      if (!mounted) return;

      setState(() {
        allowedCategories = loadedCategories;
        isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        allowedCategories = [];
        isLoadingCategories = false;
      });
    }
  }

  Future<void> pickFromGallery() async {
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  Future<void> pickFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  void showImagePickerDialog() {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.selectImages, style: theme.textTheme.titleLarge),
        content: SizedBox(
          width: 320,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.photo_rounded,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      pickFromGallery();
                    },
                  ),
                  Text(t.gallery, style: theme.textTheme.bodyMedium),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      pickFromCamera();
                    },
                  ),
                  Text(t.camera, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> uploadImages(List<XFile> images, String storeId) async {
    final List<String> urls = [];

    for (final image in images) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${image.name}";

      final ref = FirebaseStorage.instance.ref("products/$storeId/$fileName");

      final bytes = await image.readAsBytes();

      final snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: _getContentType(image.name)),
      );

      final url = await snapshot.ref.getDownloadURL();

      urls.add(url);
    }

    return urls;
  }

  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "png":
        return "image/png";
      case "webp":
        return "image/webp";
      case "gif":
        return "image/gif";
      default:
        return "image/jpeg";
    }
  }

  Future<void> addProduct() async {
    final t = AppLocalizations.of(context)!;
    if (isLoadingCategories) {
      return;
    }

    if (allowedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.selectStoreCategories),
        ),
      );
      return;
    }

    if (selectedCategory == null ||
        !allowedCategories.contains(selectedCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(t.pleaseSelectCategory),
        ),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    final storeId = userData?['storeId']?.toString();
    if (!mounted) return;
    if (storeId == null || storeId.isEmpty) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            t.pleaseSelectAnImage,
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final imageUrls = await uploadImages(selectedImages, storeId);

      final oldPrice = double.tryParse(oldPriceController.text.trim()) ?? 0;

      final price = double.tryParse(priceController.text.trim()) ?? 0;

      final stock = int.tryParse(stockController.text.trim()) ?? 0;

      final discount = oldPrice > 0
          ? (((oldPrice - price) / oldPrice) * 100).round()
          : 0;

      final productRef = await FirebaseFirestore.instance
          .collection('products')
          .add({
            'name': nameController.text.trim(),
            'storeId': storeId,
            'price': price,
            'oldPrice': oldPrice,
            'discount': discount,
            'stock': stock,
            'category': selectedCategory,
            'subcategory': selectedSubcategory,
            'brand': selectedBrand,
            'description': descriptionController.text.trim(),
            'images': imageUrls,
            'rating': 0.0,
            'reviewsCount': 0,
            'createdAt': Timestamp.now(),
          });
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .where('storeId', isEqualTo: storeId)
          .get();
      final batch = FirebaseFirestore.instance.batch();

      for (final userDoc in usersSnapshot.docs) {
        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc();

        batch.set(notificationRef, {
          'title': 'newProductNotification',
          'body': 'newProductNotificationBody',
          'type': 'product',
          'recipient': 'user',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'productName': nameController.text.trim(),
          'productId': productRef.id,
          'userId': userDoc.id,
          'storeId': storeId,
        });
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            t.productAddedSuccessfully,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      );

      nameController.clear();
      oldPriceController.clear();
      priceController.clear();
      stockController.clear();
      descriptionController.clear();
      setState(() {
        selectedImages.clear();
        selectedCategory = null;
        selectedSubcategory = null;
        selectedBrand = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            t.somethingWentWrong,
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: showImagePickerDialog,
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 38,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.selectImages,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${t.gallery} • ${t.camera}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: ResizeImage(
                            MemoryImage(
                              // This image is replaced below by the
                              // FutureBuilder preview.
                              Uint8List(0),
                            ),
                            width: 1,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                            );
                          },
                        ),
                        FutureBuilder<Uint8List>(
                          future: selectedImages.first.readAsBytes(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: colorScheme.surface.withValues(alpha: 0.9),
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: showImagePickerDialog,
                              icon: Icon(
                                Icons.edit_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        if (selectedImages.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final image = selectedImages[index];

                return FutureBuilder<Uint8List>(
                  future: image.readAsBytes(),
                  builder: (context, snapshot) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          final selected = selectedImages.removeAt(index);
                          selectedImages.insert(0, selected);
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: index == 0
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: index == 0 ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: snapshot.hasData
                                  ? Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 3,
                            right: 3,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.error,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 15,
                                  color: colorScheme.onError,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 8),

        Text(
          "${selectedImages.length} ${t.selectImages}",
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: inputDecoration(
        context: context,
        label: label,
        icon: icon,
      ).copyWith(counterText: "", hintText: hintText),
      validator: validator,
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      isExpanded: true,
      decoration: inputDecoration(
        context: context,
        label: t.category,
        icon: Icons.category_rounded,
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
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
          selectedSubcategory = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return t.pleaseSelectCategory;
        }
        return null;
      },
    );
  }

  Widget _buildSubcategoryDropdown(BuildContext context) {
    final options = availableSubcategories;
    final t = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedCategory),
      initialValue: selectedSubcategory,
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
      onChanged: selectedCategory == null
          ? null
          : (value) {
              setState(() {
                selectedSubcategory = value;
              });
            },
      validator: (value) {
        if (selectedCategory != null &&
            options.isNotEmpty &&
            (value == null || value.isEmpty)) {
          return 'Please select a subcategory';
        }
        return null;
      },
    );
  }

  Widget _buildBrandDropdown(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      initialValue: selectedBrand,
      isExpanded: true,
      decoration: inputDecoration(
        context: context,
        label: t.brand,
        icon: Icons.business_rounded,
      ),
      items: brands.map((brand) {
        return DropdownMenuItem<String>(
          value: brand,
          child: Text(brand, overflow: TextOverflow.ellipsis),
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
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : addProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onPrimary,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.addProduct,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadStoreCategories();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;

    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 16,
            vertical: isDesktop ? 32 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Form(
                key: _formKey,
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 340,
                            child: _buildImagePicker(context),
                          ),
                          const SizedBox(width: 32),
                          Expanded(child: _buildFormContent(context, t)),
                        ],
                      )
                    : _buildMobileContent(context, t),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImagePicker(context),
        const SizedBox(height: 24),
        _buildFormContent(context, t),
      ],
    );
  }

  Widget _buildFormContent(BuildContext context, AppLocalizations t) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final bool useTwoColumns = screenWidth >= 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          context: context,
          controller: nameController,
          label: t.productName,
          icon: Icons.drive_file_rename_outline_rounded,
          hintText: t.productNameHint,
          maxLength: 25,
          textCapitalization: TextCapitalization.words,
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

        const SizedBox(height: 16),

        if (useTwoColumns)
          Row(
            children: [
              Expanded(
                child: _buildField(
                  context: context,
                  controller: priceController,
                  label: t.price,
                  icon: Icons.attach_money_rounded,
                  hintText: t.priceHint,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(8)],
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
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildField(
                  context: context,
                  controller: oldPriceController,
                  label: t.oldPrice,
                  icon: Icons.money_off_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          )
        else ...[
          _buildField(
            context: context,
            controller: priceController,
            label: t.price,
            icon: Icons.attach_money_rounded,
            hintText: t.priceHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [LengthLimitingTextInputFormatter(8)],
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
          const SizedBox(height: 16),
          _buildField(
            context: context,
            controller: oldPriceController,
            label: t.oldPrice,
            icon: Icons.money_off_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null; // oldPrice optional
              }

              final oldPrice = double.tryParse(value.trim());

              if (oldPrice == null || oldPrice <= 0) {
                return t.invalidOldPrice;
              }

              final price = double.tryParse(priceController.text.trim());

              if (price != null && oldPrice <= price) {
                return t.oldPriceMustBeGreaterThanPrice;
              }

              return null;
            },
          ),
        ],

        const SizedBox(height: 16),

        if (useTwoColumns)
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown(context)),
              const SizedBox(width: 14),
              Expanded(child: _buildBrandDropdown(context)),
            ],
          )
        else ...[
          _buildCategoryDropdown(context),
          const SizedBox(height: 16),
          _buildBrandDropdown(context),
        ],

        const SizedBox(height: 16),
        _buildSubcategoryDropdown(context),
        const SizedBox(height: 16),
        _buildField(
          context: context,
          controller: stockController,
          label: t.stock,
          icon: Icons.inventory_2_rounded,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return t.enterStock;
            }

            final stock = int.tryParse(val);

            if (stock == null) {
              return t.invalidStock;
            }

            if (stock < 0) {
              return t.stockCannotBeNegative;
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        _buildField(
          context: context,
          controller: descriptionController,
          label: t.description,
          icon: Icons.description_rounded,
          hintText: t.shortDescriptionHint,
          maxLines: 4,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
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

        const SizedBox(height: 24),

        _buildAddButton(context),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    oldPriceController.dispose();
    stockController.dispose();

    super.dispose();
  }
}
