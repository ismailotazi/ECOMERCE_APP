import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class PlatformOverviewPage extends StatelessWidget {
  const PlatformOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.platformOverview,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('stores').snapshots(),
          builder: (context, storesSnapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'admin')
                  .snapshots(),
              builder: (context, adminsSnapshot) {
                if (storesSnapshot.connectionState == ConnectionState.waiting ||
                    adminsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (storesSnapshot.hasError || adminsSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        t.somethingWentWrong,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final stores = storesSnapshot.data?.docs ?? [];
                final admins = adminsSnapshot.data?.docs ?? [];

                final activeStores = stores.where((doc) {
                  return doc.data()['isActive'] == true;
                }).length;

                final inactiveStores = stores.length - activeStores;

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                final subscribedStores = stores.where((doc) {
                  final subscription = doc.data()['subscription'];

                  if (subscription is! Map) return false;

                  final nextPaymentDate = subscription['nextPaymentDate'];

                  if (nextPaymentDate is! Timestamp) return false;

                  final paymentDate = nextPaymentDate.toDate();

                  final dueDate = DateTime(
                    paymentDate.year,
                    paymentDate.month,
                    paymentDate.day,
                  );

                  return !dueDate.isBefore(today);
                }).length;

                final unsubscribedStores = stores.length - subscribedStores;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final isDesktop = width >= 1100;
                    final isTablet = width >= 700 && width < 1100;

                    final horizontalPadding = isDesktop
                        ? 40.0
                        : isTablet
                        ? 28.0
                        : 16.0;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isDesktop ? 32 : 20,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, t, colorScheme),

                              const SizedBox(height: 24),

                              _buildStats(
                                context,
                                t,
                                colorScheme,
                                stores.length,
                                activeStores,
                                inactiveStores,
                                admins.length,
                                subscribedStores,
                                unsubscribedStores,
                                isDesktop,
                                isTablet,
                              ),
                              const SizedBox(height: 32),

                              _buildSectionTitle(
                                context,
                                t.allStores,
                                Icons.storefront_outlined,
                              ),

                              const SizedBox(height: 14),

                              if (stores.isEmpty)
                                _buildEmptyCard(
                                  context,
                                  icon: Icons.storefront_outlined,
                                  text: t.noStores,
                                )
                              else
                                _buildStores(
                                  context,
                                  t,
                                  colorScheme,
                                  stores,
                                  isDesktop,
                                  isTablet,
                                ),

                              const SizedBox(height: 32),

                              _buildSectionTitle(
                                context,
                                t.allAdmins,
                                Icons.admin_panel_settings_outlined,
                              ),

                              const SizedBox(height: 14),

                              if (admins.isEmpty)
                                _buildEmptyCard(
                                  context,
                                  icon: Icons.admin_panel_settings_outlined,
                                  text: t.noAdmins,
                                )
                              else
                                _buildAdmins(
                                  context,
                                  t,
                                  colorScheme,
                                  admins,
                                  isDesktop,
                                  isTablet,
                                ),

                              const SizedBox(height: 20),
                            ],
                          ),
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

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.insights_outlined,
              color: colorScheme.onPrimary,
              size: 27,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.platformOverview,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  t.manageAllStoresAndAdmins,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    int totalStores,
    int activeStores,
    int inactiveStores,
    int totalAdmins,
    int subscribedStores,
    int unsubscribedStores,
    bool isDesktop,
    bool isTablet,
  ) {
    final cards = [
      _buildStatCard(
        context,
        icon: Icons.storefront_outlined,
        title: t.totalStores,
        value: '$totalStores',
        color: colorScheme.primary,
      ),
      _buildStatCard(
        context,
        icon: Icons.check_circle_outline,
        title: t.activeStores,
        value: '$activeStores',
        color: colorScheme.tertiary,
      ),
      _buildStatCard(
        context,
        icon: Icons.pause_circle_outline,
        title: t.inactive,
        value: '$inactiveStores',
        color: colorScheme.error,
      ),
      _buildStatCard(
        context,
        icon: Icons.verified_outlined,
        title: t.subscribedStores,
        value: '$subscribedStores',
        color: colorScheme.tertiary,
      ),
      _buildStatCard(
        context,
        icon: Icons.event_busy_outlined,
        title: t.unsubscribedStores,
        value: '$unsubscribedStores',
        color: colorScheme.error,
      ),
      _buildStatCard(
        context,
        icon: Icons.admin_panel_settings_outlined,
        title: t.totalAdmins,
        value: '$totalAdmins',
        color: colorScheme.secondary,
      ),
    ];

    if (!isDesktop && !isTablet) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 105,
      ),
      itemBuilder: (_, index) => cards[index],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 21, color: colorScheme.primary),
        const SizedBox(width: 9),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildStores(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> stores,
    bool isDesktop,
    bool isTablet,
  ) {
    if (!isDesktop && !isTablet) {
      return Column(
        children: [
          for (int i = 0; i < stores.length; i++) ...[
            _buildStoreCard(
              context,
              t,
              colorScheme,
              stores[i].id,
              stores[i].data(),
            ),
            if (i < stores.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      itemCount: stores.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 165,
      ),
      itemBuilder: (context, index) {
        final doc = stores[index];

        return _buildStoreCard(context, t, colorScheme, doc.id, doc.data());
      },
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    String storeId,
    Map<String, dynamic> data,
  ) {
    final name = data['name']?.toString().trim();

    final storeName = name != null && name.isNotEmpty ? name : storeId;

    final isActive = data['isActive'] == true;

    final statusColor = isActive ? colorScheme.tertiary : colorScheme.error;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.storefront_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              storeId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  isActive
                      ? Icons.check_circle_outline
                      : Icons.pause_circle_outline,
                  size: 17,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isActive ? t.active : t.inactive,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmins(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> admins,
    bool isDesktop,
    bool isTablet,
  ) {
    if (!isDesktop && !isTablet) {
      return Column(
        children: [
          for (int i = 0; i < admins.length; i++) ...[
            _buildAdminCard(context, t, colorScheme, admins[i].data()),
            if (i < admins.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      itemCount: admins.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 125,
      ),
      itemBuilder: (context, index) {
        return _buildAdminCard(context, t, colorScheme, admins[index].data());
      },
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    Map<String, dynamic> data,
  ) {
    final firstName = data['firstName']?.toString().trim() ?? '';
    final lastName = data['lastName']?.toString().trim() ?? '';

    final fullName = '$firstName $lastName'.trim();

    final name = fullName.isNotEmpty
        ? fullName
        : data['name']?.toString().trim().isNotEmpty == true
        ? data['name'].toString().trim()
        : t.admin;

    final email = data['email']?.toString().trim() ?? '';
    final storeId = data['storeId']?.toString().trim() ?? '';

    final photoUrl = data['photoUrl']?.toString().trim() ?? '';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? Icon(
                      Icons.person_outline,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  if (storeId.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            storeId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 42, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
