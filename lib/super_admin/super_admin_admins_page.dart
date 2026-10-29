import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/super_admin/create_admin_page.dart';
import 'package:ecomerce_app/super_admin/edit_admin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SuperAdminAdminsPage extends StatelessWidget {
  const SuperAdminAdminsPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _adminsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots();
  }

  Future<Map<String, String>> _loadStoreNames() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('stores')
        .get();

    return {
      for (final doc in snapshot.docs)
        doc.id: doc.data()['name']?.toString().trim().isNotEmpty == true
            ? doc.data()['name'].toString().trim()
            : doc.id,
    };
  }

  String _getAdminName(Map<String, dynamic> data) {
    final firstName = data['firstName']?.toString().trim() ?? '';
    final lastName = data['lastName']?.toString().trim() ?? '';

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = data['email']?.toString().trim() ?? '';

    if (email.isNotEmpty) {
      return email;
    }

    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.admins, style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: t.createAdmin,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateAdminPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _adminsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.somethingWentWrong,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            }

            final admins = snapshot.data?.docs ?? [];

            if (admins.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.noAdminsYet,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return FutureBuilder<Map<String, String>>(
              future: _loadStoreNames(),
              builder: (context, storeSnapshot) {
                if (storeSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                final storeNames = storeSnapshot.data ?? <String, String>{};

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final isDesktop = width >= 1100;
                    final isTablet = width >= 700 && width < 1100;

                    final horizontalPadding = isDesktop
                        ? 40.0
                        : isTablet
                        ? 28.0
                        : 20.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isDesktop ? 32 : 24,
                          ),
                          itemCount: admins.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final adminDoc = admins[index];
                            final data = adminDoc.data();
                            final isActive = data['isActive'] != false;
                            final adminName = _getAdminName(data);

                            final email =
                                data['email']?.toString().trim() ?? '';

                            final storeId =
                                data['storeId']?.toString().trim() ?? '';

                            final storeName = storeId.isEmpty
                                ? t.noStoreAssigned
                                : storeNames[storeId] ?? storeId;

                            final photoUrl =
                                data['photoUrl']?.toString().trim() ?? '';
                            final createdAt = data['createdAt'] is Timestamp
                                ? (data['createdAt'] as Timestamp).toDate()
                                : null;
                            return Card(
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditAdminPage(
                                        adminId: adminDoc.id,
                                        initialData: data,
                                      ),
                                    ),
                                  );

                                  if (updated == true && context.mounted) {
                                    // StreamBuilder will refresh automatically.
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(isDesktop ? 24 : 20),
                                  child: _buildAdminContent(
                                    context,
                                    adminId: adminDoc.id,
                                    adminName: adminName,
                                    email: email,
                                    storeId: storeId,
                                    storeName: storeName,
                                    photoUrl: photoUrl,
                                    createdAt: createdAt,
                                    isActive: isActive,
                                    isDesktop: isDesktop,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdminContent(
    BuildContext context, {
    required String adminId,
    required String adminName,
    required String email,
    required String storeId,
    required String storeName,
    required String photoUrl,
    required bool isDesktop,
    required DateTime? createdAt,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(context, photoUrl: photoUrl, radius: 28),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdminName(context, adminName),

                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildEmail(context, email),
                    ],

                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      _buildCreatedAt(context, createdAt),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildStoreInfo(
            context,
            storeName: storeName,
            storeId: storeId,
            adminId: adminId,
            isActive: isActive,
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildAvatar(context, photoUrl: photoUrl, radius: 28),

        const SizedBox(width: 16),

        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminName(context, adminName),

              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildEmail(context, email),
              ],

              if (createdAt != null) ...[
                const SizedBox(height: 4),
                _buildCreatedAt(context, createdAt),
              ],
            ],
          ),
        ),

        const SizedBox(width: 24),

        Expanded(
          flex: 2,
          child: _buildStoreInfo(
            context,
            storeName: storeName,
            storeId: storeId,
            adminId: adminId,
            isActive: isActive,
          ),
        ),

        const SizedBox(width: 16),

        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildAvatar(
    BuildContext context, {
    required String photoUrl,
    required double radius,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
      child: photoUrl.isEmpty
          ? Icon(
              Icons.admin_panel_settings_outlined,
              color: colorScheme.onPrimaryContainer,
            )
          : null,
    );
  }

  Widget _buildAdminName(BuildContext context, String adminName) {
    return Text(
      adminName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildEmail(BuildContext context, String email) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      email,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildStoreInfo(
    BuildContext context, {
    required String storeName,
    required String storeId,
    required String adminId,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STORE LABEL
        Text(
          t.store,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        // STORE INFO
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 21,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName.isNotEmpty ? storeName : storeId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  if (storeId.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      storeId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // STATUS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: (isActive ? colorScheme.tertiary : colorScheme.error)
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (isActive ? colorScheme.tertiary : colorScheme.error)
                  .withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? colorScheme.tertiary : colorScheme.error,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  isActive ? t.active : t.inactive,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive ? colorScheme.tertiary : colorScheme.error,
                  ),
                ),
              ),

              Switch.adaptive(
                value: isActive,
                onChanged: (_) {
                  _toggleAdminStatus(
                    context,
                    adminId: adminId,
                    isActive: isActive,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreatedAt(BuildContext context, DateTime createdAt) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 15,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '${t.since} ${DateFormat('dd.MM.yyyy • HH:mm').format(createdAt)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<void> _toggleAdminStatus(
    BuildContext context, {
    required String adminId,
    required bool isActive,
  }) async {
    final t = AppLocalizations.of(context)!;

    try {
      await FirebaseFirestore.instance.collection('users').doc(adminId).update({
        'isActive': !isActive,
      });
    } on FirebaseException catch (e) {
      debugPrint('TOGGLE ADMIN STATUS ERROR: ${e.code} - ${e.message}');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? t.permissionDenied
                : t.somethingWentWrong,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('TOGGLE ADMIN STATUS ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.somethingWentWrong),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
