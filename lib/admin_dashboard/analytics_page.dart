import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  final bool showAppBar;

  const AnalyticsPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              leading: const CustomBackButton(),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.analytics,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.storePerformanceOverview,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : null,
      body: SafeArea(
        child: FutureBuilder<List<QuerySnapshot>>(
          future: Future.wait([
            FirebaseFirestore.instance.collection("orders").get(),
            FirebaseFirestore.instance.collection("users").get(),
            FirebaseFirestore.instance.collection("products").get(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(child: Text(t.noData));
            }

            final orders = snapshot.data![0];
            final allUsers = snapshot.data![1];

            final usersCount = allUsers.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return data["role"] == "user" && data["emailVerified"] == true;
            }).length;

            final products = snapshot.data![2];

            double revenue = 0;

            int pending = 0;
            int processing = 0;
            int delivered = 0;
            int cancelled = 0;
            int shipped = 0;

            for (final order in orders.docs) {
              final data = order.data() as Map<String, dynamic>;

              final status = (data["status"] ?? "").toString().toLowerCase();

              switch (status) {
                case "delivered":
                  revenue += (data["totalPrice"] as num?)?.toDouble() ?? 0;
                  delivered++;
                  break;

                case "pending":
                  pending++;
                  break;

                case "processing":
                  processing++;
                  break;

                case "shipped":
                  shipped++;
                  break;

                case "cancelled":
                  cancelled++;
                  break;
              }
            }

            final totalOrders = orders.docs.length;

            final successRate = totalOrders == 0
                ? 0
                : ((delivered / totalOrders) * 100).round();

            final screenWidth = MediaQuery.sizeOf(context).width;
            final isDesktop = screenWidth >= 900;

            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 20,
                vertical: 20,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isDesktop ? 30 : 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: .25),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: .15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.attach_money_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      size: 28,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: .15),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          t.revenue,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              Text(
                                t.totalRevenue,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary.withValues(alpha: .7),
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "\$${revenue.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 42 : 38,
                                ),
                              ),

                              const SizedBox(height: 25),

                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withValues(alpha: .12),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.orders,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                                  .withValues(alpha: .7),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "$totalOrders",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withValues(alpha: .12),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.success,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                                  .withValues(alpha: .7),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "$successRate%",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          t.orderStatus,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 16),

                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _StatusCard(
                                      title: t.pending,
                                      value: "$pending",
                                      icon: Icons.schedule_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
                                    ),
                                    const SizedBox(height: 12),
                                    _StatusCard(
                                      title: t.processing,
                                      value: "$processing",
                                      icon: Icons.sync_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    _StatusCard(
                                      title: t.shipped,
                                      value: "$shipped",
                                      icon: Icons.local_shipping_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  children: [
                                    _StatusCard(
                                      title: t.delivered,
                                      value: "$delivered",
                                      icon: Icons.check_circle_rounded,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 12),
                                    _StatusCard(
                                      title: t.cancelled,
                                      value: "$cancelled",
                                      icon: Icons.cancel_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _StatusCard(
                                title: t.pending,
                                value: "$pending",
                                icon: Icons.schedule_rounded,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(height: 12),
                              _StatusCard(
                                title: t.processing,
                                value: "$processing",
                                icon: Icons.sync_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              _StatusCard(
                                title: t.shipped,
                                value: "$shipped",
                                icon: Icons.local_shipping_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              _StatusCard(
                                title: t.delivered,
                                value: "$delivered",
                                icon: Icons.check_circle_rounded,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 12),
                              _StatusCard(
                                title: t.cancelled,
                                value: "$cancelled",
                                icon: Icons.cancel_rounded,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ],
                          ),

                        const SizedBox(height: 30),

                        Text(
                          t.businessOverview,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: .05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.insights_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      t.businessHealth,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              _InsightRow(
                                icon: Icons.attach_money_rounded,
                                text: t.revenueGeneratedFromDeliveredOrders,
                                color: Theme.of(context).colorScheme.primary,
                              ),

                              const SizedBox(height: 12),

                              _InsightRow(
                                icon: Icons.people_alt_rounded,
                                text: t.usersRegistered(usersCount),
                                color: Theme.of(context).colorScheme.secondary,
                              ),

                              const SizedBox(height: 12),

                              _InsightRow(
                                icon: Icons.inventory_2_rounded,
                                text: t.productsAvailable(products.docs.length),
                                color: Theme.of(context).colorScheme.tertiary,
                              ),

                              const SizedBox(height: 12),

                              _InsightRow(
                                icon: Icons.local_shipping_rounded,
                                text: t.ordersDeliveredSuccessfully(delivered),
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),

        const SizedBox(width: 12),

        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class AnalyticsPage extends StatelessWidget {
//   final bool showAppBar;
//   const AnalyticsPage({super.key, this.showAppBar = true});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: showAppBar
//           ? AppBar(
//               elevation: 0,
//               scrolledUnderElevation: 0,
//               centerTitle: false,
//               leading: const CustomBackButton(),
//               title: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     t.analytics,
//                     style: Theme.of(context).textTheme.headlineLarge,
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     t.storePerformanceOverview,
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             )
//           : null,
//       body: SafeArea(
//         child: FutureBuilder<List<QuerySnapshot>>(
//           future: Future.wait([
//             FirebaseFirestore.instance.collection("orders").get(),
//             FirebaseFirestore.instance.collection("users").get(),
//             FirebaseFirestore.instance.collection("products").get(),
//           ]),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(
//                   t.somethingWentWrong,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             if (!snapshot.hasData) {
//               return Center(child: Text(t.noData));
//             }

//             final orders = snapshot.data![0];
//             final allUsers = snapshot.data![1];

//             final usersCount = allUsers.docs.where((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               return data["role"] == "user";
//             }).length;
//             final products = snapshot.data![2];

//             double revenue = 0;

//             int pending = 0;
//             int processing = 0;
//             int delivered = 0;
//             int cancelled = 0;
//             int shipped = 0;

//             for (final order in orders.docs) {
//               final data = order.data() as Map<String, dynamic>;

//               final status = (data["status"] ?? "").toString().toLowerCase();

//               switch (status) {
//                 case "delivered":
//                   revenue += (data["totalPrice"] as num?)?.toDouble() ?? 0;
//                   delivered++;
//                   break;

//                 case "pending":
//                   pending++;
//                   break;

//                 case "processing":
//                   processing++;
//                   break;
//                 case "shipped":
//                   shipped++;
//                   break;
//                 case "cancelled":
//                   cancelled++;
//                   break;
//               }
//             }

//             final totalOrders = orders.docs.length;

//             final successRate = totalOrders == 0
//                 ? 0
//                 : ((delivered / totalOrders) * 100).round();

//             return ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(28),
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Theme.of(context).colorScheme.primary,
//                         Theme.of(context).colorScheme.secondary,
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.primary.withValues(alpha: .25),
//                         blurRadius: 25,
//                         offset: const Offset(0, 12),
//                       ),
//                     ],
//                   ),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onPrimary.withValues(alpha: .15),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.attach_money_rounded,
//                               color: Theme.of(context).colorScheme.onPrimary,
//                               size: 28,
//                             ),
//                           ),

//                           const Spacer(),

//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onPrimary.withValues(alpha: .15),
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.trending_up,
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onPrimary,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   t.revenue,
//                                   style: TextStyle(
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 30),

//                       Text(
//                         t.totalRevenue,
//                         style: TextStyle(
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.onPrimary.withValues(alpha: .7),
//                           fontSize: 16,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       Text(
//                         "\$${revenue.toStringAsFixed(2)}",
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.onPrimary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 38,
//                         ),
//                       ),

//                       const SizedBox(height: 25),

//                       Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onPrimary.withValues(alpha: .12),
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     t.orders,
//                                     style: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .onPrimary
//                                           .withValues(alpha: .7),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     "$totalOrders",
//                                     style: TextStyle(
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimary,
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           const SizedBox(width: 14),

//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onPrimary.withValues(alpha: .12),
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     t.success,
//                                     style: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .onPrimary
//                                           .withValues(alpha: .7),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   Text(
//                                     "$successRate%",
//                                     style: TextStyle(
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimary,
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),
//                 Text(
//                   t.orderStatus,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 16),
//                 Column(
//                   children: [
//                     _StatusCard(
//                       title: t.pending,
//                       value: "$pending",
//                       icon: Icons.schedule_rounded,
//                       color: Theme.of(context).colorScheme.tertiary,
//                     ),

//                     const SizedBox(height: 12),

//                     _StatusCard(
//                       title: t.processing,
//                       value: "$processing",
//                       icon: Icons.sync_rounded,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     const SizedBox(height: 12),

//                     _StatusCard(
//                       title: t.shipped,
//                       value: "$shipped",
//                       icon: Icons.local_shipping_rounded,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     const SizedBox(height: 12),

//                     _StatusCard(
//                       title: t.delivered,
//                       value: "$delivered",
//                       icon: Icons.check_circle_rounded,
//                       color: Colors.green,
//                     ),

//                     const SizedBox(height: 12),

//                     _StatusCard(
//                       title: t.cancelled,
//                       value: "$cancelled",
//                       icon: Icons.cancel_rounded,
//                       color: Theme.of(context).colorScheme.error,
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 30),

//                 Text(
//                   t.businessOverview,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(22),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.shadow.withValues(alpha: .05),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.primaryContainer,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Icon(
//                               Icons.insights_rounded,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                           const SizedBox(width: 14),

//                           Text(
//                             t.businessHealth,
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 20),

//                       _InsightRow(
//                         icon: Icons.attach_money_rounded,
//                         text: t.revenueGeneratedFromDeliveredOrders,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),

//                       const SizedBox(height: 12),

//                       _InsightRow(
//                         icon: Icons.people_alt_rounded,
//                         text: t.usersRegistered(usersCount),
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),

//                       const SizedBox(height: 12),

//                       _InsightRow(
//                         icon: Icons.inventory_2_rounded,
//                         text: t.productsAvailable(products.docs.length),
//                         color: Theme.of(context).colorScheme.tertiary,
//                       ),

//                       const SizedBox(height: 12),

//                       _InsightRow(
//                         icon: Icons.local_shipping_rounded,
//                         text: t.ordersDeliveredSuccessfully(delivered),
//                         color: Theme.of(context).colorScheme.error,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _StatusCard extends StatelessWidget {
//   const _StatusCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: .12),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color),
//           ),

//           const SizedBox(width: 16),

//           Expanded(
//             child: Text(
//               title,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
//             ),
//           ),

//           Text(
//             value,
//             style: Theme.of(
//               context,
//             ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InsightRow extends StatelessWidget {
//   const _InsightRow({
//     required this.icon,
//     required this.text,
//     required this.color,
//   });

//   final IconData icon;
//   final String text;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: color, size: 22),

//         const SizedBox(width: 12),

//         Expanded(
//           child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
//         ),
//       ],
//     );
//   }
// }
