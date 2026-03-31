import 'dart:io';
import 'package:flutter/material.dart';
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

  String? selectedCategory;
  final List<String> categories = [
    "Electrical",
    "Shoes",
    "Clothes",
    "Glasses",
    "Parfum",
  ];

  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future pickFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Future pickFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => selectedImage = File(image.path));
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

  Future<String?> uploadImage(File image) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('products/$fileName');
      TaskSnapshot snapshot = await ref.putFile(image);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageUrl = await uploadImage(selectedImage!);
      if (imageUrl == null) throw "Image upload failed";

      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'image': imageUrl,
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
        selectedImage = null;
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,
                    child: selectedImage == null
                        ? const Icon(Icons.add, size: 50, color: Colors.orange)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: nameController,
                decoration: buildInputDecoration(
                  "Product Name",
                  Icons.drive_file_rename_outline,
                ),
                validator: (val) => val!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration("Price", Icons.attach_money),
                validator: (val) => val!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: buildInputDecoration("Category", Icons.category),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                validator: (val) => val == null ? "Select category" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: buildInputDecoration(
                  "Description",
                  Icons.description,
                ),
                validator: (val) => val!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 30),
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
