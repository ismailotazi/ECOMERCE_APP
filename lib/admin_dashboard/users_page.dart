import 'package:ecomerce_app/admin_dashboard/user_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          "Users",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;
          debugPrint("Users count = ${users.length}");
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;

              final String firstName = user["firstName"] ?? "";
              final String lastName = user["lastName"] ?? "";
              final String name = "$firstName $lastName".trim();

              final String email = user["email"] ?? "No email";
              final String role = user["role"] ?? "user";
              final String city = user["city"] ?? "";
              final String country = user["country"] ?? "";
              final String photoUrl = user["photoUrl"] ?? "";

              return Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),

                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    backgroundColor: Colors.deepOrange.shade100,
                    child: photoUrl.isEmpty
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),

                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "$city, $country",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: role == "admin"
                              ? Colors.deepOrange.withValues(alpha: .15)
                              : Colors.blue.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: role == "admin"
                                ? Colors.deepOrange
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete User"),
                          content: Text(
                            "Are you sure you want to delete $name ?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User deleted successfully"),
                          ),
                        );
                      }
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailsPage(userId: userId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
