import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecomerce_app/auth/super_admin_login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/app_preferences.dart';
import 'package:ecomerce_app/user_dashboard/main_nav_user.dart';
import 'package:flutter/material.dart';

class StoreSelectionPage extends StatelessWidget {
  const StoreSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('stores')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(t.somethingWentWrong));
            }

            final stores = snapshot.data?.docs ?? [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 700;
                final hasStores = stores.isNotEmpty;
                final contentWidth = isWeb ? 900.0 : constraints.maxWidth;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 32 : 20,
                        vertical: 24,
                      ),
                      children: [
                        Icon(
                          hasStores
                              ? Icons.storefront_rounded
                              : Icons.store_mall_directory_outlined,
                          size: 48,
                          color: colorScheme.primary,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          hasStores ? t.chooseYourStore : t.noStoresYet,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          hasStores
                              ? t.selectStoreToContinue
                              : t.noStoresAvailableAtMoment,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),

                        const SizedBox(height: 28),

                        if (hasStores)
                          ...stores.map((store) {
                            final data = store.data();
                            final storeId = store.id;
                            final storeName =
                                data['name']?.toString().trim().isNotEmpty ==
                                    true
                                ? data['name'].toString()
                                : storeId;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Card(
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isWeb ? 24 : 16,
                                    vertical: isWeb ? 12 : 8,
                                  ),
                                  leading: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Builder(
                                        builder: (context) {
                                          final logoUrl = data['logoUrl']
                                              ?.toString()
                                              .trim();

                                          if (logoUrl != null &&
                                              logoUrl.isNotEmpty) {
                                            return Image.network(
                                              logoUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.storefront_rounded,
                                                      color: colorScheme
                                                          .onPrimaryContainer,
                                                    );
                                                  },
                                              loadingBuilder:
                                                  (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }

                                                    return Center(
                                                      child: SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: colorScheme
                                                                  .primary,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                            );
                                          }

                                          return Icon(
                                            Icons.storefront_rounded,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    storeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(storeId),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                  ),

                                  onTap: () async {
                                    await AppPreferences.setSelectedStoreId(
                                      storeId,
                                    );

                                    if (!context.mounted) return;

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MainNavUser(storeId: storeId),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),

                        if (!hasStores)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 40,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  t.noActiveStoresAvailable,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SuperAdminLoginPage(),
                                ),
                              );
                            },
                            child: Text(t.superAdmin),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
