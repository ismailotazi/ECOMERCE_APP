import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/User_notifications_page.dart';
import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
import 'package:ecomerce_app/user_dashboard/user_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilPage extends StatefulWidget {
  final bool showArrowBack;

  const UserProfilPage({super.key, this.showArrowBack = true});

  @override
  State<UserProfilPage> createState() => _UserProfilPageState();
}

class _UserProfilPageState extends State<UserProfilPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profile),
        centerTitle: true,
        leading: widget.showArrowBack ? const CustomBackButton() : null,
        actions: [
          if (!isGuest)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("notifications")
                  .where("userId", isEqualTo: user.uid)
                  .where("recipient", isEqualTo: "user")
                  .where("isRead", isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.docs.length ?? 0;

                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserNotificationsPage(),
                      ),
                    );
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? "99+" : unreadCount.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserSettingsPage()),
              );
            },
          ),
        ],
      ),

      body: isGuest
          ? _buildGuestProfile(context, t)
          : _buildUserProfile(context, t, user),
    );
  }

  // ==============================================================
  // GUEST PROFILE
  // ==============================================================

  Widget _buildGuestProfile(BuildContext context, AppLocalizations t) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        final double horizontalPadding = isDesktop ? 32 : 20;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 28 : 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: isDesktop ? 58 : 46,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.person_rounded,
                            size: isDesktop ? 58 : 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Guest",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Sign in to access your profile, orders and notifications.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.login_rounded),
                          label: const Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  t.orderHistory,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      t.noOrderYet,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================================================
  // LOGGED USER PROFILE
  // ==============================================================

  Widget _buildUserProfile(
    BuildContext context,
    AppLocalizations t,
    User user,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        final double horizontalPadding = isDesktop ? 32 : 20;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              children: [
                // ======================================================
                // USER INFO
                // ======================================================
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    final rawData = snapshot.data!.data();

                    final data = rawData is Map<String, dynamic>
                        ? rawData
                        : <String, dynamic>{};

                    final firstName =
                        data["firstName"]?.toString().trim() ?? "";

                    final lastName = data["lastName"]?.toString().trim() ?? "";

                    final fullName = [
                      firstName,
                      lastName,
                    ].where((value) => value.isNotEmpty).join(" ");

                    final city = data["city"]?.toString().trim() ?? "";

                    final country = data["country"]?.toString().trim() ?? "";

                    final location = [
                      city,
                      country,
                    ].where((value) => value.isNotEmpty).join(", ");

                    final photoUrl = data["photoUrl"]?.toString().trim() ?? "";

                    return Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isDesktop ? 28 : 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: isDesktop ? 58 : 46,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl.isEmpty
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: isDesktop ? 58 : 48,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(height: 12),

                            if (fullName.isNotEmpty)
                              Text(
                                fullName,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),

                            if (fullName.isNotEmpty && location.isNotEmpty)
                              const SizedBox(height: 6),

                            if (location.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 5),

                            Text(
                              data["email"]?.toString() ?? user.email ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ======================================================
                // ORDER HISTORY
                // ======================================================
                Text(
                  t.orderHistory,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(user.uid)
                      .collection("orders")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            t.noOrderYet,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }

                    final orders = snapshot.data!.docs;

                    return Column(
                      children: [
                        for (final order in orders)
                          _buildOrderCard(context, order, t),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================================================
  // ORDER CARD
  // ==============================================================

  Widget _buildOrderCard(
    BuildContext context,
    QueryDocumentSnapshot order,
    AppLocalizations t,
  ) {
    final data = order.data() as Map<String, dynamic>;

    final status = data["status"]?.toString().toLowerCase() ?? "pending";

    final total = data["totalPrice"] ?? 0;

    final itemsCount = data["itemsCount"] is num
        ? (data["itemsCount"] as num).toInt()
        : 0;

    DateTime? createdAt;

    if (data["createdAt"] != null && data["createdAt"] is Timestamp) {
      createdAt = (data["createdAt"] as Timestamp).toDate();
    }

    final statusColor = getStatusColor(context, status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: statusColor,
                child: Icon(
                  getStatusIcon(status),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["orderNumber"]?.toString() ?? t.order,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(status),
                            size: 15,
                            color: statusColor,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              getLocalizedStatus(context, status),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 7),

                    if (createdAt != null)
                      Text(
                        "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
                        "${createdAt.hour.toString().padLeft(2, '0')}:"
                        "${createdAt.minute.toString().padLeft(2, '0')}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                    const SizedBox(height: 4),

                    Text(
                      "$itemsCount ${itemsCount == 1 ? t.product : t.products}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$$total",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // STATUS COLOR
  // ==============================================================

  Color getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return AppColors.warning;

      case "processing":
        return AppColors.info;

      case "shipped":
        return AppColors.secondary;

      case "delivered":
        return AppColors.success;

      case "cancelled":
        return AppColors.error;

      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  // ==============================================================
  // STATUS ICON
  // ==============================================================

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Icons.hourglass_top;

      case "processing":
        return Icons.sync;

      case "shipped":
        return Icons.local_shipping;

      case "delivered":
        return Icons.check_circle;

      case "cancelled":
        return Icons.cancel;

      default:
        return Icons.help_outline;
    }
  }

  // ==============================================================
  // LOCALIZED STATUS
  // ==============================================================

  String getLocalizedStatus(BuildContext context, String status) {
    final t = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case "pending":
        return t.pending;

      case "processing":
        return t.processing;

      case "shipped":
        return t.shipped;

      case "delivered":
        return t.delivered;

      case "cancelled":
        return t.cancelled;

      default:
        return status;
    }
  }
}
// ==============================================================
// LOCALIZED STATUS
// ==============================================================

String getLocalizedStatus(BuildContext context, String status) {
  final t = AppLocalizations.of(context)!;

  switch (status.toLowerCase()) {
    case "pending":
      return t.pending;

    case "processing":
      return t.processing;

    case "shipped":
      return t.shipped;

    case "delivered":
      return t.delivered;

    case "cancelled":
      return t.cancelled;

    default:
      return status;
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:ecomerce_app/user_dashboard/User_notifications_page.dart';

// import 'package:ecomerce_app/user_dashboard/order_details_page.dart';

// import 'package:ecomerce_app/user_dashboard/user_settings_page.dart';
// import 'package:flutter/material.dart';

// import 'package:firebase_auth/firebase_auth.dart';

// class UserProfilPage extends StatefulWidget {
//   final bool showArrowBack;
//   const UserProfilPage({super.key, this.showArrowBack = true});

//   @override
//   State<UserProfilPage> createState() => _UserProfilPageState();
// }

// class _UserProfilPageState extends State<UserProfilPage> {
//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t.profile),
//         centerTitle: true,

//         leading: widget.showArrowBack ? const CustomBackButton() : null,

//         actions: [
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection("notifications")
//                 .where(
//                   "userId",
//                   isEqualTo: FirebaseAuth.instance.currentUser!.uid,
//                 )
//                 .where("recipient", isEqualTo: "user")
//                 .where("isRead", isEqualTo: false)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               final unreadCount = snapshot.data?.docs.length ?? 0;

//               return IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const UserNotificationsPage(),
//                     ),
//                   );
//                 },
//                 icon: Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.notifications_outlined),

//                     if (unreadCount > 0)
//                       Positioned(
//                         right: -6,
//                         top: -6,
//                         child: Container(
//                           padding: const EdgeInsets.all(3),
//                           constraints: const BoxConstraints(
//                             minWidth: 18,
//                             minHeight: 18,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).colorScheme.error,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             unreadCount.toString(),
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.onError,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),

//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => UserSettingsPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // ---------------- User Info ----------------
//           FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection("users")
//                 .doc(FirebaseAuth.instance.currentUser!.uid)
//                 .get(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Center(
//                   child: CircularProgressIndicator(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 );
//               }

//               final data = snapshot.data!.data() as Map<String, dynamic>;
//               final firstName = data["firstName"]?.toString().trim() ?? "";
//               final lastName = data["lastName"]?.toString().trim() ?? "";

//               final fullName = [
//                 firstName,
//                 lastName,
//               ].where((value) => value.isNotEmpty).join(" ");

//               final city = data["city"]?.toString().trim() ?? "";
//               final country = data["country"]?.toString().trim() ?? "";

//               final location = [
//                 city,
//                 country,
//               ].where((value) => value.isNotEmpty).join(", ");
//               return Center(
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.primary.withValues(alpha: 0.15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.primary.withValues(alpha: 0.18),
//                             blurRadius: 14,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: CircleAvatar(
//                         radius: 46,
//                         backgroundColor: Theme.of(
//                           context,
//                         ).colorScheme.surfaceContainerHighest,
//                         backgroundImage:
//                             data["photoUrl"] != null &&
//                                 data["photoUrl"].toString().isNotEmpty
//                             ? NetworkImage(data["photoUrl"].toString())
//                             : null,
//                         child:
//                             data["photoUrl"] == null ||
//                                 data["photoUrl"].toString().isEmpty
//                             ? Icon(
//                                 Icons.person_rounded,
//                                 size: 48,
//                                 color: Theme.of(context).colorScheme.primary,
//                               )
//                             : null,
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     if (fullName.isNotEmpty)
//                       Text(
//                         fullName,
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),

//                     if (fullName.isNotEmpty && location.isNotEmpty)
//                       const SizedBox(height: 5),

//                     if (location.isNotEmpty)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             size: 16,
//                             color: Theme.of(context).colorScheme.outline,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             location,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 5),

//                     Text(
//                       data["email"]?.toString() ?? "",
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 30),

//           // ---------------- Order History ----------------
//           Text(t.orderHistory, style: Theme.of(context).textTheme.titleLarge),

//           const SizedBox(height: 10),

//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection("users")
//                 .doc(FirebaseAuth.instance.currentUser!.uid)
//                 .collection("orders")
//                 .orderBy("createdAt", descending: true)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(
//                   child: CircularProgressIndicator(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 );
//               }

//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Center(
//                     child: Text(
//                       t.noOrderYet,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                   ),
//                 );
//               }

//               final orders = snapshot.data!.docs;

//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: orders.length,
//                 itemBuilder: (context, index) {
//                   final order = orders[index];

//                   final data = order.data() as Map<String, dynamic>;

//                   final status =
//                       data["status"]?.toString().toLowerCase() ?? "pending";

//                   final total = data["totalPrice"] ?? 0;
//                   final itemsCount = (data["itemsCount"] ?? 0) as int;
//                   DateTime? createdAt;

//                   if (data["createdAt"] != null) {
//                     createdAt = (data["createdAt"] as Timestamp).toDate();
//                   }

//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 5),
//                     elevation: Theme.of(context).brightness == Brightness.dark
//                         ? 0
//                         : 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         radius: 24,
//                         backgroundColor: getStatusColor(status),
//                         child: Icon(
//                           getStatusIcon(status),
//                           color: Theme.of(context).colorScheme.onPrimary,
//                         ),
//                       ),
//                       title: Text(data["orderNumber"]?.toString() ?? t.order),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(top: 6),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: getStatusColor(
//                                 status,
//                               ).withValues(alpha: 0.15),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   getStatusIcon(status),
//                                   size: 16,
//                                   color: getStatusColor(status),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   getLocalizedStatus(context, status),
//                                   style: TextStyle(
//                                     color: getStatusColor(status),
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 6),

//                           if (createdAt != null)
//                             Text(
//                               "${createdAt.day}/${createdAt.month}/${createdAt.year} • "
//                               "${createdAt.hour.toString().padLeft(2, '0')}:"
//                               "${createdAt.minute.toString().padLeft(2, '0')}",
//                               style: Theme.of(context).textTheme.bodySmall,
//                             ),
//                           const SizedBox(height: 4),

//                           Text(
//                             "$itemsCount ${itemsCount == 1 ? t.product : t.products}",
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                       trailing: Text(
//                         "\$$total",
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(
//                               color: AppColors.success,
//                               fontWeight: FontWeight.bold,
//                             ),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => OrderDetailsPage(orderId: order.id),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           ),

//           const SizedBox(height: 30),

//           // ---------------- Account Settings ----------------
//         ],
//       ),
//     );
//   }

//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//         return Colors.orange;

//       case "processing":
//         return Colors.blue;

//       case "shipped":
//         return Colors.purple;

//       case "delivered":
//         return Colors.green;

//       case "cancelled":
//         return Colors.red;

//       default:
//         return Colors.grey;
//     }
//   }

//   IconData getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case "pending":
//         return Icons.hourglass_top;

//       case "processing":
//         return Icons.sync;

//       case "shipped":
//         return Icons.local_shipping;

//       case "delivered":
//         return Icons.check_circle;

//       case "cancelled":
//         return Icons.cancel;

//       default:
//         return Icons.help_outline;
//     }
//   }

//   String getLocalizedStatus(BuildContext context, String status) {
//     final t = AppLocalizations.of(context)!;

//     switch (status.toLowerCase()) {
//       case "pending":
//         return t.pending;

//       case "processing":
//         return t.processing;

//       case "shipped":
//         return t.shipped;

//       case "delivered":
//         return t.delivered;

//       case "cancelled":
//         return t.cancelled;

//       default:
//         return status;
//     }
//   }
// }
