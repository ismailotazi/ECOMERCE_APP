import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepOrange.withValues(alpha: .12),
              child: const Icon(
                Icons.credit_card,
                size: 45,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "No Payment Methods",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "You haven't added any payment methods yet.\nAdd a card to enjoy faster checkout.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Coming Soon")));
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add Payment Method",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Supported Payments",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            _paymentTile(Icons.credit_card, "Visa", "Coming Soon"),

            _paymentTile(Icons.credit_card, "Mastercard", "Coming Soon"),

            _paymentTile(Icons.account_balance_wallet, "PayPal", "Coming Soon"),

            _paymentTile(Icons.phone_iphone, "Apple Pay", "Coming Soon"),

            _paymentTile(Icons.android, "Google Pay", "Coming Soon"),

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
                    Icon(Icons.lock, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your future payments will be protected using secure encryption.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _paymentTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.withValues(alpha: .1),
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
