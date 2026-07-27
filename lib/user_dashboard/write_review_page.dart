import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WriteReviewPage extends StatefulWidget {
  final String productId;
  const WriteReviewPage({super.key, required this.productId});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  double rating = 5;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write Review"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Rate this product",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                iconSize: 42,
                onPressed: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),

          Center(
            child: Text(
              rating.toStringAsFixed(0),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 30),

          TextField(
            controller: commentController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Tell us about this product...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser!;

                final userDoc = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .get();

                final userData = userDoc.data()!;

                await FirebaseFirestore.instance
                    .collection("products")
                    .doc(widget.productId)
                    .collection("reviews")
                    .add({
                      "userId": user.uid,
                      "userName":
                          "${userData["firstName"]} ${userData["lastName"]}",
                      "photoUrl": userData["photoUrl"] ?? "",
                      "rating": rating,
                      "comment": commentController.text.trim(),
                      "createdAt": FieldValue.serverTimestamp(),
                    });

                final reviewsSnapshot = await FirebaseFirestore.instance
                    .collection("products")
                    .doc(widget.productId)
                    .collection("reviews")
                    .get();

                double totalRating = 0;

                for (var doc in reviewsSnapshot.docs) {
                  totalRating += (doc["rating"] as num).toDouble();
                }

                final averageRating = reviewsSnapshot.docs.isEmpty
                    ? 0
                    : totalRating / reviewsSnapshot.docs.length;

                await FirebaseFirestore.instance
                    .collection("products")
                    .doc(widget.productId)
                    .update({
                      "rating": averageRating,
                      "reviewsCount": reviewsSnapshot.docs.length,
                    });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Review submitted successfully"),
                  ),
                );

                Navigator.pop(context);
              },
              icon: const Icon(Icons.send),
              label: const Text("Submit Review"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
