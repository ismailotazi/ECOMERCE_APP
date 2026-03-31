import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final Function(int) onSelect;
  final int selectedIndex;

  const AdminSidebar({
    super.key,
    required this.onSelect,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1E1E2C),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // 🔥 Header
          Column(
            children: const [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.deepOrange,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Admin Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 🔥 Menu Items
          _item(Icons.inventory_2, "Products", 0),
          _item(Icons.add_box, "Add Product", 1),
          _item(Icons.receipt_long, "Orders", 2),
          _item(Icons.people, "Users", 3),

          const Spacer(),

          // 🔐 Logout (optional)
          _item(Icons.logout, "Logout", 99, isLogout: true),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    int index, {
    bool isLogout = false,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isLogout) {
          onSelect(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout
                  ? Colors.red
                  : isSelected
                  ? Colors.white
                  : Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isLogout
                    ? Colors.red
                    : isSelected
                    ? Colors.white
                    : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
