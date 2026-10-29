import 'package:ecomerce_app/admin_dashboard/user_details_page.dart';
import 'package:ecomerce_app/l10n/app_localizations.dart';
import 'package:ecomerce_app/theme/custom_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  String getLocalizedRole(BuildContext context, String role) {
    final t = AppLocalizations.of(context)!;

    switch (role.toLowerCase()) {
      case "admin":
        return t.admin;
      case "user":
        return t.user;
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.users),
        leading: const CustomBackButton(),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: () async {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              throw Exception("Unauthorized");
            }

            return FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get();
          }(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

            if (userSnapshot.hasError || !userSnapshot.hasData) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final userData = userSnapshot.data!.data();

            if (userData == null ||
                userData["role"]?.toString() != "admin" ||
                userData["isActive"] != true) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }

            final storeId = userData["storeId"]?.toString();

            if (storeId == null || storeId.isEmpty) {
              return Center(
                child: Text(
                  t.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'user')
                  .where('emailVerified', isEqualTo: true)
                  .where('storeId', isEqualTo: storeId)
                  .snapshots(),
              builder: (context, legacySnapshot) {
                if (legacySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                if (legacySnapshot.hasError) {
                  return Center(
                    child: Text(
                      legacySnapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'user')
                      .where('emailVerified', isEqualTo: true)
                      .where('stores.$storeId.isActive', isEqualTo: true)
                      .snapshots(),
                  builder: (context, multiStoreSnapshot) {
                    if (multiStoreSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    if (multiStoreSnapshot.hasError) {
                      return Center(
                        child: Text(
                          multiStoreSnapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final Map<String, QueryDocumentSnapshot> usersMap = {};

                    // Legacy storeId users
                    if (legacySnapshot.hasData) {
                      for (final doc in legacySnapshot.data!.docs) {
                        usersMap[doc.id] = doc;
                      }
                    }

                    // Multi-store users
                    if (multiStoreSnapshot.hasData) {
                      for (final doc in multiStoreSnapshot.data!.docs) {
                        usersMap[doc.id] = doc;
                      }
                    }

                    final users = usersMap.values.toList();

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          t.noUsersFound,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 15,
                            vertical: isDesktop ? 24 : 15,
                          ),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user =
                                users[index].data() as Map<String, dynamic>;
                            final userId = users[index].id;

                            final String firstName =
                                user["firstName"]?.toString().trim() ?? "";
                            final String lastName =
                                user["lastName"]?.toString().trim() ?? "";

                            final String name = [
                              firstName,
                              lastName,
                            ].where((value) => value.isNotEmpty).join(" ");

                            final String email =
                                user["email"]?.toString().trim() ?? "";
                            final String role =
                                user["role"]?.toString().trim() ?? "user";

                            final String city =
                                user["city"]?.toString().trim() ?? "";
                            final String country =
                                user["country"]?.toString().trim() ?? "";

                            final String location = [
                              city,
                              country,
                            ].where((value) => value.isNotEmpty).join(", ");

                            return Card(
                              elevation:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 0
                                  : 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              margin: EdgeInsets.only(
                                bottom: isDesktop ? 18 : 15,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 22 : 18,
                                  vertical: isDesktop ? 12 : 10,
                                ),

                                leading: CircleAvatar(
                                  radius: isDesktop ? 30 : 28,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Text(
                                    '${firstName.isNotEmpty ? firstName.characters.first.toUpperCase() : 'N'}'
                                    '${lastName.isNotEmpty ? lastName.characters.first.toUpperCase() : 'N'}',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontSize: isDesktop ? 18 : 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                title: name.isNotEmpty
                                    ? Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      )
                                    : null,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (email.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                    if (location.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 15,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              location,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: .15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        getLocalizedRole(context, role),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(t.deleteUser),
                                        content: Text(
                                          t.deleteUserConfirmation(name),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(t.cancel),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onError,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(t.delete),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(userId)
                                            .delete();

                                        if (context.mounted) {
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
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                t.somethingWentWrong,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UserDetailsPage(userId: userId),
                                    ),
                                  );
                                },
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
}
