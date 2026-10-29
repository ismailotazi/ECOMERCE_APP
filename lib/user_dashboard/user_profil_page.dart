import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:ecomerce_app/user_dashboard/user_notifications_page.dart';
import 'package:ecomerce_app/user_dashboard/order_details_page.dart';
import 'package:ecomerce_app/user_dashboard/user_settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProfilPage extends StatefulWidget {
  final bool showArrowBack;
  final String? storeId;

  const UserProfilPage({super.key, this.showArrowBack = true, this.storeId});

  @override
  State<UserProfilPage> createState() => _UserProfilPageState();
}

class _UserProfilPageState extends State<UserProfilPage> {
  Widget _buildStoreLogo(BuildContext context, bool isDesktop) {
    final storeId = widget.storeId?.trim();

    if (storeId == null || storeId.isEmpty) {
      return _storeLogoPlaceholder(context, isDesktop);
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get(),
      builder: (context, snapshot) {
        final logoUrl =
            snapshot.data?.data()?['logoUrl']?.toString().trim() ?? '';

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _storeLogoPlaceholder(context, isDesktop, loading: true);
        }

        if (logoUrl.isEmpty || snapshot.hasError) {
          return _storeLogoPlaceholder(context, isDesktop);
        }

        return Container(
          width: isDesktop ? 124 : 100,
          height: isDesktop ? 124 : 100,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: ClipOval(
            child: Image.network(
              logoUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _storeLogoPlaceholder(context, isDesktop);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _storeLogoPlaceholder(
    BuildContext context,
    bool isDesktop, {
    bool loading = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: isDesktop ? 124 : 100,
      height: isDesktop ? 124 : 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: loading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Icon(
              Icons.storefront_rounded,
              size: isDesktop ? 58 : 48,
              color: colorScheme.onPrimaryContainer,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar:
          kIsWeb &&
              MediaQuery.sizeOf(context).width >= 900 &&
              !widget.showArrowBack
          ? null
          : widget.showArrowBack
          ? AppBar(
              title: Text(t.profile),
              centerTitle: true,
              leading: const CustomBackButton(),
              actions: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notifications")
                      .where("userId", isEqualTo: user.uid)
                      .where("recipient", isEqualTo: "user")
                      .where("storeId", isEqualTo: widget.storeId)
                      .where("isRead", isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data?.docs.length ?? 0;

                    return IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserNotificationsPage(storeId: widget.storeId),
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
                                  unreadCount > 99
                                      ? "99+"
                                      : unreadCount.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onError,
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
                      MaterialPageRoute(
                        builder: (_) =>
                            UserSettingsPage(storeId: widget.storeId),
                      ),
                    );
                  },
                ),
              ],
            )
          : AppBar(title: Text(t.profile), centerTitle: true),

      body: _buildUserProfile(context, t, user),
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
                            _buildStoreLogo(context, isDesktop),

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
                      .where("storeId", isEqualTo: widget.storeId)
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            "${t.somethingWentWrong}\n${snapshot.error}",
                            textAlign: TextAlign.center,
                          ),
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
              builder: (_) =>
                  OrderDetailsPage(orderId: order.id, storeId: widget.storeId),
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
                child: FaIcon(
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
                          FaIcon(
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
                    "$total ${t.currencySymbol}",
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

  FaIconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return FontAwesomeIcons.hourglassHalf;

      case "processing":
        return FontAwesomeIcons.gear;

      case "shipped":
        return FontAwesomeIcons.truck;

      case "delivered":
        return FontAwesomeIcons.circleCheck;

      case "cancelled":
        return FontAwesomeIcons.circleXmark;

      default:
        return FontAwesomeIcons.circleQuestion;
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
