List<Map<String, dynamic>> cartItems = [];

double getTotalPrice() {
  double total = 0;

  for (var item in cartItems) {
    final price = (item["price"] as num?)?.toDouble() ?? 0.0;
    final quantity = item["quantity"] ?? 1;

    total += price * quantity;
  }

  return total;
}
