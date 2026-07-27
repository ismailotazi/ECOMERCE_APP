import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    "Electrical",
    "Parfum",
    "Clothes",
    "Shoes",
    "Glasses",
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
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one image")),
      );
      return;
    }

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

    await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .update({
          "name": nameController.text.trim(),
          "description": descriptionController.text.trim(),
          "price": double.tryParse(priceController.text) ?? 0,
          "oldPrice": double.tryParse(oldPriceController.text) ?? 0,
          "stock": int.tryParse(stockController.text) ?? 0,
          "category": selectedCategory,
          "brand": selectedBrand,
          "image": imageUrls.first,
          "images": imageUrls,
        });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product updated successfully")),
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Images"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.photo, size: 40),
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
                leading: const Icon(Icons.photo),
                title: const Text("Replace Image"),
                onTap: () {
                  Navigator.pop(context);
                  pickReplacementImage(index);
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.camera_alt),
              //   title: const Text("Camera"),
              //   onTap: () {
              //     Navigator.pop(context);
              //     pickReplacementFromCamera(index);
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Delete Image",
                  style: TextStyle(color: Colors.red),
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

  // Future<void> pickReplacementFromCamera(int index) async {
  //   final picked = await picker.pickImage(source: ImageSource.camera);

  //   if (picked == null) return;

  //   setState(() {
  //     images[index] = EditableImage(file: File(picked.path));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      height: 110,
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
                                width: 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.orange,
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
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        image.url!,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: nameController,
                      maxLength: 25,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          buildInputDecoration(
                            "Product Name",
                            Icons.drive_file_rename_outline,
                          ).copyWith(
                            counterText: "",
                            hintText: "e.g. Nike Air Max",
                          ),
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

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:
                          buildInputDecoration(
                            "Description",
                            Icons.description,
                          ).copyWith(
                            counterText: "",
                            hintText: "Short description...",
                          ),
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

                    TextFormField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      maxLength: 8,
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

                    TextFormField(
                      controller: oldPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      maxLength: 8,
                      decoration: buildInputDecoration(
                        "Old Price",
                        Icons.money_off,
                      ).copyWith(counterText: "", hintText: "e.g. 129.99"),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return null; // اختياري
                        }

                        final oldPrice = double.tryParse(val);

                        if (oldPrice == null) {
                          return "Invalid old price";
                        }

                        if (oldPrice <= 0) {
                          return "Old price must be greater than 0";
                        }

                        if (oldPrice > 99999.99) {
                          return "Maximum price is 99999.99";
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
                      decoration: buildInputDecoration(
                        "Stock",
                        Icons.inventory,
                      ).copyWith(counterText: "", hintText: "e.g. 25"),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Enter stock quantity";
                        }

                        final stock = int.tryParse(val);

                        if (stock == null) {
                          return "Invalid stock";
                        }

                        if (stock < 0) {
                          return "Stock cannot be negative";
                        }

                        if (stock > 999999) {
                          return "Maximum stock is 999999";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: buildInputDecoration(
                        "Category",
                        Icons.category,
                      ),
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
                          return "Please select a brand";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await updateProduct();
                          }
                        },
                        child: const Text(
                          "Update Product",
                          style: TextStyle(fontSize: 18),
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
