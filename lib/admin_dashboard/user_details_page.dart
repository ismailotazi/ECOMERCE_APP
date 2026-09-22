import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/admin_dashboard/edit_user_page.dart';
import 'package:ecomerce_app/admin_dashboard/user_orders_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/app_colors.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(t.usersDetails),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (!snapshot.data!.exists) {
              return Center(
                child: Text(
                  t.userNotFound,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: isDesktop ? 28 : 20,
                  ),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: isDesktop ? 60 : 55,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            backgroundImage:
                                data["photoUrl"] != null &&
                                    data["photoUrl"].toString().isNotEmpty
                                ? NetworkImage(data["photoUrl"])
                                : null,
                            child:
                                data["photoUrl"] == null ||
                                    data["photoUrl"].toString().isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: isDesktop ? 60 : 55,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  )
                                : null,
                          ),
                          SizedBox(height: isDesktop ? 18 : 15),
                          Text(
                            "${data["firstName"]} ${data["lastName"]}",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "@${data["username"]}",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data["email"] ?? "",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              t.user,
                              style: TextStyle(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 34 : 30),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 28 : 25),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 22 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.contactInformation,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),

                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.info.withValues(
                                  alpha: .15,
                                ),
                                child: Icon(Icons.email, color: AppColors.info),
                              ),
                              title: Text(t.email),
                              subtitle: Text(data["email"] ?? "-"),
                            ),

                            const Divider(),

                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.success.withValues(
                                  alpha: .15,
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: AppColors.success,
                                ),
                              ),
                              title: Text(t.phone),
                              subtitle: Text(data["phone"] ?? "-"),
                            ),

                            const Divider(),

                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.warning.withValues(
                                  alpha: .15,
                                ),
                                child: Icon(
                                  Icons.people,
                                  color: AppColors.warning,
                                ),
                              ),
                              title: Text(t.gender),
                              subtitle: Text(data["gender"] ?? "-"),
                            ),

                            const Divider(),

                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondary.withValues(
                                  alpha: .15,
                                ),
                                child: Icon(
                                  Icons.cake,
                                  color: AppColors.secondary,
                                ),
                              ),
                              title: Text(t.dateOfBirth),
                              subtitle: Text(
                                data["birthDate"] != null
                                    ? "${(data["birthDate"] as Timestamp).toDate().day}/"
                                          "${(data["birthDate"] as Timestamp).toDate().month}/"
                                          "${(data["birthDate"] as Timestamp).toDate().year}"
                                    : "-",
                              ),
                            ),

                            SizedBox(height: isDesktop ? 28 : 25),

                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isDesktop ? 22 : 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.shippingAddress,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 20),

                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.success
                                            .withValues(alpha: .15),
                                        child: Icon(
                                          Icons.public,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      title: Text(t.country),
                                      subtitle: Text(data["country"] ?? "-"),
                                    ),

                                    const Divider(),

                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.info
                                            .withValues(alpha: .15),
                                        child: Icon(
                                          Icons.location_city,
                                          color: AppColors.info,
                                        ),
                                      ),
                                      title: Text(t.city),
                                      subtitle: Text(data["city"] ?? "-"),
                                    ),

                                    const Divider(),

                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.warning
                                            .withValues(alpha: .15),
                                        child: Icon(
                                          Icons.home,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                      title: Text(t.streetAddress),
                                      subtitle: Text(data["address"] ?? "-"),
                                    ),

                                    const Divider(),

                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.secondary
                                            .withValues(alpha: .15),
                                        child: Icon(
                                          Icons.markunread_mailbox,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      title: Text(t.zipCode),
                                      subtitle: Text(data["zipCode"] ?? "-"),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: isDesktop ? 28 : 25),

                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("orders")
                                  .where("userId", isEqualTo: userId)
                                  .get(),
                              builder: (context, orderSnapshot) {
                                if (!orderSnapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  );
                                }

                                final orders = orderSnapshot.data!.docs;

                                double totalSpent = 0;

                                for (var order in orders) {
                                  final data =
                                      order.data() as Map<String, dynamic>;

                                  totalSpent += (data["totalPrice"] ?? 0)
                                      .toDouble();
                                }

                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      isDesktop ? 22 : 18,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.customerStatistics,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 20),

                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.info
                                                .withValues(alpha: .15),
                                            child: Icon(
                                              Icons.shopping_bag,
                                              color: AppColors.info,
                                            ),
                                          ),
                                          title: Text(t.totalOrders),
                                          trailing: Text(
                                            orders.length.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.info,
                                                ),
                                          ),
                                        ),

                                        const Divider(),

                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.success
                                                .withValues(alpha: .15),
                                            child: Icon(
                                              Icons.payments,
                                              color: AppColors.success,
                                            ),
                                          ),
                                          title: Text(t.totalSpent),
                                          trailing: Text(
                                            "\$${totalSpent.toStringAsFixed(2)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.success,
                                                ),
                                          ),
                                        ),

                                        const Divider(),

                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.warning
                                                .withValues(alpha: .15),
                                            child: Icon(
                                              Icons.calendar_today,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                          title: Text(t.memberSince),
                                          subtitle: Text(
                                            data["createdAt"] != null
                                                ? (data["createdAt"]
                                                          as Timestamp)
                                                      .toDate()
                                                      .toString()
                                                      .split(" ")
                                                      .first
                                                : "-",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: isDesktop ? 28 : 25),

                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isDesktop ? 22 : 18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.quickActions,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 20),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => UserOrdersPage(
                                                userId: userId,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.shopping_bag_outlined,
                                        ),
                                        label: Text(t.viewOrders),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.info,
                                          foregroundColor: AppColors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditUserPage(
                                                userId: userId,
                                                initialData: data,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.edit),
                                        label: Text(t.editUser),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: AppColors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: Text(t.deleteUser),
                                              content: Text(
                                                t.areYouSureDeleteUser,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(t.cancel),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors.error,
                                                      ),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: Text(
                                                    t.delete,
                                                    style: TextStyle(
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(userId)
                                                .delete();

                                            if (context.mounted) {
                                              Navigator.pop(context);

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    t.userDeletedSuccessfully,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.delete),
                                        label: Text(t.deleteUser),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecomerce_app/admin_dashboard/edit_user_page.dart';
// import 'package:ecomerce_app/admin_dashboard/user_orders_page.dart';
// import 'package:ecomerce_app/l10n/app_localizations.dart';
// import 'package:ecomerce_app/theme/app_colors.dart';
// import 'package:ecomerce_app/theme/custom_back_button.dart';
// import 'package:flutter/material.dart';

// class UserDetailsPage extends StatelessWidget {
//   final String userId;

//   const UserDetailsPage({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     final t = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,

//         leading: const CustomBackButton(),
//         title: Text(t.usersDetails),
//       ),

//       body: SafeArea(
//         child: FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance
//               .collection("users")
//               .doc(userId)
//               .get(),

//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               );
//             }

//             if (!snapshot.data!.exists) {
//               return Center(
//                 child: Text(
//                   t.userNotFound,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//               );
//             }

//             final data = snapshot.data!.data() as Map<String, dynamic>;

//             return ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Center(
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 55,
//                         backgroundColor: Theme.of(
//                           context,
//                         ).colorScheme.primaryContainer,
//                         backgroundImage:
//                             data["photoUrl"] != null &&
//                                 data["photoUrl"].toString().isNotEmpty
//                             ? NetworkImage(data["photoUrl"])
//                             : null,
//                         child:
//                             data["photoUrl"] == null ||
//                                 data["photoUrl"].toString().isEmpty
//                             ? Icon(
//                                 Icons.person,
//                                 size: 55,
//                                 color: Theme.of(
//                                   context,
//                                 ).colorScheme.onPrimaryContainer,
//                               )
//                             : null,
//                       ),
//                       const SizedBox(height: 15),

//                       Text(
//                         "${data["firstName"]} ${data["lastName"]}",
//                         style: Theme.of(context).textTheme.headlineSmall
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),

//                       const SizedBox(height: 6),

//                       Text(
//                         "@${data["username"]}",
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         data["email"] ?? "",
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 18,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.info.withValues(alpha: .15),
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Text(
//                           t.user,
//                           style: TextStyle(
//                             color: AppColors.info,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(18),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           t.contactInformation,
//                           style: Theme.of(context).textTheme.titleMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),

//                         const SizedBox(height: 20),

//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: CircleAvatar(
//                             backgroundColor: AppColors.info.withValues(
//                               alpha: .15,
//                             ),
//                             child: Icon(Icons.email, color: AppColors.info),
//                           ),
//                           title: Text(t.email),
//                           subtitle: Text(data["email"] ?? "-"),
//                         ),

//                         const Divider(),

//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: CircleAvatar(
//                             backgroundColor: AppColors.success.withValues(
//                               alpha: .15,
//                             ),
//                             child: Icon(Icons.phone, color: AppColors.success),
//                           ),
//                           title: Text(t.phone),
//                           subtitle: Text(data["phone"] ?? "-"),
//                         ),

//                         const Divider(),

//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: CircleAvatar(
//                             backgroundColor: AppColors.warning.withValues(
//                               alpha: .15,
//                             ),
//                             child: Icon(Icons.people, color: AppColors.warning),
//                           ),
//                           title: Text(t.gender),
//                           subtitle: Text(data["gender"] ?? "-"),
//                         ),

//                         const Divider(),

//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: CircleAvatar(
//                             backgroundColor: AppColors.secondary.withValues(
//                               alpha: .15,
//                             ),
//                             child: Icon(Icons.cake, color: AppColors.secondary),
//                           ),
//                           title: Text(t.dateOfBirth),
//                           subtitle: Text(
//                             data["birthDate"] != null
//                                 ? "${(data["birthDate"] as Timestamp).toDate().day}/"
//                                       "${(data["birthDate"] as Timestamp).toDate().month}/"
//                                       "${(data["birthDate"] as Timestamp).toDate().year}"
//                                 : "-",
//                           ),
//                         ),
//                         const SizedBox(height: 25),
//                         Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(18),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(18),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   t.shippingAddress,
//                                   style: Theme.of(context).textTheme.titleMedium
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 20),

//                                 ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: CircleAvatar(
//                                     backgroundColor: AppColors.success
//                                         .withValues(alpha: .15),
//                                     child: Icon(
//                                       Icons.public,
//                                       color: AppColors.success,
//                                     ),
//                                   ),
//                                   title: Text(t.country),
//                                   subtitle: Text(data["country"] ?? "-"),
//                                 ),

//                                 const Divider(),

//                                 ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: CircleAvatar(
//                                     backgroundColor: AppColors.info.withValues(
//                                       alpha: .15,
//                                     ),
//                                     child: Icon(
//                                       Icons.location_city,
//                                       color: AppColors.info,
//                                     ),
//                                   ),
//                                   title: Text(t.city),
//                                   subtitle: Text(data["city"] ?? "-"),
//                                 ),

//                                 const Divider(),

//                                 ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: CircleAvatar(
//                                     backgroundColor: AppColors.warning
//                                         .withValues(alpha: .15),
//                                     child: Icon(
//                                       Icons.home,
//                                       color: AppColors.warning,
//                                     ),
//                                   ),
//                                   title: Text(t.streetAddress),
//                                   subtitle: Text(data["address"] ?? "-"),
//                                 ),

//                                 const Divider(),

//                                 ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: CircleAvatar(
//                                     backgroundColor: AppColors.secondary
//                                         .withValues(alpha: .15),
//                                     child: Icon(
//                                       Icons.markunread_mailbox,
//                                       color: AppColors.secondary,
//                                     ),
//                                   ),
//                                   title: Text(t.zipCode),
//                                   subtitle: Text(data["zipCode"] ?? "-"),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 25),

//                         FutureBuilder<QuerySnapshot>(
//                           future: FirebaseFirestore.instance
//                               .collection("orders")
//                               .where("userId", isEqualTo: userId)
//                               .get(),
//                           builder: (context, orderSnapshot) {
//                             if (!orderSnapshot.hasData) {
//                               return Center(
//                                 child: CircularProgressIndicator(
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               );
//                             }

//                             final orders = orderSnapshot.data!.docs;

//                             double totalSpent = 0;

//                             for (var order in orders) {
//                               final data = order.data() as Map<String, dynamic>;

//                               totalSpent += (data["totalPrice"] ?? 0)
//                                   .toDouble();
//                             }

//                             return Card(
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(18),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       t.customerStatistics,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .titleMedium
//                                           ?.copyWith(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                     ),

//                                     const SizedBox(height: 20),

//                                     ListTile(
//                                       contentPadding: EdgeInsets.zero,
//                                       leading: CircleAvatar(
//                                         backgroundColor: AppColors.info
//                                             .withValues(alpha: .15),
//                                         child: Icon(
//                                           Icons.shopping_bag,
//                                           color: AppColors.info,
//                                         ),
//                                       ),
//                                       title: Text(t.totalOrders),
//                                       trailing: Text(
//                                         orders.length.toString(),
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleMedium
//                                             ?.copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: AppColors.info,
//                                             ),
//                                       ),
//                                     ),
//                                     const Divider(),

//                                     ListTile(
//                                       contentPadding: EdgeInsets.zero,
//                                       leading: CircleAvatar(
//                                         backgroundColor: AppColors.success
//                                             .withValues(alpha: .15),
//                                         child: Icon(
//                                           Icons.payments,
//                                           color: AppColors.success,
//                                         ),
//                                       ),
//                                       title: Text(t.totalSpent),
//                                       trailing: Text(
//                                         "\$${totalSpent.toStringAsFixed(2)}",
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleMedium
//                                             ?.copyWith(
//                                               fontWeight: FontWeight.bold,
//                                               color: AppColors.success,
//                                             ),
//                                       ),
//                                     ),

//                                     const Divider(),

//                                     ListTile(
//                                       contentPadding: EdgeInsets.zero,
//                                       leading: CircleAvatar(
//                                         backgroundColor: AppColors.warning
//                                             .withValues(alpha: .15),
//                                         child: Icon(
//                                           Icons.calendar_today,
//                                           color: AppColors.warning,
//                                         ),
//                                       ),
//                                       title: Text(t.memberSince),
//                                       subtitle: Text(
//                                         data["createdAt"] != null
//                                             ? (data["createdAt"] as Timestamp)
//                                                   .toDate()
//                                                   .toString()
//                                                   .split(" ")
//                                                   .first
//                                             : "-",
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 25),
//                         Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(18),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(18),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   t.quickActions,
//                                   style: Theme.of(context).textTheme.titleMedium
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 20),

//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton.icon(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.primary,
//                                       foregroundColor: AppColors.white,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 14,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(14),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) =>
//                                               UserOrdersPage(userId: userId),
//                                         ),
//                                       );
//                                     },
//                                     icon: const Icon(
//                                       Icons.shopping_bag_outlined,
//                                     ),
//                                     label: Text(t.viewOrders),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),

//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton.icon(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.info,
//                                       foregroundColor: AppColors.white,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 14,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(14),
//                                       ),
//                                     ),
//                                     onPressed: () async {
//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => EditUserPage(
//                                             userId: userId,
//                                             initialData: data,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     icon: const Icon(Icons.edit),
//                                     label: Text(t.editUser),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),

//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton.icon(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.error,
//                                       foregroundColor: AppColors.white,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 14,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(14),
//                                       ),
//                                     ),
//                                     onPressed: () async {
//                                       final confirm = await showDialog<bool>(
//                                         context: context,
//                                         builder: (_) => AlertDialog(
//                                           title: Text(t.deleteUser),
//                                           content: Text(t.areYouSureDeleteUser),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () =>
//                                                   Navigator.pop(context, false),
//                                               child: Text(t.cancel),
//                                             ),
//                                             ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor:
//                                                     AppColors.error,
//                                               ),
//                                               onPressed: () =>
//                                                   Navigator.pop(context, true),
//                                               child: Text(
//                                                 t.delete,
//                                                 style: TextStyle(
//                                                   color: AppColors.white,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );

//                                       if (confirm == true) {
//                                         await FirebaseFirestore.instance
//                                             .collection("users")
//                                             .doc(userId)
//                                             .delete();

//                                         if (context.mounted) {
//                                           Navigator.pop(context);

//                                           ScaffoldMessenger.of(
//                                             context,
//                                           ).showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                 t.userDeletedSuccessfully,
//                                               ),
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     },
//                                     icon: const Icon(Icons.delete),
//                                     label: Text(t.deleteUser),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
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
