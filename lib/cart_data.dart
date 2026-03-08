List<Map<String, dynamic>> cartItems = [];

double getTotalPrice() {
  double total = 0;

  for (var item in cartItems) {
    String price = item["price"].replaceAll("\$", "");
    total += double.parse(price);
  }

  return total;
}
