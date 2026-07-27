import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.orange.withValues(alpha: .12),
              child: const Icon(
                Icons.notifications_active,
                size: 45,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Notifications",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Manage how you receive updates from the app.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SwitchListTile(
                value: true,
                onChanged: (_) {},
                secondary: const Icon(Icons.shopping_bag_outlined),
                title: const Text("Order Updates"),
                subtitle: const Text("Receive updates about your orders."),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SwitchListTile(
                value: true,
                onChanged: (_) {},
                secondary: const Icon(Icons.local_offer_outlined),
                title: const Text("Offers & Discounts"),
                subtitle: const Text("Get notified about new deals."),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SwitchListTile(
                value: false,
                onChanged: (_) {},
                secondary: const Icon(Icons.campaign_outlined),
                title: const Text("Promotions"),
                subtitle: const Text("Receive promotional notifications."),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SwitchListTile(
                value: true,
                onChanged: (_) {},
                secondary: const Icon(Icons.email_outlined),
                title: const Text("Email Notifications"),
                subtitle: const Text("Receive important emails."),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Push notifications with Firebase Cloud Messaging will be available in a future update.",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
