import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/input_decoration.dart';
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

  Future<List<String>> uploadImages(List<XFile> images) async {
    final List<String> urls = [];

    for (final image in images) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${image.name}";

      final ref = FirebaseStorage.instance.ref("products/$fileName");

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
      final imageUrls = await uploadImages(selectedImages);

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
            'price': price,
            'oldPrice': oldPrice,
            'discount': discount,
            'stock': stock,
            'category': selectedCategory,
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
      items: categories.map((category) {
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
// import 'dart:io';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/input_decoration.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class AddProductPage extends StatefulWidget {
//   const AddProductPage({super.key});

//   @override
//   State<AddProductPage> createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   final TextEditingController oldPriceController = TextEditingController();

//   final TextEditingController stockController = TextEditingController();
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

//   List<File> selectedImages = [];
//   final ImagePicker picker = ImagePicker();
//   bool isLoading = false;

//   Future pickFromGallery() async {
//     final List<XFile> images = await picker.pickMultiImage();

//     if (images.isNotEmpty) {
//       setState(() {
//         selectedImages = images.map((e) => File(e.path)).toList();
//       });
//     }
//   }

//   Future pickFromCamera() async {
//     final XFile? image = await picker.pickImage(source: ImageSource.camera);
//     if (image != null) setState(() => selectedImages.add(File(image.path)));
//   }

//   void showImagePickerDialog() {
//     final theme = Theme.of(context);
//     final t = AppLocalizations.of(context)!;
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(t.selectImages, style: theme.textTheme.titleLarge),
//         content: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.photo,
//                     size: 40,
//                     color: theme.colorScheme.primary,
//                   ),
//                   onPressed: () {
//                     pickFromGallery();
//                     Navigator.pop(context);
//                   },
//                 ),
//                 Text(t.gallery, style: theme.textTheme.bodyMedium),
//               ],
//             ),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.camera_alt,
//                     size: 40,
//                     color: theme.colorScheme.primary,
//                   ),
//                   onPressed: () {
//                     pickFromCamera();
//                     Navigator.pop(context);
//                   },
//                 ),
//                 Text(t.camera, style: theme.textTheme.bodyMedium),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<List<String>> uploadImages(List<File> images) async {
//     List<String> urls = [];

//     for (final image in images) {
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();

//       final ref = FirebaseStorage.instance.ref("products/$fileName");

//       final snapshot = await ref.putFile(image);

//       final url = await snapshot.ref.getDownloadURL();

//       urls.add(url);
//     }

//     return urls;
//   }

//   Future<void> addProduct() async {
//     final t = AppLocalizations.of(context)!;

//     if (!_formKey.currentState!.validate()) return;

//     if (selectedImages.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Theme.of(context).colorScheme.error,
//           content: Text(
//             t.pleaseSelectAnImage,
//             style: TextStyle(color: Theme.of(context).colorScheme.onError),
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final imageUrls = await uploadImages(selectedImages);

//       final oldPrice = double.tryParse(oldPriceController.text.trim()) ?? 0;

//       final price = double.tryParse(priceController.text.trim()) ?? 0;

//       final stock = int.tryParse(stockController.text.trim()) ?? 0;

//       final discount = oldPrice > 0
//           ? (((oldPrice - price) / oldPrice) * 100).round()
//           : 0;

//       final productRef = await FirebaseFirestore.instance
//           .collection('products')
//           .add({
//             'name': nameController.text.trim(),
//             'price': price,
//             'oldPrice': oldPrice,
//             'discount': discount,
//             'stock': stock,
//             'category': selectedCategory,
//             'brand': selectedBrand,
//             'description': descriptionController.text.trim(),
//             'images': imageUrls,
//             'rating': 0.0,
//             'reviewsCount': 0,
//             'createdAt': Timestamp.now(),
//           });

//       final usersSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('role', isEqualTo: 'user')
//           .get();

//       final batch = FirebaseFirestore.instance.batch();

//       for (final userDoc in usersSnapshot.docs) {
//         final notificationRef = FirebaseFirestore.instance
//             .collection('notifications')
//             .doc();

//         batch.set(notificationRef, {
//           'title': 'newProductNotification',
//           'body': 'newProductNotificationBody',
//           'type': 'product',
//           'recipient': 'user',
//           'isRead': false,
//           'createdAt': FieldValue.serverTimestamp(),
//           'productName': nameController.text.trim(),
//           'productId': productRef.id,
//           'userId': userDoc.id,
//         });
//       }

//       await batch.commit();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           content: Text(
//             t.productAddedSuccessfully,
//             style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
//           ),
//         ),
//       );

//       // Clear form after successful product creation
//       nameController.clear();
//       oldPriceController.clear();
//       priceController.clear();
//       stockController.clear();
//       descriptionController.clear();

//       setState(() {
//         selectedImages.clear();
//         selectedCategory = null;
//         selectedBrand = null;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Theme.of(context).colorScheme.error,
//           content: Text(
//             t.somethingWentWrong,
//             style: TextStyle(color: Theme.of(context).colorScheme.onError),
//           ),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: showImagePickerDialog,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.shadow.withValues(alpha: 0.15),
//                         blurRadius: 18,
//                         spreadRadius: 2,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: CircleAvatar(
//                     radius: 70,
//                     backgroundColor: Theme.of(
//                       context,
//                     ).colorScheme.surfaceContainerHighest,

//                     backgroundImage: selectedImages.isNotEmpty
//                         ? FileImage(selectedImages.first)
//                         : null,

//                     child: selectedImages.isEmpty
//                         ? Icon(
//                             Icons.add_photo_alternate_rounded,
//                             size: 50,
//                             color: Theme.of(context).colorScheme.primary,
//                           )
//                         : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: nameController,
//                 maxLength: 25,
//                 textCapitalization: TextCapitalization.words,
//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.productName,
//                   icon: Icons.drive_file_rename_outline,
//                 ).copyWith(counterText: "", hintText: t.productNameHint),
//                 validator: (val) {
//                   if (val == null || val.trim().isEmpty) {
//                     return t.enterProductName;
//                   }

//                   final name = val.trim();

//                   if (name.length < 3) {
//                     return t.nameIsTooShort;
//                   }

//                   if (name.length > 25) {
//                     return t.maximum25Characters;
//                   }

//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: priceController,
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 inputFormatters: [LengthLimitingTextInputFormatter(8)],
//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.price,
//                   icon: Icons.attach_money,
//                 ).copyWith(counterText: "", hintText: t.priceHint),
//                 validator: (val) {
//                   if (val == null || val.trim().isEmpty) {
//                     return t.enterPrice;
//                   }

//                   final price = double.tryParse(val);

//                   if (price == null) {
//                     return t.invalidPrice;
//                   }

//                   if (price <= 0) {
//                     return t.priceMustBeGreaterThanZero;
//                   }

//                   if (price > 99999.99) {
//                     return t.maximumPrice;
//                   }

//                   return null;
//                 },
//               ),
//               const SizedBox(height: 15),
//               DropdownButtonFormField<String>(
//                 initialValue: selectedCategory,
//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.category,
//                   icon: Icons.category,
//                 ),
//                 items: categories.map((category) {
//                   return DropdownMenuItem(
//                     value: category,
//                     child: Text(getLocalizedCategory(context, category)),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCategory = value;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return t.pleaseSelectCategory;
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 15),
//               DropdownButtonFormField<String>(
//                 initialValue: selectedBrand,
//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.brand,
//                   icon: Icons.business,
//                 ),
//                 items: brands.map((brand) {
//                   return DropdownMenuItem(value: brand, child: Text(brand));
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedBrand = value;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return t.pleaseSelectBrand;
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 15),

//               TextFormField(
//                 controller: oldPriceController,
//                 keyboardType: TextInputType.number,
//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.oldPrice,
//                   icon: Icons.money_off,
//                 ),
//               ),
//               const SizedBox(height: 15),

//               TextFormField(
//                 controller: stockController,
//                 keyboardType: TextInputType.number,

//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.stock,
//                   icon: Icons.inventory,
//                 ),
//               ),
//               const SizedBox(height: 15),

//               const SizedBox(height: 15),
//               TextFormField(
//                 controller: descriptionController,
//                 maxLines: 3,
//                 maxLength: 80,
//                 textCapitalization: TextCapitalization.sentences,
//                 inputFormatters: [LengthLimitingTextInputFormatter(80)],
//                 decoration: inputDecoration(
//                   context: context,
//                   label: t.description,
//                   icon: Icons.description,
//                 ).copyWith(counterText: "", hintText: t.shortDescriptionHint),
//                 validator: (val) {
//                   if (val == null || val.trim().isEmpty) {
//                     return t.enterDescription;
//                   }

//                   final description = val.trim();

//                   if (description.length < 3) {
//                     return t.descriptionIsTooShort;
//                   }

//                   if (description.length > 80) {
//                     return t.maximum80Characters;
//                   }

//                   return null;
//                 },
//               ),
//               const SizedBox(height: 15),
//               SizedBox(
//                 width: double.infinity,
//                 height: 54,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     gradient: LinearGradient(
//                       colors: [
//                         Theme.of(context).colorScheme.primary,
//                         Theme.of(context).colorScheme.secondary,
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.primary.withValues(alpha: 0.25),
//                         blurRadius: 12,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : addProduct,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                       disabledBackgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: isLoading
//                         ? SizedBox(
//                             width: 23,
//                             height: 23,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2.5,
//                               color: Theme.of(context).colorScheme.onPrimary,
//                             ),
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.add_rounded,
//                                 size: 24,
//                                 color: Theme.of(context).colorScheme.onPrimary,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 t.addProduct,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w700,
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onPrimary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
