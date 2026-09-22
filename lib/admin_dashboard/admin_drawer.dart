import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
import 'package:ecomerce_app/admin_dashboard/admin_settings_page.dart';
import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';
import 'package:ecomerce_app/admin_dashboard/product_page.dart';
import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
import 'package:ecomerce_app/admin_dashboard/users_page.dart';
import 'package:ecomerce_app/auth/login_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/services/cart_storage.dart';
import 'package:ecomerce_app/services/favorite_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Drawer(
        child: Center(
          child: Text(
            t.noUserFound,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Drawer(
            child: Center(
              child: Text(
                t.userNotFound,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final firstName = data["firstName"] ?? "";
        final lastName = data["lastName"] ?? "";
        final email = data["email"] ?? "";
        final photoUrl = data["photoUrl"] ?? "";

        return Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),

                        child: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,

                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,

                          child: photoUrl.isEmpty
                              ? Icon(
                                  Icons.admin_panel_settings,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$firstName $lastName",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    t.administrator,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Text(
                    t.menu,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  title: t.orders,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminOrdersPage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.people_outline,
                  color: Theme.of(context).colorScheme.tertiary,
                  title: t.customers,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UsersPage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.inventory_2_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  title: t.products,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductPage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.payments_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  title: t.revenue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RevenuePage()),
                    );
                  },
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.tertiary,
                  title: t.analytics,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnalyticsPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Text(
                    t.system,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  title: t.settings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminSettingsPage()),
                    );
                  },
                ),

                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),

                _buildMenuTile(
                  context,
                  icon: Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error,
                  title: t.logout,
                  onTap: () async {
                    Navigator.pop(context);

                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        final t = AppLocalizations.of(dialogContext)!;
                        final colorScheme = Theme.of(dialogContext).colorScheme;

                        return AlertDialog(
                          title: Text(t.logout),
                          content: Text(t.logoutConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(t.cancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(t.logout),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout != true) return;

                    await FirebaseAuth.instance.signOut();

                    await CartStorage.clearCart();
                    await FavoriteStorage.clearFavorites();

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_orders_page.dart';
// import 'package:ecomerce_app/admin_dashboard/admin_settings_page.dart';
// import 'package:ecomerce_app/admin_dashboard/analytics_page.dart';
// import 'package:ecomerce_app/admin_dashboard/product_page.dart';
// import 'package:ecomerce_app/admin_dashboard/revenue_page.dart';
// import 'package:ecomerce_app/admin_dashboard/users_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AdminDrawer extends StatelessWidget {
//   const AdminDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return Drawer(
//         child: Center(
//           child: Text(
//             t.noUserFound,
//             style: Theme.of(context).textTheme.bodyLarge,
//           ),
//         ),
//       );
//     }

//     return FutureBuilder<DocumentSnapshot>(
//       future: FirebaseFirestore.instance
//           .collection("users")
//           .doc(currentUser.uid)
//           .get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Drawer(
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//           );
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return Drawer(
//             child: Center(
//               child: Text(
//                 t.userNotFound,
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             ),
//           );
//         }

//         final data = snapshot.data!.data() as Map<String, dynamic>;

//         final firstName = data["firstName"] ?? "";
//         final lastName = data["lastName"] ?? "";
//         final email = data["email"] ?? "";
//         final photoUrl = data["photoUrl"] ?? "";

//         return Drawer(
//           child: SafeArea(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 65,
//                         height: 65,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Theme.of(context).colorScheme.primary,
//                             width: 2,
//                           ),
//                         ),

//                         child: CircleAvatar(
//                           backgroundColor: Theme.of(
//                             context,
//                           ).colorScheme.surfaceContainerHighest,

//                           backgroundImage: photoUrl.isNotEmpty
//                               ? NetworkImage(photoUrl)
//                               : null,

//                           child: photoUrl.isEmpty
//                               ? Icon(
//                                   Icons.admin_panel_settings,
//                                   size: 32,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 )
//                               : null,
//                         ),
//                       ),

//                       const SizedBox(width: 15),

//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "$firstName $lastName",
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(fontWeight: FontWeight.bold),
//                             ),

//                             const SizedBox(height: 4),

//                             Text(
//                               email,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                             ),

//                             const SizedBox(height: 8),

//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 5,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.secondaryContainer,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.verified,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.secondary,
//                                     size: 16,
//                                   ),

//                                   const SizedBox(width: 5),

//                                   Text(
//                                     t.administrator,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .labelSmall
//                                         ?.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Divider(
//                   indent: 20,
//                   endIndent: 20,
//                   color: Theme.of(context).colorScheme.outlineVariant,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
//                   child: Text(
//                     t.menu,
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                 ),
//                 _buildMenuTile(
//                   context,
//                   icon: Icons.shopping_bag_outlined,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.orders,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => AdminOrdersPage()),
//                     );
//                   },
//                 ),

//                 _buildMenuTile(
//                   context,
//                   icon: Icons.people_outline,
//                   color: Theme.of(context).colorScheme.tertiary,
//                   title: t.customers,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => UsersPage()),
//                     );
//                   },
//                 ),

//                 _buildMenuTile(
//                   context,
//                   icon: Icons.inventory_2_outlined,
//                   color: Theme.of(context).colorScheme.primary,
//                   title: t.products,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => ProductPage()),
//                     );
//                   },
//                 ),

//                 _buildMenuTile(
//                   context,
//                   icon: Icons.payments_outlined,
//                   color: Theme.of(context).colorScheme.secondary,
//                   title: t.revenue,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => RevenuePage()),
//                     );
//                   },
//                 ),

//                 _buildMenuTile(
//                   context,
//                   icon: Icons.analytics_outlined,
//                   color: Theme.of(context).colorScheme.tertiary,
//                   title: t.analytics,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => AnalyticsPage()),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),

//                 Divider(
//                   indent: 20,
//                   endIndent: 20,
//                   color: Theme.of(context).colorScheme.outlineVariant,
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
//                   child: Text(
//                     t.system,
//                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                 ),
//                 _buildMenuTile(
//                   context,
//                   icon: Icons.settings_outlined,
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   title: t.settings,
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => AdminSettingsPage()),
//                     );
//                   },
//                 ),

//                 Divider(
//                   indent: 20,
//                   endIndent: 20,
//                   color: Theme.of(context).colorScheme.outlineVariant,
//                 ),

//                 _buildMenuTile(
//                   context,
//                   icon: Icons.logout_rounded,
//                   color: Theme.of(context).colorScheme.error,
//                   title: t.logout,
//                   onTap: () async {
//                     Navigator.pop(context);

//                     final shouldLogout = await showDialog<bool>(
//                       context: context,
//                       builder: (dialogContext) {
//                         final t = AppLocalizations.of(dialogContext)!;
//                         final colorScheme = Theme.of(dialogContext).colorScheme;

//                         return AlertDialog(
//                           title: Text(t.logout),
//                           content: Text(t.logoutConfirmation),
//                           actions: [
//                             TextButton(
//                               onPressed: () =>
//                                   Navigator.pop(dialogContext, false),
//                               child: Text(t.cancel),
//                             ),
//                             FilledButton(
//                               style: FilledButton.styleFrom(
//                                 backgroundColor: colorScheme.error,
//                                 foregroundColor: colorScheme.onError,
//                               ),
//                               onPressed: () =>
//                                   Navigator.pop(dialogContext, true),
//                               child: Text(t.logout),
//                             ),
//                           ],
//                         );
//                       },
//                     );

//                     if (shouldLogout != true) return;

//                     await FirebaseAuth.instance.signOut();
//                   },
//                 ),
//                 const SizedBox(height: 15),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMenuTile(
//     BuildContext context, {
//     required IconData icon,
//     required Color color,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//       child: ListTile(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         leading: Container(
//           width: 42,
//           height: 42,
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: .12),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color),
//         ),
//         title: Text(
//           title,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
//         ),
//         trailing: Icon(
//           Icons.chevron_right,
//           size: 20,
//           color: Theme.of(context).colorScheme.onSurfaceVariant,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }
