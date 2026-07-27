import 'dart:io';
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
    "Electrical",
    "Shoes",
    "Clothes",
    "Glasses",
    "Parfum",
    "Others",
  ];
  final List<String> brands = [
    "Nike",
    "Adidas",
    "Apple",
    "Samsung",
    "Puma",
    "Zara",
    "Other",
  ];
  List<File> selectedImages = [];
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future pickFromGallery() async {
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images.map((e) => File(e.path)).toList();
      });
    }
  }

  Future pickFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => selectedImages.add(File(image.path)));
  }

  void showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, size: 40, color: Colors.orange),
                  onPressed: () {
                    pickFromGallery();
                    Navigator.pop(context);
                  },
                ),
                const Text("Gallery"),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    pickFromCamera();
                    Navigator.pop(context);
                  },
                ),
                const Text("Camera"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> urls = [];

    for (final image in images) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref("products/$fileName");

      final snapshot = await ref.putFile(image);

      final url = await snapshot.ref.getDownloadURL();

      urls.add(url);
    }

    return urls;
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final imageUrls = await uploadImages(selectedImages);
      final oldPrice = double.tryParse(oldPriceController.text.trim()) ?? 0;

      final price = double.tryParse(priceController.text.trim()) ?? 0;

      final discount = oldPrice > 0
          ? (((oldPrice - price) / oldPrice) * 100).round()
          : 0;
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),

        'price': price,

        'oldPrice': oldPrice,

        'discount': discount,
        'stock': int.tryParse(stockController.text.trim()) ?? 0,

        'category': selectedCategory,
        'brand': selectedBrand,
        'description': descriptionController.text.trim(),

        'image': imageUrls.first, // مؤقتاً

        'images': imageUrls, // الجديد

        'rating': 0.0,

        'reviewsCount': 0,

        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );

      // Reset form
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      setState(() {
        selectedCategory = null;
        selectedBrand = null;
        selectedImages.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: showImagePickerDialog,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: selectedImages.isNotEmpty
                        ? FileImage(selectedImages.first)
                        : null,

                    child: selectedImages.isEmpty
                        ? const Icon(Icons.add, size: 50, color: Colors.orange)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: nameController,
                maxLength: 25,
                textCapitalization: TextCapitalization.words,
                decoration: buildInputDecoration(
                  "Product Name",
                  Icons.drive_file_rename_outline,
                ).copyWith(counterText: "", hintText: "e.g. Nike Air Max"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Enter product name";
                  }

                  final name = val.trim();

                  if (name.length < 3) {
                    return "Name is too short";
                  }

                  if (name.length > 25) {
                    return "Maximum 25 characters";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(8)],
                decoration: buildInputDecoration(
                  "Price",
                  Icons.attach_money,
                ).copyWith(counterText: "", hintText: "e.g. 99.99"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Enter price";
                  }

                  final price = double.tryParse(val);

                  if (price == null) {
                    return "Invalid price";
                  }

                  if (price <= 0) {
                    return "Price must be greater than 0";
                  }

                  if (price > 99999.99) {
                    return "Maximum price is 99999.99";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: buildInputDecoration("Category", Icons.category),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a category";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedBrand,
                decoration: buildInputDecoration("Brand", Icons.business),
                items: brands.map((brand) {
                  return DropdownMenuItem(value: brand, child: Text(brand));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select a brand";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: oldPriceController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration("Old Price", Icons.money_off),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration("Stock", Icons.inventory),
              ),
              const SizedBox(height: 15),

              const SizedBox(height: 15),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(80)],
                decoration: buildInputDecoration(
                  "Description",
                  Icons.description,
                ).copyWith(counterText: "", hintText: "Short description..."),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Enter description";
                  }

                  final description = val.trim();

                  if (description.length < 3) {
                    return "Description is too short";
                  }

                  if (description.length > 80) {
                    return "Maximum 80 characters";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Product",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
