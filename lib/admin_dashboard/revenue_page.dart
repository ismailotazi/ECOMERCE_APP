import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  double totalRevenue = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(t.revenue),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "delivered")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            final orders = snapshot.data!.docs;

            double totalRevenue = 0;

            for (final order in orders) {
              final data = order.data() as Map<String, dynamic>;

              totalRevenue += (data["totalPrice"] as num?)?.toDouble() ?? 0;
            }

            final totalOrders = orders.length;

            final averageOrder = totalOrders == 0
                ? 0
                : totalRevenue / totalOrders;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: isDesktop ? 28 : 20,
                  ),
                  child: ListView(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 32 : 25),
                          child: Column(
                            children: [
                              Container(
                                width: isDesktop ? 76 : 70,
                                height: isDesktop ? 76 : 70,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: .12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.attach_money,
                                  color: AppColors.success,
                                  size: isDesktop ? 52 : 50,
                                ),
                              ),

                              SizedBox(height: isDesktop ? 18 : 15),

                              Text(
                                t.totalRevenue,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "\$${totalRevenue.toStringAsFixed(2)}",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isDesktop ? 34 : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 24 : 20),

                      GridView.count(
                        crossAxisCount: isDesktop ? 2 : 2,
                        crossAxisSpacing: isDesktop ? 20 : 15,
                        mainAxisSpacing: isDesktop ? 20 : 15,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: isDesktop ? 1.5 : 0.9,
                        children: [
                          _StatCard(
                            title: t.orders,
                            value: totalOrders.toString(),
                            icon: Icons.shopping_bag,
                            color: AppColors.info,
                          ),
                          _StatCard(
                            title: t.average,
                            value: "\$${averageOrder.toStringAsFixed(2)}",
                            icon: Icons.bar_chart,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/////////////////////////////////////
class _StatCard extends StatelessWidget {
  const _StatCard({
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Card(
      elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 22 : 16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isDesktop ? 58 : 52,
                height: isDesktop ? 58 : 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: isDesktop ? 34 : 34),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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

// class RevenuePage extends StatefulWidget {
//   const RevenuePage({super.key});

//   @override
//   State<RevenuePage> createState() => _RevenuePageState();
// }

// class _RevenuePageState extends State<RevenuePage> {
//   double totalRevenue = 0;

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         leading: const CustomBackButton(),
//         title: Text(t.revenue),
//       ),

//       body: SafeArea(
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("orders")
//               .where("status", isEqualTo: "delivered")
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             final orders = snapshot.data!.docs;

//             double totalRevenue = 0;

//             for (final order in orders) {
//               final data = order.data() as Map<String, dynamic>;

//               totalRevenue += (data["totalPrice"] as num?)?.toDouble() ?? 0;
//             }
//             final totalOrders = orders.length;
//             final averageOrder = totalOrders == 0
//                 ? 0
//                 : totalRevenue / totalOrders;
//             return Padding(
//               padding: const EdgeInsets.all(20),
//               child: ListView(
//                 children: [
//                   Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(25),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.attach_money,
//                             color: AppColors.success,
//                             size: 50,
//                           ),
//                           const SizedBox(height: 15),

//                           Text(
//                             t.totalRevenue,
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),

//                           const SizedBox(height: 10),

//                           Text(
//                             "\$${totalRevenue.toStringAsFixed(2)}",
//                             style: Theme.of(context).textTheme.headlineMedium
//                                 ?.copyWith(
//                                   color: AppColors.success,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   GridView.count(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 15,
//                     mainAxisSpacing: 15,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     childAspectRatio: 0.9,
//                     children: [
//                       _StatCard(
//                         title: t.orders,
//                         value: totalOrders.toString(),
//                         icon: Icons.shopping_bag,
//                         color: AppColors.info,
//                       ),
//                       _StatCard(
//                         title: t.average,
//                         value: "\$${averageOrder.toStringAsFixed(2)}",
//                         icon: Icons.bar_chart,
//                         color: AppColors.success,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// /////////////////////////////////////
// class _StatCard extends StatelessWidget {
//   const _StatCard({
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
//     return Card(
//       elevation: Theme.of(context).brightness == Brightness.dark ? 0 : 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 34),

//               const SizedBox(height: 10),

//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 8),

//               Text(
//                 value,
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
