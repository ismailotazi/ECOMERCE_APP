import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
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
  bool isLoading = false;
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.writeReview),
        centerTitle: true,
        leading: const CustomBackButton(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isDesktop = width >= 1100;
          final bool isTablet = width >= 700 && width < 1100;

          final double horizontalPadding = isDesktop
              ? 32
              : isTablet
              ? 24
              : 20;

          final double maxContentWidth = isDesktop
              ? 700
              : isTablet
              ? 650
              : double.infinity;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                children: [
                  Text(
                    t.rateThisProduct,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: isDesktop
                            ? 46
                            : isTablet
                            ? 44
                            : 42,
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
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: commentController,
                    maxLines: 6,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: t.tellUsAboutThisProduct,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final user = FirebaseAuth.instance.currentUser;

                              if (user == null) {
                                if (!context.mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );

                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });

                              try {
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

                                final reviewsSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection("products")
                                    .doc(widget.productId)
                                    .collection("reviews")
                                    .get();

                                double totalRating = 0;

                                for (var doc in reviewsSnapshot.docs) {
                                  totalRating += (doc["rating"] as num)
                                      .toDouble();
                                }

                                final averageRating =
                                    reviewsSnapshot.docs.isEmpty
                                    ? 0
                                    : totalRating / reviewsSnapshot.docs.length;

                                await FirebaseFirestore.instance
                                    .collection("products")
                                    .doc(widget.productId)
                                    .update({
                                      "rating": averageRating,
                                      "reviewsCount":
                                          reviewsSnapshot.docs.length,
                                    });

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t.reviewSubmittedSuccessfully,
                                    ),
                                  ),
                                );

                                Navigator.pop(context);
                              } catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t.somethingWentWrong)),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                      icon: const Icon(Icons.send),
                      label: isLoading
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(t.submitReview),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class WriteReviewPage extends StatefulWidget {
//   final String productId;
//   const WriteReviewPage({super.key, required this.productId});

//   @override
//   State<WriteReviewPage> createState() => _WriteReviewPageState();
// }

// class _WriteReviewPageState extends State<WriteReviewPage> {
//   double rating = 5;
//   bool isLoading = false;
//   final TextEditingController commentController = TextEditingController();
//   @override
//   void dispose() {
//     commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.writeReview),
//         centerTitle: true,
//         leading: const CustomBackButton(),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           Text(
//             t.rateThisProduct,
//             style: Theme.of(
//               context,
//             ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 20),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(5, (index) {
//               return IconButton(
//                 iconSize: 42,
//                 onPressed: () {
//                   setState(() {
//                     rating = index + 1;
//                   });
//                 },
//                 icon: Icon(
//                   index < rating ? Icons.star : Icons.star_border,
//                   color: Colors.amber,
//                 ),
//               );
//             }),
//           ),

//           Center(
//             child: Text(
//               rating.toStringAsFixed(0),
//               style: Theme.of(
//                 context,
//               ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
//             ),
//           ),

//           const SizedBox(height: 30),

//           TextField(
//             controller: commentController,
//             maxLines: 6,
//             style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//             decoration: InputDecoration(
//               hintText: t.tellUsAboutThisProduct,
//               hintStyle: TextStyle(
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//               filled: true,
//               fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,

//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide.none,
//               ),

//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).colorScheme.primary,
//                   width: 2,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 30),

//           SizedBox(
//             height: 55,
//             child: ElevatedButton.icon(
//               onPressed: isLoading
//                   ? null
//                   : () async {
//                       setState(() {
//                         isLoading = true;
//                       });

//                       try {
//                         final user = FirebaseAuth.instance.currentUser!;

//                         final userDoc = await FirebaseFirestore.instance
//                             .collection("users")
//                             .doc(user.uid)
//                             .get();

//                         final userData = userDoc.data()!;

//                         await FirebaseFirestore.instance
//                             .collection("products")
//                             .doc(widget.productId)
//                             .collection("reviews")
//                             .add({
//                               "userId": user.uid,
//                               "userName":
//                                   "${userData["firstName"]} ${userData["lastName"]}",
//                               "photoUrl": userData["photoUrl"] ?? "",
//                               "rating": rating,
//                               "comment": commentController.text.trim(),
//                               "createdAt": FieldValue.serverTimestamp(),
//                             });

//                         final reviewsSnapshot = await FirebaseFirestore.instance
//                             .collection("products")
//                             .doc(widget.productId)
//                             .collection("reviews")
//                             .get();

//                         double totalRating = 0;

//                         for (var doc in reviewsSnapshot.docs) {
//                           totalRating += (doc["rating"] as num).toDouble();
//                         }

//                         final averageRating = reviewsSnapshot.docs.isEmpty
//                             ? 0
//                             : totalRating / reviewsSnapshot.docs.length;

//                         await FirebaseFirestore.instance
//                             .collection("products")
//                             .doc(widget.productId)
//                             .update({
//                               "rating": averageRating,
//                               "reviewsCount": reviewsSnapshot.docs.length,
//                             });

//                         if (!context.mounted) return;

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(t.reviewSubmittedSuccessfully),
//                           ),
//                         );

//                         Navigator.pop(context);
//                       } catch (e) {
//                         if (!context.mounted) return;

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(t.somethingWentWrong)),
//                         );
//                       } finally {
//                         if (mounted) {
//                           setState(() {
//                             isLoading = false;
//                           });
//                         }
//                       }
//                     },
//               icon: const Icon(Icons.send),
//               label: isLoading
//                   ? SizedBox(
//                       height: 22,
//                       width: 22,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Theme.of(context).colorScheme.onPrimary,
//                       ),
//                     )
//                   : Text(t.submitReview),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
