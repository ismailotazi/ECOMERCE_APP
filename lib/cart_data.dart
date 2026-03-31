List<Map<String, dynamic>> cartItems = [];

double getTotalPrice() {
  double total = 0;

  for (var item in cartItems) {
    try {
      String priceText = item["price"] ?? "\$0";
      // إزالة علامة $ إذا كانت موجودة
      priceText = priceText.replaceAll("\$", "");
      // نتحقق من quantity (default = 1)
      int quantity = item["quantity"] ?? 1;
      total += double.parse(priceText) * quantity;
    } catch (e) {
      // نتجنب crash إلى كانت قيمة price غير صالحة
      continue;
    }
  }

  return total;
}
