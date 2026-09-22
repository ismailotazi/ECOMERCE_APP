import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  const AdminOrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  String selectedStatus = "pending";

  final List<Map<String, dynamic>> statuses = [
    {"value": "pending", "icon": Icons.hourglass_top, "color": Colors.orange},
    {"value": "processing", "icon": Icons.sync, "color": Colors.blue},
    {"value": "shipped", "icon": Icons.local_shipping, "color": Colors.purple},
    {"value": "delivered", "icon": Icons.check_circle, "color": Colors.green},
    {"value": "cancelled", "icon": Icons.cancel, "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;

    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 600 && screenWidth < 1100;

    final horizontalPadding = isDesktop
        ? 32.0
        : isTablet
        ? 24.0
        : 16.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.orderDetails),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text(t.somethingWentWrong));
            }

            final rawData = snapshot.data!.data();

            if (rawData == null) {
              return Center(child: Text(t.somethingWentWrong));
            }

            final data = rawData as Map<String, dynamic>;

            if (selectedStatus == "pending") {
              selectedStatus = data["status"] ?? "pending";
            }

            final orderNumber = data["orderNumber"] ?? "";
            final userName = data["userName"] ?? "";
            final email = data["email"] ?? "";
            final total = data["totalPrice"] ?? 0;
            final userId = data["userId"] ?? "";

            final paymentMethod = data["paymentMethod"] ?? "";
            final paymentProofUrl = data["paymentProofUrl"];

            final createdAt = (data["createdAt"] as Timestamp).toDate();

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isDesktop ? 28 : 20,
                    horizontalPadding,
                    50,
                  ),
                  children: [
                    // ---------------------------------------------------------
                    // ORDER HEADER
                    // ---------------------------------------------------------
                    _buildOrderHeader(
                      context: context,
                      orderNumber: orderNumber,
                      createdAt: createdAt,
                      isDesktop: isDesktop,
                    ),

                    SizedBox(height: isDesktop ? 28 : 20),

                    // ---------------------------------------------------------
                    // DESKTOP CUSTOMER + TOTAL
                    // ---------------------------------------------------------
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildCustomerSection(
                              context: context,
                              userName: userName,
                              email: email,
                              isDesktop: true,
                              t: t,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTotalCard(
                              context: context,
                              total: total,
                              t: t,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildCustomerSection(
                        context: context,
                        userName: userName,
                        email: email,
                        isDesktop: false,
                        t: t,
                      ),
                      const SizedBox(height: 20),
                    ],

                    SizedBox(height: isDesktop ? 28 : 20),

                    // ---------------------------------------------------------
                    // PRODUCTS
                    // ---------------------------------------------------------
                    Text(
                      t.products,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("orders")
                          .doc(widget.orderId)
                          .collection("items")
                          .get(),
                      builder: (context, itemsSnapshot) {
                        if (!itemsSnapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }

                        final items = itemsSnapshot.data!.docs;

                        return _buildProductsList(
                          context: context,
                          items: items,
                          t: t,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ---------------------------------------------------------
                    // MOBILE / TABLET TOTAL
                    // ---------------------------------------------------------
                    if (!isDesktop)
                      _buildTotalCard(context: context, total: total, t: t),

                    // ---------------------------------------------------------
                    // PAYMENT INFORMATION
                    // ---------------------------------------------------------
                    if (paymentMethod == "Bank Transfer") ...[
                      SizedBox(height: isDesktop ? 28 : 20),

                      Text(
                        t.paymentInformation,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildPaymentInformation(
                        context: context,
                        paymentProofUrl: paymentProofUrl,
                        t: t,
                        isDesktop: isDesktop,
                      ),
                    ],

                    SizedBox(height: isDesktop ? 28 : 20),

                    // ---------------------------------------------------------
                    // STATUS
                    // ---------------------------------------------------------
                    Text(
                      t.orderStatus,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildStatusSection(
                      context: context,
                      t: t,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------
                    // SAVE
                    // ---------------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: Text(t.saveChanges),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 17 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final orderRef = FirebaseFirestore.instance
                              .collection("orders")
                              .doc(widget.orderId);

                          final orderSnapshot = await orderRef.get();

                          if (!orderSnapshot.exists) return;

                          final oldStatus =
                              orderSnapshot.data()?["status"]?.toString() ?? "";

                          if (oldStatus == selectedStatus) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t.orderUpdatedSuccessfully),
                              ),
                            );

                            return;
                          }

                          await orderRef.update({"status": selectedStatus});

                          final query = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId)
                              .collection("orders")
                              .where("orderNumber", isEqualTo: orderNumber)
                              .limit(1)
                              .get();

                          if (query.docs.isNotEmpty) {
                            await query.docs.first.reference.update({
                              "status": selectedStatus,
                            });
                          }

                          await FirebaseFirestore.instance
                              .collection("notifications")
                              .add({
                                "title": "orderUpdatedNotification",
                                "body": "orderUpdatedNotificationBody",
                                "type": "order_status",
                                "recipient": "user",
                                "isRead": false,
                                "createdAt": FieldValue.serverTimestamp(),
                                "orderId": widget.orderId,
                                "userId": userId,
                                "orderNumber": orderNumber,
                                "status": selectedStatus,
                              });

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.orderUpdatedSuccessfully)),
                          );

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // ORDER HEADER
  // ===========================================================================

  Widget _buildOrderHeader({
    required BuildContext context,
    required dynamic orderNumber,
    required DateTime createdAt,
    required bool isDesktop,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 22 : 18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 58 : 52,
            height: isDesktop ? 58 : 52,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: colorScheme.primary,
              size: isDesktop ? 29 : 26,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderNumber.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                  "${createdAt.hour.toString().padLeft(2, '0')}:"
                  "${createdAt.minute.toString().padLeft(2, '0')}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CUSTOMER
  // ===========================================================================

  Widget _buildCustomerSection({
    required BuildContext context,
    required dynamic userName,
    required dynamic email,
    required bool isDesktop,
    required AppLocalizations t,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.customer,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 18 : 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isDesktop ? 28 : 25,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                    size: isDesktop ? 28 : 25,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PRODUCTS
  // ===========================================================================

  Widget _buildProductsList({
    required BuildContext context,
    required List<QueryDocumentSnapshot> items,
    required AppLocalizations t,
    required bool isDesktop,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: items.map((doc) {
        final item = doc.data() as Map<String, dynamic>;

        final imageSize = isDesktop
            ? 76.0
            : isTablet
            ? 68.0
            : 60.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item["image"],
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        width: imageSize,
                        height: imageSize,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${t.qty}: ${item["quantity"]}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  "\$${item["price"]}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // TOTAL
  // ===========================================================================

  Widget _buildTotalCard({
    required BuildContext context,
    required dynamic total,
    required AppLocalizations t,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: const Icon(Icons.payments_rounded, color: AppColors.success),
        title: Text(t.orderTotal),
        trailing: Text(
          "\$$total",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PAYMENT INFORMATION
  // ===========================================================================

  Widget _buildPaymentInformation({
    required BuildContext context,
    required dynamic paymentProofUrl,
    required AppLocalizations t,
    required bool isDesktop,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasProof =
        paymentProofUrl != null && paymentProofUrl.toString().isNotEmpty;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.bankTransfer,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        hasProof
                            ? t.paymentProofUploaded
                            : t.paymentProofNotUploaded,
                        style: TextStyle(
                          color: hasProof ? Colors.green : colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  hasProof
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: hasProof ? Colors.green : Colors.orange,
                ),
              ],
            ),

            if (hasProof) ...[
              const SizedBox(height: 18),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 700 : double.infinity,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      paymentProofUrl.toString(),
                      width: double.infinity,
                      height: isDesktop ? 360 : 220,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return SizedBox(
                          height: isDesktop ? 360 : 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) {
                        return Container(
                          height: isDesktop ? 360 : 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined, size: 45),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return Dialog(
                          insetPadding: EdgeInsets.all(isDesktop ? 40 : 16),
                          child: InteractiveViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                paymentProofUrl.toString(),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.zoom_in_rounded),
                  label: Text(t.viewPaymentProof),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _buildStatusSection({
    required BuildContext context,
    required AppLocalizations t,
    required bool isDesktop,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 14),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status["value"],
                          child: Row(
                            children: [
                              Icon(
                                status["icon"],
                                color: status["color"],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(switch (status["value"]) {
                                "pending" => t.pending,
                                "processing" => t.processing,
                                "shipped" => t.shipped,
                                "delivered" => t.delivered,
                                "cancelled" => t.cancelled,
                                _ => status["value"].toString(),
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              )
            : DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status["value"],
                    child: Row(
                      children: [
                        Icon(status["icon"], color: status["color"], size: 20),
                        const SizedBox(width: 10),
                        Text(switch (status["value"]) {
                          "pending" => t.pending,
                          "processing" => t.processing,
                          "shipped" => t.shipped,
                          "delivered" => t.delivered,
                          "cancelled" => t.cancelled,
                          _ => status["value"].toString(),
                        }),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class AdminOrderDetailsPage extends StatefulWidget {
//   const AdminOrderDetailsPage({super.key, required this.orderId});

//   final String orderId;

//   @override
//   State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
// }

// class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
//   String selectedStatus = "pending";
//   final List<Map<String, dynamic>> statuses = [
//     {"value": "pending", "icon": Icons.hourglass_top, "color": Colors.orange},
//     {"value": "processing", "icon": Icons.sync, "color": Colors.blue},
//     {"value": "shipped", "icon": Icons.local_shipping, "color": Colors.purple},
//     {"value": "delivered", "icon": Icons.check_circle, "color": Colors.green},
//     {"value": "cancelled", "icon": Icons.cancel, "color": Colors.red},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(t.orderDetails),
//         leading: const CustomBackButton(),
//       ),

//       body: SafeArea(
//         child: FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance
//               .collection("orders")
//               .doc(widget.orderId)
//               .get(),

//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return Center(child: Text(t.somethingWentWrong));
//             }

//             final rawData = snapshot.data!.data();

//             if (rawData == null) {
//               return Center(child: Text(t.somethingWentWrong));
//             }

//             final data = rawData as Map<String, dynamic>;

//             if (selectedStatus == "pending") {
//               selectedStatus = data["status"] ?? "pending";
//             }

//             final orderNumber = data["orderNumber"] ?? "";
//             final userName = data["userName"] ?? "";
//             final email = data["email"] ?? "";
//             final total = data["totalPrice"] ?? 0;
//             final userId = data["userId"] ?? "";

//             final paymentMethod = data["paymentMethod"] ?? "";
//             final paymentProofUrl = data["paymentProofUrl"];

//             final createdAt = (data["createdAt"] as Timestamp).toDate();
//             return ListView(
//               padding: const EdgeInsets.all(20),

//               children: [
//                 Text(
//                   orderNumber,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
//                   "${createdAt.hour.toString().padLeft(2, '0')}:"
//                   "${createdAt.minute.toString().padLeft(2, '0')}",
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 Text(
//                   t.customer,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Theme.of(
//                       context,
//                     ).colorScheme.surfaceContainerHighest,
//                     child: Icon(
//                       Icons.person,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),

//                   title: Text(userName),

//                   subtitle: Text(
//                     email,
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//                 Text(
//                   t.products,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 FutureBuilder<QuerySnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection("orders")
//                       .doc(widget.orderId)
//                       .collection("items")
//                       .get(),

//                   builder: (context, itemsSnapshot) {
//                     if (!itemsSnapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       );
//                     }

//                     final items = itemsSnapshot.data!.docs;

//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: items.length,
//                       itemBuilder: (context, index) {
//                         final item =
//                             items[index].data() as Map<String, dynamic>;

//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 10),

//                           child: ListTile(
//                             leading: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 item["image"],
//                                 width: 60,
//                                 height: 60,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, _, _) {
//                                   return Container(
//                                     width: 60,
//                                     height: 60,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.surfaceContainerHighest,
//                                     child: Icon(
//                                       Icons.image,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onSurfaceVariant,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),

//                             title: Text(item["name"]),

//                             subtitle: Text(
//                               "${t.qty}: ${item["quantity"]}",
//                               style: TextStyle(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onSurfaceVariant,
//                               ),
//                             ),

//                             trailing: Text(
//                               "\$${item["price"]}",
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.success,
//                                   ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 5),

//                 Card(
//                   child: ListTile(
//                     leading: const Icon(
//                       Icons.payments,
//                       color: AppColors.success,
//                     ),

//                     title: Text(t.orderTotal),

//                     trailing: Text(
//                       "\$$total",
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.success,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (paymentMethod == "Bank Transfer") ...[
//                   const SizedBox(height: 20),

//                   Text(
//                     t.paymentInformation,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor: Theme.of(
//                                   context,
//                                 ).colorScheme.primaryContainer,
//                                 child: Icon(
//                                   Icons.account_balance_rounded,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),

//                               const SizedBox(width: 12),

//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       t.bankTransfer,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),

//                                     const SizedBox(height: 4),

//                                     Text(
//                                       paymentProofUrl != null &&
//                                               paymentProofUrl
//                                                   .toString()
//                                                   .isNotEmpty
//                                           ? t.paymentProofUploaded
//                                           : t.paymentProofNotUploaded,
//                                       style: TextStyle(
//                                         color:
//                                             paymentProofUrl != null &&
//                                                 paymentProofUrl
//                                                     .toString()
//                                                     .isNotEmpty
//                                             ? Colors.green
//                                             : Theme.of(
//                                                 context,
//                                               ).colorScheme.error,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),

//                               Icon(
//                                 paymentProofUrl != null &&
//                                         paymentProofUrl.toString().isNotEmpty
//                                     ? Icons.check_circle_rounded
//                                     : Icons.warning_amber_rounded,
//                                 color:
//                                     paymentProofUrl != null &&
//                                         paymentProofUrl.toString().isNotEmpty
//                                     ? Colors.green
//                                     : Colors.orange,
//                               ),
//                             ],
//                           ),

//                           if (paymentProofUrl != null &&
//                               paymentProofUrl.toString().isNotEmpty) ...[
//                             const SizedBox(height: 16),

//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(14),
//                               child: Image.network(
//                                 paymentProofUrl.toString(),
//                                 width: double.infinity,
//                                 height: 220,
//                                 fit: BoxFit.cover,
//                                 loadingBuilder: (context, child, progress) {
//                                   if (progress == null) return child;

//                                   return SizedBox(
//                                     height: 220,
//                                     child: Center(
//                                       child: CircularProgressIndicator(
//                                         color: Theme.of(
//                                           context,
//                                         ).colorScheme.primary,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 errorBuilder: (_, _, _) {
//                                   return Container(
//                                     height: 220,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.surfaceContainerHighest,
//                                       borderRadius: BorderRadius.circular(14),
//                                     ),
//                                     child: const Center(
//                                       child: Icon(
//                                         Icons.broken_image_outlined,
//                                         size: 45,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),

//                             const SizedBox(height: 12),

//                             SizedBox(
//                               width: double.infinity,
//                               child: OutlinedButton.icon(
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (_) {
//                                       return Dialog(
//                                         insetPadding: const EdgeInsets.all(16),
//                                         child: InteractiveViewer(
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                               16,
//                                             ),
//                                             child: Image.network(
//                                               paymentProofUrl.toString(),
//                                               fit: BoxFit.contain,
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 },
//                                 icon: const Icon(Icons.zoom_in_rounded),
//                                 label: Text(t.viewPaymentProof),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 20),
//                 Text(
//                   t.orderStatus,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 DropdownButtonFormField<String>(
//                   initialValue: selectedStatus,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Theme.of(context).colorScheme.outline,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(
//                         color: Theme.of(context).colorScheme.primary,
//                         width: 2,
//                       ),
//                     ),
//                   ),

//                   items: statuses.map((status) {
//                     return DropdownMenuItem<String>(
//                       value: status["value"],
//                       child: Row(
//                         children: [
//                           Icon(
//                             status["icon"],
//                             color: status["color"],
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(switch (status["value"]) {
//                             "pending" => t.pending,
//                             "processing" => t.processing,
//                             "shipped" => t.shipped,
//                             "delivered" => t.delivered,
//                             "cancelled" => t.cancelled,
//                             _ => status["value"].toString(),
//                           }),
//                         ],
//                       ),
//                     );
//                   }).toList(),

//                   onChanged: (value) {
//                     setState(() {
//                       selectedStatus = value!;
//                     });
//                   },
//                 ),

//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,

//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.save),

//                     label: Text(t.saveChanges),

//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),

//                     onPressed: () async {
//                       final orderRef = FirebaseFirestore.instance
//                           .collection("orders")
//                           .doc(widget.orderId);

//                       final orderSnapshot = await orderRef.get();

//                       if (!orderSnapshot.exists) return;

//                       final oldStatus =
//                           orderSnapshot.data()?["status"]?.toString() ?? "";

//                       if (oldStatus == selectedStatus) {
//                         if (!context.mounted) return;

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(t.orderUpdatedSuccessfully)),
//                         );

//                         return;
//                       }

//                       await orderRef.update({"status": selectedStatus});

//                       final query = await FirebaseFirestore.instance
//                           .collection("users")
//                           .doc(userId)
//                           .collection("orders")
//                           .where("orderNumber", isEqualTo: orderNumber)
//                           .limit(1)
//                           .get();

//                       if (query.docs.isNotEmpty) {
//                         await query.docs.first.reference.update({
//                           "status": selectedStatus,
//                         });
//                       }

//                       await FirebaseFirestore.instance
//                           .collection("notifications")
//                           .add({
//                             "title": "orderUpdatedNotification",
//                             "body": "orderUpdatedNotificationBody",
//                             "type": "order_status",
//                             "recipient": "user",
//                             "isRead": false,
//                             "createdAt": FieldValue.serverTimestamp(),
//                             "orderId": widget.orderId,
//                             "userId": userId,
//                             "orderNumber": orderNumber,
//                             "status": selectedStatus,
//                           });
//                       if (!context.mounted) return;

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(t.orderUpdatedSuccessfully)),
//                       );

//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
